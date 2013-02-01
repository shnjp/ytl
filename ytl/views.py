# -*- coding:utf-8 -*-
from flask import request
from .application import app, db
from .view_helpers import *


@app.route('/')
@templated('index.html')
def site_top():
    pass


@app.route('/who/<who>')
@templated('index.html')
def who(who):
    pass


@app.route('/photos')
def site_top_photos():
    return response_photolist({})


@app.route('/who/<who>/photos')
def who_photos(who):
    return response_photolist({'likes': who})


@app.route('/who/<who>/similars')
def who_similars(who):
    similars = []
    query = db.Similarity.find({'pair': who}).sort([('coefficient', -1)]).limit(20)
    for s in query:
        pair = s['pair']
        similars.append(pair[0] if pair[1] == who else pair[1])  # TODO:もっと綺麗にかけそう

    return jsonify(similars=similars)


def response_photolist(query):
    skip = int(request.args.get('skip', '0'), 10)

    cursor = db.Photo.find(query).sort([('note_count', -1)]).limit(20).skip(skip)
    photos = list(cursor)
    return jsonify(photos=photos)
