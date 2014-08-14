# Startup script
# =================================================
# This file is used to manage the whole build environment.
#
# ### Main routine
#
# This file defines the command line interface with the defined commands. They
# will be run in parallel as possible.
#
# It will work with an boolean `success` value which is handed through the
# functions to define if everything went correct or something was not possible.
# If an real and unexpected error occur it will be thrown. All errors which
# aren't caught will end in an error and abort with exit code 2.
#
# ### Task libraries
#
# Each task is made available as separate task module with the `run` method
# to be called for each alinex package. The given command on the command line
# call may trigger multiple tasks which are done.
#
# Each task will get a `command` object which holds all the information from the
# command line call.


# Node Modules
# -------------------------------------------------

errorHandler = require 'alinex-error'
errorHandler.install()
errorHandler.config.stack.modules = true

# include base modules
yargs = require 'yargs'
fs = require 'fs'
path = require 'path'
colors = require 'colors'
async = require 'async'


# Setup build environment
# -------------------------------------------------

# Root directory of the core application
GLOBAL.ROOT_DIR = path.dirname __dirname
# Read in package configuration
GLOBAL.PKG = JSON.parse fs.readFileSync path.join ROOT_DIR, 'package.json'

# set the process title
process.title = 'alinex-make'


commands =
  list: "show the list of possible commands"
  create: "create a new package"
  compile: "compile code"
  pull: "pull newest version from repository"
  push: "push changes to repository"
  publish: "publish package in npm"
  doc: "create documentation pages"
  test: "run automatic tests"
  clean: "cleanup files"


# Start argument parsing
# -------------------------------------------------
argv = yargs
.usage("""
  Utility to help simplify tasks in development.

  Usage: $0 [-vC] -c command... [dir]...
  """)
# examples
.example('$0 -f', 'count the lines in the given file')
# commands
.demand('c')
.alias('c', 'command')
.describe('c', 'command to execute (use list to see more)')
# general options
.boolean('C')
.alias('C', 'nocolors')
.describe('C', 'turn of color output')
.boolean('v')
.alias('v', 'verbose')
.describe('v', 'run in verbose mode')
# create options
.describe('private', 'create: private repository')
.describe('package', 'create: set package name')
# push options
.alias('m', 'message')
.describe('m', 'push: text for commit message')
# publish options
.describe('minor', 'publish: change to next minor version')
.describe('major', 'publish: change to next major version')
# publish options
.describe('coverage', 'test: create coverage report')
.describe('coveralls', 'test: send coverage to coveralls')
.describe('watch', 'test,doc: keep process running while watching for changes')
.describe('browser', 'test,doc: open in browser')
# doc options
.describe('publish', 'doc: push to github pages')
# clean options
.describe('dist', 'clean: all which is not needed in production')
.describe('auto', 'clean: all which is created automatically')
# general help
.help('h')
.alias('h', 'help')
.showHelpOnFail(false, "Specify --help for available options")
.check (argv, options) ->
  unless argv.command in Object.keys commands
    return "Unknown command: #{argv.command}"
  true
.argv
argv.command = [argv.command] unless Array.isArray argv.command

colors.mode = 'none' if argv.nocolors


# Run the commands
# -------------------------------------------------
async.eachSeries argv.command, (command, cb) ->
  console.log commands[argv.command].blue.bold

  cb()
, (err) ->
  throw err if err
  # check for existing command
  console.log "Done.".green
