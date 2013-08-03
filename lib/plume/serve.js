var fs, path, async, render, ROOT, purgePrivate, handleDirectory, handleFile;
fs = require('fs');
path = require('path');
async = require('async');
render = require('./render');
ROOT = './docs';
purgePrivate = function(items){
  var i$, len$, i, results$ = [];
  for (i$ = 0, len$ = items.length; i$ < len$; ++i$) {
    i = items[i$];
    if (i[0] !== '_') {
      results$.push(i);
    }
  }
  return results$;
};
handleDirectory = function(req, res, directory){
  return fs.readdir(directory, function(_, items){
    items = purgePrivate(items);
    return async.map(items, function(item, callback){
      var name;
      name = path.join(directory, item);
      return fs.stat(name, function(_, info){
        if (info.isDirectory()) {
          return callback(null, ['categories', item]);
        } else {
          if (/^index/.test(item)) {
            return render(path.join(directory, item), function(text){
              return callback(null, ['index', text]);
            });
          } else {
            return callback(null, ['files', item]);
          }
        }
      });
    }, function(_, items){
      var data, i$, len$, ref$, type, what;
      data = {
        categories: [],
        files: [],
        index: null
      };
      for (i$ = 0, len$ = items.length; i$ < len$; ++i$) {
        ref$ = items[i$], type = ref$[0], what = ref$[1];
        if (type !== 'index') {
          data[type].push(what);
        } else {
          data[type] = what;
        }
      }
      data = JSON.stringify(data);
      res.writeHead(200, {
        'Content-Length': data.length,
        'Content-Type': 'application/json'
      });
      return res.end(data);
    });
  });
};
handleFile = function(req, res){
  return res.end();
};
exports.handle = function(req, res){
  var url, location;
  url = req.url.replace(/\/+$/, '');
  location = path.join(ROOT, url);
  return fs.stat(location, function(_, info){
    var handler;
    if (!info) {
      res.writeHead(404);
      res.end();
      return;
    }
    handler = info.isDirectory() ? handleDirectory : handleFile;
    return handler(req, res, location);
  });
};