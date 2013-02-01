db.blogs.ensureIndex({'blog_name': 1}, {unique: true});

db.photos.ensureIndex({'reblog_key': 1}, {unique: true});

db.similarities.ensureIndex({'key': 1}, {unique: true});
db.similarities.ensureIndex({'pair': 1})
