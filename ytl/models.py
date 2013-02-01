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

__all_classes__ = [Photo, Blog]
