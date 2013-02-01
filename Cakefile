#
# TODO: staticディレクトリと、srcディレクトリを分ける
#
sys        = require 'sys'
fs         = require 'fs'
{exec}     = require 'child_process'
util       = require 'util'
growl      = require 'growl'
Q          = require 'q'

process.chdir 'static'

COFFEE_DIR = 'coffee/'
COFFEE_FILES = [
  'common.coffee',
  'app.coffee'
]
COFFEE_DESTINTAION = 'app.js'


JS_FILES = []
# library files
JS_FILES.push(
  'js/libs/jquery-1.8.3.min.js',
  'js/libs/underscore-min.js',
#  'js/libs/underscore.js',
  'js/libs/backbone-min.js',
  'js/libs/moment.min.js',
  'js/libs/jquery.lazyload.js',
  'js/libs/jquery.masonry.min.js',
  'js/libs/jquery.imagesloaded.min.js',
  'bootstrap/js/bootstrap.min.js',
)


LESS_DIR = 'less/'
LESS_FILES = [
  'ytl.less',
  'common.less',
]

q_exec = (cmd) ->
  deferred = Q.defer()
  exec cmd, (err, stdout, stderr) ->
    deferred.reject(err) if err
    deferred.resolve(stdout, stderr)
  return deferred.promise


concat_files = (files, callback, delimiter='\n\n') ->
  contents = new Array remaining = files.length

  for fn, index in files then do (fn, index) ->
    fs.readFile fn, 'utf8', (err, fileContents) ->
      if err
        growly "read file failed #{fn}"
        throw err
      contents[index] = fileContents
      callback contents.join(delimiter) if --remaining is 0


read_file = (filename) ->
  deferred = Q.defer()
  fs.readFile filename, "utf-8", (err, contents) ->
    if err
      deferred.reject err
    else
      deferred.resolve contents

  deferred.promise


concat_files2 = (files, output, delimiter='\n\n') ->
  deferred = Q.defer()

  (Q.all (read_file fn for fn in files)).then (contents) ->
    fs.writeFile output, contents.join(delimiter), 'utf8', (err) ->
      if err
        deferred.reject err
      else
        deferred.resolve output
  .done()

  deferred.promise


watch_files = (files, taskname) ->
  util.log taskname + ' > ' + files
  for fn in files
    watcher = fs.watch fn, (event, filename) ->
      util.log event + ' ' + fn
      if event == 'change'
        util.log "changes in #{fn}, invoke #{taskname}"
        invoke taskname
      else if event == 'rename'
        watcher.close()
        watch_files [fn], taskname


growly = (message='') ->
  options =
    title: 'CoffeeScript'
  growl message, options


##### tasks
task 'watch', 'Watch source files and build changes', ->
  invoke 'watch:js'
  invoke 'watch:less'


task 'watch:js', '', ->
  invoke 'build:js'

  files = (COFFEE_DIR + fn for fn in COFFEE_FILES)
  files = files.concat(JS_FILES)
  files.pop files.indexOf('app.js')
  watch_files files, 'build:js'


task 'watch:less', '', ->
  invoke 'build:less'

  watch_files (LESS_DIR + fn for fn in LESS_FILES), 'build:less'


task 'build', 'Build single js file from source files', ->
  invoke 'build:js'
  invoke 'build:less'


task 'build:js', 'Build fdk.js', ->
  invoke 'build:coffee'
  Q.all([
    q_exec "cat #{JS_FILES.join(' ')} > js/libs.js"
  ])
  .then ->
    q_exec "cat js/libs.js js/app.js > js/ytl.js"
    util.log 'js compiled'
  .done()


task 'build:coffee', 'Build single js file from source files', ->
  build_coffee('app', COFFEE_FILES).done()


build_coffee = (prefix, coffee_files) ->
  util.log "build_coffee #{prefix} #{coffee_files}" 
  # make .build dir
  build_dir_path = "#{COFFEE_DIR}.build/"
  if not fs.existsSync(build_dir_path)
    fs.mkdirSync(build_dir_path)

  # concat
  Q.all coffee_files.map (source) ->
      destination = source.replace(/.coffee$/, '.js')
      q_exec "coffee --compile -o #{build_dir_path} #{COFFEE_DIR}#{source}"
  .then ->
    files = coffee_files.map (fn) -> "#{build_dir_path}#{fn.replace(/.coffee$/, '.js')}"
    q_exec "cat #{files.join(' ')} > js/#{prefix}.js"
  .then ->
    util.log "js/#{prefix}.js compiled"
    # uglify
    q_exec "uglifyjs -o js/#{prefix}.min.js js/#{prefix}.js"
  .then ->
    util.log "js/#{prefix}.min.js compiled"


task 'build:less', 'Build less file', ->
  render_less('ytl')


render_less = (prefix) ->
  exec "lessc less/#{prefix}.less", (err, stdout, stderr) ->
    if err
      util.log stdout + stderr
      growly "less compile failed"
    else
      fs.writeFile "css/#{prefix}.css", stdout, 'utf8', (err) ->
        if err
          growly 'less save failed'
        else
          growly 'less compile succeeded'
          util.log "#{prefix}.css compiled"

  exec "lessc --yui-compress less/#{prefix}.less", (err, stdout, stderr) ->
    if err
      util.log stdout + stderr
      growly "less compile failed"
    else
      fs.writeFile "css/#{prefix}.min.css", stdout, 'utf8', (err) ->
        if err
          growly 'less save failed'
        else
          growly 'less compile succeeded'
          util.log "#{prefix}.min.css compiled"
