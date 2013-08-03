var http, render, serve, plume;
http = require('http');
render = require('./render');
serve = require('./serve');
module.exports = plume = function(req, res){
  return serve.handle(req, res);
};
plume.createServer = function(){
  return http.createServer(plume);
};