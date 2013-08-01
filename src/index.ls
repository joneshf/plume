require! http
require! fs
require! path
require! async

ROOT = './docs'

# GET /:path
# GET / #=> retrieve list of items under repo:// and render index.md
# GET /documentation #=> retrieve list of items under repo://documentation

server = http.create-server (request, response) ->
  # Map url to path on the source.
  url = request.url.replace /\/+$/, ''
  location = path.join ROOT, url

  _, stats <- fs.stat location
  if stats.is-directory!
    # Collect the list of available files.
    _, items <- fs.readdir location

    # Remove _'d names.
    items = [i for i in items when i.0 isnt \_]

    # Get whether each file is a directory or not.
    _, stats <- async.map items, (item, callback) ->
      name = path.join location, item
      _, fstats <- fs.stat name
      type = if fstats.is-directory! then 'directory' else 'file'
      callback null, type

    # Build and write response.
    data = {}
    data['categories'] = [n for n, i in items when stats[i] is 'directory']
    data['files'] = [n for n, i in items when stats[i] is 'file']
    data = JSON.stringify data

    response.write-head 200,
      'Content-Length': data.length,
      'Content-Type': 'application/json'

    response.write data
    response.end!

server.listen 8000, \localhost
