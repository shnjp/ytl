# -*- coding: utf-8 -*-
from flask.ext.mongokit import Document


class Photo(Document):
    __collection__ = 'photos'


class Blog(Document):
    __collection__ = 'blogs'


__all_classes__ = [Photo, Blog]
