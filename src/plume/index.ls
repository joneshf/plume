require! http
require! render: './render'
require! serve: './serve'

module.exports = plume = (req, res) ->
  serve.handle req, res

plume.create-server = ->
  http.create-server plume
