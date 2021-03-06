# Test Script
# ========================================================================


# Node modules
# -------------------------------------------------

# node packages
path = require 'path'
coffee = require 'coffee-script'
async = require 'async'
# alinex packages
fs = require 'alinex-fs'
# internal mhelper modules
builder = require '../index'


# Compile coffee -> js
# ------------------------------------------------
# _Arguments:_
#
# - `verbose` - (integer) verbose level
# - `uglify` - (boolean) should uglify be used
module.exports = (dir, options, cb) ->
  src = path.join dir, 'src'
  lib = path.join dir, 'lib'
  # find files to compile
  fs.find src,
    filter:
      include: '*.coffee'
  , (err, files) ->
    return cb err if err
    return cb() unless files.length
    builder.info dir, options, "compile coffee script files"
    async.each files, (file, cb) ->
      fs.readFile file, 'utf8', (err, data) ->
        return cb err if err
        jsfile = path.basename(file, '.coffee') + '.js'
        mapfile = path.basename(file, '.coffee') + '.map'
        builder.noisy dir, options, "compile #{file[src.length+1..]}"
        compiled = coffee.compile data,
          filename: path.basename file
          generatedFile: jsfile
          sourceRoot: path.relative path.dirname(file), dir
          sourceFiles: [ file ]
          sourceMap: true
        compiled.js += "\n//# sourceMappingURL=#{path.basename mapfile}"
        # write files
        filepathjs = path.join lib, path.dirname(file)[src.length..], jsfile
        filepathmap = path.join lib, path.dirname(file)[src.length..], mapfile
        async.parallel [
          (cb) ->
            fs.mkdirs path.dirname(filepathjs), (err) ->
              return cb err if err and err.code isnt 'EEXIST'
              fs.writeFile filepathjs, compiled.js, cb
          (cb) ->
            fs.mkdirs path.dirname(filepathmap), (err) ->
              return cb err if err and err.code isnt 'EEXIST'
              fs.writeFile filepathmap, compiled.v3SourceMap, cb
        ], (err) ->
          return cb err if err or not options.uglify
          builder.task 'uglify', dir,
            verbose: options.verbose
            dir: path.dirname filepathjs
            fromjs: jsfile
            frommap: mapfile
            tojs: jsfile
            tomap: mapfile
          , cb
    , cb
