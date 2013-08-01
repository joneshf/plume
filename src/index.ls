require! http
require! fs
require! path

ROOT = './docs'

# GET /:path
# GET / #=> retrieve list of items under repo:// and render index.md
# GET /documentation #=> retrieve list of items under repo://documentation

server = http.create-server (request, response) ->
  # Map url to path on the source.
  url = request.url.replace /\/+$/, ''
  location = path.join ROOT, url
  (_, stats) <- fs.stat location
  if stats.is-directory!
    # Collect the list of available files.
    (_, files) <- fs.readdir location
    console.log "files", files

  else

  response.end!

server.listen 8000, \localhost
