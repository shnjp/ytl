# -*- coding:utf-8 -*-
import os
import sys
import time
from crendentials import *

GOOGLE_CX = '000678964075068892961:8tmauknnxqw'

TUMBLER_API_ENDPOINT = 'http://api.tumblr.com'
TUMBLER_IMAGE_POST_API_ENDPOINT = TUMBLER_API_ENDPOINT + '/v2/blog/{blogname}.tumblr.com/posts/photo'

__all__ = [
    'GOOGLE_API_ENDPOINT', 'GOOGLE_API_KEY', 'GOOGLE_CX',
    'TUMBLER_CONSUMER_KEY', 'TUMBLER_SECRET_KEY', 'TUMBLER_API_ENDPOINT', 'TUMBLER_IMAGE_POST_API_ENDPOINT'
]


class ConfigBase(object):
    pass


class DevelopmentConfig(ConfigBase):
    MONGODB_HOST = 'localhost'
    MONGODB_PORT = 27017
    MONGODB_DATABASE = 'ytl'

    DEBUG = True
