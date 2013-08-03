require! fs
require! marked

render-unknown = (text, callback) ->
  callback text

render-markdown = (text, callback) ->
  callback marked text

module.exports = (file, callback) ->
  # Read the text from the file into memory.
  _, text <- fs.read-file file, \utf8

  # Determine the renderer to use.
  ext = /.+\.(.*)/.exec file .1
  render = switch ext
    | \md   => render-markdown
    | _     => render-unknown

  # Render the content
  render text, callback
