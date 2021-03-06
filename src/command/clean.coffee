# Test Script
# ========================================================================


# Node modules
# -------------------------------------------------

# internal mhelper modules
builder = require '../index'


# Setup
# -------------------------------------------------

exports.title = 'cleanup files'
exports.description = """
Remove unneccessary folders.
"""

exports.options =
  auto:
    alias: 'a'
    type: 'boolean'
    describe: 'Remove all automatically generated folders'
  dist:
    type: 'boolean'
    describe: 'Remove unneccessary folders for production'


# Handler
# ------------------------------------------------

exports.handler = (options, cb) ->
  # step over directories
  builder.dirs options, (dir, options, cb) ->
    builder.task 'clean', dir, options, cb
  , cb
