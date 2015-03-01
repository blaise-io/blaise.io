module.exports = (grunt) ->

    grunt.initConfig
        gcc_rest:
            dist:
                files:
                    'tmp/index.min.js': ['src/script/index.js']
                options:
                    params:
                        language: 'ECMASCRIPT5_STRICT',
                        compilation_level: 'ADVANCED_OPTIMIZATIONS',
                        warning_level: 'VERBOSE',
                        use_types_for_optimization: 'true'

        uglify:
            dist:
                files:
                    'tmp/index.min.js': ['tmp/index.min.js', 'src/script/analytics.js'],

        imageEmbed:
            dist:
                src: 'src/style/index.css'
                dest: 'tmp/index.min.css'
                options:
                    deleteAfterEncoding: false

        cssmin:
            combine:
                files:
                    'tmp/index.min.css': ['tmp/index.min.css']

        copy:
            main:
                files: [
                    src: ['index.html', 'favicon.ico', 'content/*']
                    dest: 'build/'
                ]

        'string-replace':
            inline:
                options:
                    replacements: [
                        pattern: '<script src="src/script/index.js"></script>'
                        replacement: '<script><%= grunt.file.read("tmp/index.min.js") %></script>'
                    ,
                        pattern: '<link rel="stylesheet" href="src/style/index.css">'
                        replacement: '<style><%= grunt.file.read("tmp/index.min.css") %></style>'
                    ]

                files:
                    'build/index.html': 'build/index.html'


    grunt.loadNpmTasks 'grunt-gcc-rest'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-cssmin'
    grunt.loadNpmTasks 'grunt-image-embed'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-string-replace'
    grunt.loadNpmTasks 'grunt-contrib-commands'

    grunt.registerTask 'default', ['gcc_rest', 'uglify', 'imageEmbed', 'cssmin', 'copy', 'string-replace']
