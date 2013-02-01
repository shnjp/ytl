# -*- coding:utf-8 -*_
from pymongo import *


def init_mongo_db(config):
    host, port, db = config['MONGO_HOST'], config['MONGO_PORT'], config['MONGO_DB']

    connection = Connection(host, port)
    db = connection[db]

    return db
