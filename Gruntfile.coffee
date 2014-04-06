module.exports = (grunt) ->

  # Output
  libName = "ajs.js"
  productionName = "ajs-prod.min.js"
  productionNameFull = "ajs-prod-full.min.js"

  # Directories
  buildDir = "build"
  libDir = "lib"
  testDir = "test"
  devDir = "dev"
  production = "#{buildDir}/#{productionName}"
  productionFull = "#{buildDir}/#{productionNameFull}"

  productionConcatFull = [
    "#{devDir}/components/adefyre/build/are-prod-full.min.js"
    "#{devDir}/js/ajs.js"
  ]

  # Intermediate vars
  __adefyOut = {}
  __adefyOut["#{buildDir}/ajs-concat.coffee"] = [ "#{libDir}/AJS.coffee" ]
  __adefyOut["#{devDir}/ajs-concat.coffee"] = [ "#{libDir}/AJS.coffee" ]

  __coffeeConcatFiles = {}

  # Build concat output
  __coffeeConcatFiles["#{buildDir}/#{libName}"] = "#{buildDir}/ajs-concat.coffee";

  # Dev concat output, used for browser testing
  __coffeeConcatFiles["#{devDir}/#{libName}"] = "#{buildDir}/ajs-concat.coffee";

  # 1 to 1 compiled files, for unit tests
  __coffeeFiles = [
    "#{libDir}/*.coffee"
    "#{libDir}/**/*.coffee"
  ]
  __testFiles = {}
  __testFiles["#{buildDir}/test/spec.js"] = [
    "#{testDir}/spec/*.coffee"
    "#{testDir}/spec/**/*.coffee"
  ]

  _uglify = {}
  _uglify[production] = "#{buildDir}/#{libName}"
  _uglify[productionFull] = productionFull

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    coffee:
      concat:
        options:
          sourceMap: true
          bare: true
        cwd: buildDir
        files: __coffeeConcatFiles
      lib:
        expand: true
        options:
          bare: true
        src: __coffeeFiles
        dest: buildDir
        ext: ".js"
      tests:
        expand: true
        options:
          bare: true
        files: __testFiles

    concat_in_order:
      lib:
        files: __adefyOut
        options:
          extractRequired: (path, content) ->

            workingDir = path.split "/"
            workingDir.pop()

            deps = @getMatches /\#\s\@depend\s(.*\.coffee)/g, content
            deps.forEach (dep, i) ->
              deps[i] = "#{workingDir.join().replace(',', '/')}/#{dep}"
              console.log "Got dep #{deps[i]}"

            return deps
          extractDeclared: (path) -> [path]
          onlyConcatRequiredFiles: true

    watch:
      coffeescript:
        files: [
          "#{libDir}/**/*.coffee"
          "#{libDir}/*.coffee"
          "#{testDir}/**/*.coffee"
          "#{testDir}/*.coffee"
        ]
        tasks: ["concat_in_order", "coffee", "mocha"]

    connect:
      server:
        options:
          port: 8081
          base: "./"

    mocha:
      all:
        src: [ "#{buildDir}/#{testDir}/test.html" ]
        options:
          bail: false
          log: true
          reporter: "Nyan"
          run: true

    copy:
      test_page:
        files: [
          expand: true
          cwd: "#{testDir}/env"
          src: [ "**" ]
          dest: "#{buildDir}/#{testDir}"
        ]

    clean: [
      buildDir
    ]

    # Production concat
    concat:
      options:
        stripBanners: true
      distFull:
        src: productionConcatFull
        dest: productionFull

    uglify:
      options:
        preserveComments: false
        banner: "/* Copyright © 2013 Spectrum IT Solutions Gmbh - All Rights Reserved */\n"
      production:
        files: _uglify

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-concat-in-order"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-mocha"

  # Perform a full build
  grunt.registerTask "default", ["full"]
  grunt.registerTask "full", [
    "clean"
    "copy:test_page"
    "concat_in_order"
    "coffee"
    "mocha"
    "concat"
    "uglify"
  ]
  grunt.registerTask "dev", ["connect", "copy:test_page", "watch"]
