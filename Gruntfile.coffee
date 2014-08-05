
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

      tests:
        files:
          'compiled/all-tests.js': ['src/main.coffee', 'test/test_helper.coffee', 'test/*.coffee']
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


    mocha:
      all:
        src: ['test/runner.html']
      options:
        run: true
        log: true

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-mocha');

  grunt.registerTask "compile", ["browserify:jssdk", "uglify"]

  grunt.registerTask "test", ["browserify:tests", "mocha"]

  grunt.registerTask "default", "test"
