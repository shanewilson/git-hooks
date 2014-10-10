var gulp = require('gulp');
var fs = require('graceful-fs');

gulp.task('changelog', function(){
  require('conventional-changelog')({
    repository: 'https://github.com/NCI-GDC/portal-ui',
    version: require('./package.json').version,
    issueLink: function (id) {
      return '[GDC-'+id+'](https://jira.oicr.on.ca/browse/GDC-' + id + ')'
    }
  }, function(err, log) {
    fs.writeFile('CHANGELOG.md', log);
  });
});
