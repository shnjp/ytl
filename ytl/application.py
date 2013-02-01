# -*- coding: utf-8 -*-
import time
from flask import Flask
from flask.ext.mongokit import MongoKit


def create_app(config):
    uptime = int(time.time())

    global app, db
    app = YTLWebApp('ytl', static_folder='../static')
    app.config.from_object(config)
    app.secret_key = app.config['SECRET_KEY']

    # init database
    db = MongoKit(app)
    from .models import __all_classes__
    db.register(__all_classes__)

    # load views
    # TODO: きもい
    from . import views

    # template context
    constants = {
        'UPTIME': uptime
    }

    @app.context_processor
    def template_constatns():
        # update constants
        return constants

    return app


class YTLWebApp(Flask):
    pass
