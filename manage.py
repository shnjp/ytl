#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from flask.ext.script import Manager, prompt_bool, Command


def create_app(config_name=None):
    from ytl.application import create_app

    if not config_name:
        try:
            config_name = os.environ['YTL_ENV']
        except KeyError:
            print >>sys.stderr, '${YTL_ENV} not set'
            sys.exit(1)

    app = create_app('config.{}Config'.format(config_name.capitalize()))
    return app


manager = Manager(create_app)


def check_defaultencoding():
    import sys
    if sys.getdefaultencoding() == 'utf-8':
        return

    print 'Default encoding is not utf-8!'
    command = sitecustomize_command()
    if sys.stdin.isatty() and prompt_bool('May I run `{}`'.format(command)):
        import commands
        print commands.getoutput(command)
    print 'OK, re-run the command as you wish.'
    sys.exit(1)


def sitecustomize_command():
    heredir = os.path.abspath(os.path.dirname(__file__))
    ctx = dict(source=os.path.join(heredir, 'sitecustomize.py'), dest=os.path.normpath(os.path.join(heredir, 'env', 'lib', 'python2.7', 'site-packages')))
    return 'ln -s {source} {dest}/'.format(**ctx)


# subscript
class RunSubscript(Command):
    """細かいスクリプトを実行する"""
    capture_all_args = True

    def run(self, args):
        subscript = args.pop(0)
        if ':' in subscript:
            script, proc = subscript.split(':', 1)
        else:
            script, proc = subscript, 'main'
        mod = __import__('bin.' + subscript, globals(), locals(), [proc])
        getattr(mod, proc)(*args)
manager.add_command('bin', RunSubscript())


if __name__ == "__main__":
    check_defaultencoding()
    sys.argv = [v.decode('utf-8') for v in sys.argv]
    manager.run()
