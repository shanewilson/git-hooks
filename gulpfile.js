var gulp = require('gulp');
var fs = require('graceful-fs');

gulp.task('changelog', function(){
  require('conventional-changelog')({
    repository: 'https://github.com/shanewilson/git-hooks/',
    version: require('./package.json').version
  }, function(err, log) {
    fs.writeFile('CHANGELOG.md', log);
  });
});
