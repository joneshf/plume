module.exports = (grunt) ->
  'use strict'

  # Configuration
  # =============
  grunt.initConfig

    # Cleanup
    # -------
    clean:
      all: [
        "lib"
      ]

    # LiveScript
    # ----------
    livescript:
      compile:
        files: [
          expand: true
          filter: 'isFile'
          cwd: "src"
          dest: "lib"
          src: '**/*.ls'
          ext: '.js'
        ]

        options:
          bare: true

  # Dependencies
  # ============
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # Tasks
  # =====

  # Prepare
  # -------
  grunt.registerTask 'prepare', [
    'clean'
  ]

  # Build
  # -----
  grunt.registerTask 'build', [
    'livescript'
  ]

  # Default
  # -------
  grunt.registerTask 'default', [
    'clean',
    'build'
  ]
