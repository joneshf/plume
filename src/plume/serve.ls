require! fs
require! path
require! async

require! render: './render'

ROOT = './docs'

#! Purge item list.
#! Remove all _* names.
purge-private = (items) -> [i for i in items when i.0 isnt \_]

#! GET /
#! GET /documentation
#!
#! Should return something like:
#!  categories := <[ documentation foreward etc ]>
#!  files      := #=> files available
#!  index      := #=> rendered index file
handle-directory = (req, res, directory) ->
  # Collect the list of available files.
  _, items <- fs.readdir directory

  # Purge list of items.
  items = purge-private items

  # Iterate through the series of items.
  _, items <- async.map items, (item, callback) ->
    # Get meta information on the item.
    name = path.join directory, item
    _, info <- fs.stat name

    if info.is-directory!
      # Push on category listing.
      callback null, ['categories', item]

    else
      if /^index/.test item
        # Render and put in index.
        text <- render (path.join directory, item)
        callback null, ['index', text]

      else
        # Push on file listing.
        callback null, ['files', item]

  # Pull out and set into a data dictionary.
  data = {categories: [], files: [], index: null}
  for [type, what] in items
    if type isnt \index
      data[type].push what

    else
      data[type] = what

  # Send and close the response.
  data = JSON.stringify data
  res.write-head 200,
    'Content-Length': data.length,
    'Content-Type': 'application/json'

  res.end data

#! GET /index
#! GET /documentation/foreward/what-is-rest
#! GET /documentation/foreward/why-armet
#! GET /documentation/foreward/configuration-and-conventions
#!
#! Should return:
#!  content   := #=> rendered file
handle-file = (req, res) ->
  res.end!

exports.handle = (req, res) ->
  # Map url to path on the source.
  url = req.url.replace /\/+$/, ''
  location = path.join ROOT, url

  # Get information on path.
  _, info <- fs.stat location
  unless info
    res.write-head 404
    res.end!
    return

  # Transfer the directory or file handling.
  handler = if info.is-directory! then handle-directory else handle-file
  handler req, res, location
