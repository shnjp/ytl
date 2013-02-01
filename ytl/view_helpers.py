# -*- coding:utf-8 -*-
#import json
from bson import json_util
from functools import wraps
from flask import current_app, request, render_template as flask_render_template, redirect
from flask.views import View
from flask.helpers import flash

__all__ = ['render_template', 'templated', 'jsonify']


def render_template(template=None, ctx=None, no_cache=True, no_frame=True):
    template_name = template
    if template_name is None:
        template_name = request.endpoint \
            .replace('.', '/') + '.html'
    if ctx is None:
        ctx = {}
    rendered = flask_render_template(template_name, **ctx)
    headers = ctx.get('__headers', [])

    if no_frame:
        headers.append(('X-Frame-Options', 'deny'))

    if no_cache:
        headers.append(('Cache-Control', 'private, no-cache, no-store, must-revalidate'))
        headers.append(('Expires', 'Sat, 01 Jan 2000 00:00:00 GMT'))
        headers.append(('Pragma', 'expires'))

    return current_app.response_class(rendered, headers=headers)


##### for view func
def templated(template=None, no_cache=True, no_frame=True):
    """返り値をテンプレートを使って表現"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            ctx = f(*args, **kwargs)
            if ctx is None:
                ctx = {}
            elif not isinstance(ctx, dict):
                return ctx
            return render_template(template, ctx, no_cache, no_frame)

        return decorated_function
    return decorator


def jsonify(**kwargs):
    no_cache = kwargs.pop('_no_cache', True)

    headers = []
    body = json_util.dumps(dict(**kwargs),
        indent=None if request.is_xhr else 2, ensure_ascii=False, encoding="utf8")

    if no_cache:
        headers.append(('Cache-Control', 'private, no-cache, no-store, must-revalidate'))
        headers.append(('Expires', 'Sat, 01 Jan 2000 00:00:00 GMT'))
        headers.append(('Pragma', 'expires'))

    return current_app.response_class(body, mimetype='application/json; charset=utf-8', headers=headers)
