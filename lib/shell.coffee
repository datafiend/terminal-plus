{Task} = require 'atom'

Path = require 'path'
fork = require.resolve './fork'

module.exports =
class Shell
  child: null

  constructor: ({pwd, shellPath}) ->

    disableInput = =>
      @fork = null
      @input = ->
      @resize = ->

    shellArguments = atom.config.get 'terminal-plus.core.shellArguments'
    args = shellArguments.split(/\s+/g).filter (arg) -> arg
    if /zsh|bash/.test(shellPath) and args.indexOf('--login') == -1
      args.unshift '--login'

    @fork = Task.once fork, Path.resolve(pwd), shellPath, args, disableInput

  destroy: ->
    @terminate()


  ###
  Section: External Methods
  ###

  input: (data) ->
    return unless @isStillAlive()

    @fork.send event: 'input', text: data

  resize: (cols, rows) ->
    return unless @isStillAlive()

    @fork.send {event: 'resize', rows, cols}

  isStillAlive: ->
    return false unless @fork and @fork.childProcess
    return @fork.childProcess.connected and !@fork.childProcess.killed

  terminate: ->
    @fork.terminate()

  on: (event, handler) ->
    @fork.on event, handler

  off: (event, handler) ->
    if handler
      @fork.off event, handler
    else
      @fork.off event
