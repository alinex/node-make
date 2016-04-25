# Test Script
# ========================================================================


# Node modules
# -------------------------------------------------

# node packages
path = require 'path'
{exec} = require 'child_process'
# internal mhelper modules
builder = require '../index'


# Pull newest git changes
# ------------------------------------------------
# _Arguments:_
#
# - `verbose` - (integer) verbose level
# - `target` - (string) url to open
module.exports = (dir, options, cb) ->
  builder.debug dir, options, "open #{options.target} in browser"
  # call browser
  opener = switch process.platform
    when 'darwin' then 'open'
    # if the first parameter to start is quoted, it uses that as the title
    # so we pass a blank title so we can quote the file we are opening
    when 'win32' then 'start ""'
    # use Portlands xdg-open everywhere else
    else path.resolve __dirname, '../../bin/xdg-open'
  exec opener + ' "' + encodeURI(options.target) + '"', cb
