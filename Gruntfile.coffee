module.exports = (grunt) ->
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'
    i18n:
      src: ['l10n-templates/**/*']
      options:
        locales: 'translations/*.yaml'
        output: '.tmp/l10n'
        base: 'l10n-templates'

    useminPrepare:
      html: 'l10n-templates/**/*.html'
      options:
        root: 'app'
        dest: 'dist'

    usemin:
      html: '.tmp/l10n/**/*.html'

    watch:
      i18n:
        files: ['l10n-templates/**/*', 'translations/**/*']
        tasks: ['i18n', 'copy:i18nWatch']

      livescript:
        files: ['app/**/*.ls']
        tasks: ['livescript', 'commonjs', 'copy:jsWatch']

    connect:
      server:
        options:
          base: ['app/bower_components', '.tmp/dist']

    livescript:
      options:
        bare: true

      compile:
        expand: true
        cwd: 'app'
        src: [ '**/*.ls' ]
        dest: '.tmp/lsc'
        ext: '.js'

    commonjs:
      modules:
        cwd: '.tmp/lsc/scripts'
        src: [ '**/*.js' ]
        dest: '.tmp/commonjs/'

    copy:
      l10nMain:
        expand: true
        cwd: '.tmp/l10n'
        src: ['**/*']
        dest: 'dist'

      l10nDefault:
        expand: true
        cwd: '.tmp/l10n/en'
        src: ['**/*']
        dest: 'dist'

      jsWatch:
        expand: true
        cwd: '.tmp/commonjs'
        src: ['**/*']
        dest: '.tmp/dist/scripts'

      i18nWatch:
        expand: true
        cwd: '.tmp/l10n/'
        src: ['**/*']
        dest: '.tmp/dist'

    clean:
      build: ['.tmp', 'dist']
      tmp: ['.tmp']
  }

  grunt.registerTask 'prepare', ['clean:build', 'useminPrepare']
  grunt.registerTask 'compile', ['i18n', 'livescript', 'commonjs']
  grunt.registerTask 'optimize', ['usemin', 'concat', 'uglify', 'copy:l10nMain', 'copy:l10nDefault']
  grunt.registerTask 'default', ['prepare', 'compile', 'optimize']

  grunt.registerTask 'server', ['clean:tmp', 'i18n', 'copy:i18nWatch', 'livescript', 'commonjs', 'copy:jsWatch', 'connect:server', 'watch']

  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-livescript'
  grunt.loadNpmTasks 'grunt-commonjs'
  grunt.loadNpmTasks 'grunt-usemin'
  grunt.loadNpmTasks 'grunt-i18n'
