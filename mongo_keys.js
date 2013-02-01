db.blogs.ensureIndex({'blog_name': 1}, {unique: true});

db.posts.ensureIndex({'reblog_key': 1}, {unique: true});
