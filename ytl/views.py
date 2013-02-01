# -*- coding:utf-8 -*-
from flask import request
from .application import app, db
from .view_helpers import *


@app.route('/')
@templated('index.html')
def site_top():
    pass


@app.route('/photos')
def site_top_photos():
    skip = int(request.args.get('skip', '0'), 10)

    cursor = db.Photo.find({}).sort([('note_count', -1)]).limit(20).skip(skip)
    photos = list(cursor)
    return jsonify(photos=photos)
