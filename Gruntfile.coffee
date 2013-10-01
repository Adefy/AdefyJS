module.exports = (grunt) ->

  # Output
  libName = "adefy.js"
  productionName = "ajs-prod.min.js"
  productionNameFull = "ajs-prod-full.min.js"

  # Directories
  buildDir = "build"
  libDir = "lib"
  testDir = "test"
  devDir = "dev"
  docDir = "doc"
  awglDir = "../AdefyWebGL"
  cdnDir = "../www/ajs"
  production = "#{buildDir}/#{productionName}"
  productionFull = "#{buildDir}/#{productionNameFull}"

  productionConcatFull = [
    "#{devDir}/js/underscore.min.js"
    "#{devDir}/js/sylvester.js"
    "#{devDir}/js/glUtils.js"
    "#{devDir}/js/mjax.min.js"
    "#{devDir}/js/gl-matrix-min.js"
    "#{devDir}/js/cp.min.js"

    "#{devDir}/js/adefy.js"
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
      awgl:
        files: [
          expand: false
          src: "#{awglDir}/build/awgl.js"
          dest: "#{buildDir}/static/js/awgl.js"
        ,
          expand: false
          src: "#{awglDir}/build/awgl.js"
          dest: "#{devDir}/js/awgl.js"
        ,
          expand: false
          src: "#{awglDir}/build/awgl-concat.coffee"
          dest: "#{buildDir}/static/js/awgl-concat.coffee"
        ,
          expand: false
          src: "#{awglDir}/build/awgl.js.map"
          dest: "#{buildDir}/static/js/awgl.js.map"
        ,
          expand: false
          src: "#{awglDir}/build/awgl.js.map"
          dest: "#{devDir}/js/awgl.js.map"
        ,
          expand: false
          src: "#{awglDir}/build/awgl-concat.coffee"
          dest: "#{devDir}/js/awgl-concat.coffee"
        ]
      cdn:
        files: [
          expand: true
          cwd: docDir
          src: [ "**" ]
          dest: "#{cdnDir}/doc"
        ,
          src: "#{buildDir}/ajs-prod.min.js"
          dest: "#{cdnDir}/ajs.js"
        ,
          src: "#{buildDir}/ajs-prod-full.min.js"
          dest: "#{cdnDir}/ajs-full.js"
        ]

    clean: [
      buildDir
      docDir
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

  grunt.registerTask "codo", "build html documentation", ->
    done = this.async()
    require("child_process").exec "codo", (err, stdout) ->
      grunt.log.write stdout
      done err

  # Perform a full build
  grunt.registerTask "default", ["concat_in_order", "coffee"]
  grunt.registerTask "full", ["clean", "codo", "copy:test_page", "concat_in_order", "coffee", "mocha"]
  grunt.registerTask "dev", ["connect", "copy:test_page", "watch"]
  grunt.registerTask "deploy", [ "concat", "uglify" ]
  grunt.registerTask "cdn", [ "full", "deploy", "copy:cdn" ]