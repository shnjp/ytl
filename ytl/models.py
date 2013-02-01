# -*- coding: utf-8 -*-
from flask.ext.mongokit import Document
import datetime


class Photo(Document):
    __collection__ = 'photos'
    # TODO:めんどい
    use_schemaless = True
    structure = {
        'reblog_key': unicode,
        'posts': [basestring]
    }
    required_fields = ['reblog_key', 'posts']


class Blog(Document):
    __collection__ = 'blogs'

    structure = {
        'blog_name': basestring,
        'date_fetch_by_google': datetime.datetime
    }
    required_fields = ['blog_name']


class Similarity(Document):
    __collection__ = 'similarities'

    structure = {
        'key': basestring,
        'pair': [basestring],
        'coefficient': float
    }
    required_fields = ['key', 'pair', 'coefficient']


__all_classes__ = [Photo, Blog, Similarity]
