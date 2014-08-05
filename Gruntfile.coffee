
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    browserify:
      jssdk:
        files:
          'build/cineio-dev.js': ['src/main.coffee']
        options:
          browserifyOptions:
            extensions: ['.coffee', '.js']
          transform: ['coffeeify']

    uglify:
      options:
        report: "min"

      production:
        files:
          "build/cineio.js": ["build/cineio-dev.js"]

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask "compile", ["browserify:jssdk", "uglify"]
