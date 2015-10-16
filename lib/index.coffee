'use strict'

Args          = require 'args-js'
nodeify       = require 'nodeify'
promise       = require 'cb2promise'
Errorifier    = require 'errorifier'
parseJson     = require 'parse-json'
loadJsonFile  = require 'load-json-file'
writeJsonFile = require 'write-json-file'

_stringify = (data, replacer, space) ->
  JSON.stringify(data, replacer, space) + '\n'

_stringifyAsync = (data, replacer, space, cb) ->
  content = null
  error = null

  try
    content = _stringify data, replacer, space
  catch err
    content = {}
    error = new Errorifier
      code: 'ENOVALIDJSON',
      message: err.message
  finally
    process.nextTick ->
      cb null, content

_loadAsync = loadJsonFile

_load = loadJsonFile.sync

_saveAsync = writeJsonFile

_save = writeJsonFile.sync

_parse = parseJson

_parseAsync = (data, reviver, filename, cb) ->
  content = null
  error = null

  try
    content = _parse data, reviver, filename
  catch err
    content = {}
    error = new Errorifier
      code: 'ENOVALIDJSON',
      message: err.message
  finally
    process.nextTick ->
      cb error, content

module.exports =

  stringifyAsync: ->
    args = Array.prototype.slice.call arguments
    cb = if typeof args[args.length - 1] is 'function' then args.pop() else null

    {data, replacer, space}  = Args([
      { data    : Args.OBJECT   | Args.Required              }
      { replacer: Args.FUNCTION | Args.Optional              }
      { space   : Args.NUMBER   | Args.Optional, _default: 2 }
    ], args)

    return promise _stringifyAsync, data, replacer, space unless cb
    _stringifyAsync data, replacer, space, cb

  stringify: ->
    {data, replacer, space}  = Args([
      { data    : Args.OBJECT   | Args.Required              }
      { replacer: Args.FUNCTION | Args.Optional              }
      { space   : Args.NUMBER   | Args.Optional, _default: 2 }
    ], arguments)

    _stringify data, replacer, space

  parseAsync: ->
    args = Array.prototype.slice.call arguments
    cb = if typeof args[args.length - 1] is 'function' then args.pop() else null

    {data, reviver, filename}  = Args([
      { data     : Args.STRING   | Args.Required }
      { reviver  : Args.FUNCTION | Args.Optional }
      { filename : Args.STRING   | Args.Optional }
    ], args)

    return promise _parseAsync, data, reviver, filename unless cb
    _parseAsync data, reviver, filename, cb

  parse: parseJson

  loadAsync: ->
    {filepath, opts, cb}  = Args([
      { filepath : Args.STRING   | Args.Required }
      { cb       : Args.FUNCTION | Args.Optional }
    ], arguments)

    return nodeify _loadAsync(filepath), cb if cb
    _loadAsync filepath

  load: ->
    {filepath, opts}  = Args([
      { filepath : Args.STRING | Args.Required }
    ], arguments)

    _load filepath

  saveAsync: ->
    {filepath, data, opts, cb}  = Args([
      { filepath : Args.STRING   | Args.Required                             }
      { data     : Args.OBJECT   | Args.Required                             }
      { opts     : Args.OBJECT   | Args.Optional, _default: indent: '  '     }
      { cb       : Args.FUNCTION | Args.Optional                             }
    ], arguments)

    return nodeify _saveAsync(filepath, data, opts), cb if cb
    _saveAsync filepath

  save: ->
    {filepath, data, opts, cb}  = Args([
      { filepath : Args.STRING | Args.Required                         }
      { data     : Args.OBJECT | Args.Required                         }
      { opts     : Args.OBJECT | Args.Optional, _default: indent: '  ' }
    ], arguments)

    _save filepath, data, opts