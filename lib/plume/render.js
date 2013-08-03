var fs, marked, renderUnknown, renderMarkdown;
fs = require('fs');
marked = require('marked');
renderUnknown = function(text, callback){
  return callback(text);
};
renderMarkdown = function(text, callback){
  return callback(marked(text));
};
module.exports = function(file, callback){
  return fs.readFile(file, 'utf8', function(_, text){
    var ext, render;
    ext = /.+\.(.*)/.exec(file)[1];
    render = (function(){
      switch (ext) {
      case 'md':
        return renderMarkdown;
      default:
        return renderUnknown;
      }
    }());
    return render(text, callback);
  });
};