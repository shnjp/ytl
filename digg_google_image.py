#!/usr/bin/env python
# -*- coding:utf-8 -*-
import sys
import urllib3
import json
from config import *
import re
import pprint
from datetime import datetime
from ytl.database import init_mongo_db

http = urllib3.PoolManager()
urllib3.add_stderr_logger()


TUMBLR_REX = re.compile('^http://([^.]+).tumblr.com/post/(\d+)')


class IsNotTumblerURL(StandardError):
    pass


def main(usernames):
    db = init_mongo_db({
        'MONGO_HOST': 'localhost',
        'MONGO_PORT': 27017,
        'MONGO_DB': 'ytl'
    })

    # TODO: usernameじゃなくてblog_nameな
    for username in usernames:
        for image in digg_google_image(db, username):
            try:
                digg_tumbler_image(db, image['image']['contextLink'])
            except IsNotTumblerURL:
                pass


def digg_google_image(db, username):
    # update timestamp
    try:
        obj = db.blogs.find({'blog_name': username})[0]
    except IndexError:
        obj = {'blog_name': username}
    obj['date_fetch_by_google'] = datetime.utcnow()
    db.blogs.save(obj)

    params = {
        'alt': 'json',
        'cx': GOOGLE_CX,
        'key': GOOGLE_API_KEY,
        'q': '"{} liked this"'.format(username),
        'searchType': 'image'
    }

    while True:
        resp = http.request('GET', GOOGLE_API_ENDPOINT, params)
        if resp.status == 400:
            break
        elif resp.status != 200:
            raise ValueError('bad response')

        data = json.loads(resp.data)
        for item in data['items']:
            yield item

        # 次のクエリ
        try:
            next = data['queries']['nextPage'][0]
        except KeyError:
            break
        params['start'] = next['startIndex']


def digg_google_image_dummy(username):
    with open('google/{}.json'.format(username)) as fp:
        data = json.load(fp)

        for item in data['items']:
            yield item


def digg_tumbler_image(db, url):
    """
    tumblrで投稿されている画像は、写真自体のURLで同一判定ができるようだ。
    source_urlをたどっていっても、notesの数は同一なので、これは共有されている模様。
    """
    mo = TUMBLR_REX.match(url)
    if not mo:
        raise IsNotTumblerURL()
    blogname, post_id = mo.groups()

    # 対象ポストが既に取得済みか探す
    post_key = '{}/{}'.format(blogname, post_id)

    try:
        photo = db.photos.find({'posts': post_key})[0]
        # TODO: 日付が古ければ再取得しよう!
        print >>sys.stderr, 'skip', url
        return
    except IndexError:
        # 未取得
        pass

    params = {
        'api_key': TUMBLER_CONSUMER_KEY,
        'id': post_id,
        'notes_info': 'true'
    }
    resp = http.request('GET', TUMBLER_IMAGE_POST_API_ENDPOINT.format(blogname=blogname), params)
    if resp.status != 200:
        raise ValueError('bad response')

    data = json.loads(resp.data)
    post = data['response']['posts'][0]
    if post['type'] != 'photo':
        return

    photo_link = post['photos'][0]['original_size']['url']

    timestamp = post['timestamp']
    likes = []
    reblogs = []
    posts = set([post_key])
    blogs = set()
    for note in post['notes']:
        t = note.get('timestamp')
        if t and t < timestamp:
            timestamp = t
        ty = note['type']
        blogs.add(note['blog_name'])
        if ty == 'like':
            likes.append(note['blog_name'])
        elif ty == 'reblog':
            reblogs.append(note['blog_name'])
            posts.add('{}/{}'.format(note['blog_name'], note['post_id']))
        else:
            pass

    # sourceをたどる必要は特に無い
    # source_url = post['source_url']

    # postを投稿
    doc = {
        'timestamp': t,
        'reblog_key': post['reblog_key'],
        'photo_link': photo_link,
        'photso': post['photos'],
        'date_updated': datetime.utcnow(),
        'posts': list(posts),
        'reblogs': reblogs,
        'likes': likes,
        'like_count': len(likes),
        'reblog_count': len(reblogs),
        'note_count': post['note_count']
    }
    db.photos.insert(doc)

    # user追加
    blogs = [{'blog_name': x} for x in blogs]
    db.blogs.insert(blogs, continue_on_error=True)


if __name__ == '__main__':
    main(sys.argv[1:])
