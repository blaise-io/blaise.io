module.exports = (grunt) ->

    grunt.initConfig
        uglify:
            dist:
                files:
                    '/var/tmp/index.min.js': ['src/script/index.js']

        imageEmbed:
            dist:
                src: 'src/style/index.css'
                dest: '/var/tmp/index.min.css'
                options:
                    deleteAfterEncoding: false

        cssmin:
            combine:
                files:
                    '/var/tmp/index.min.css': ['/var/tmp/index.min.css']

        copy:
            main:
                files: [
                    src: ['index.html', 'favicon.ico', 'content/*', 'src/font/*']
                    dest: 'build/'
                ]

        'string-replace':
            inline:
                options:
                    replacements: [
                        pattern: '<script src="src/script/index.js"></script>'
                        replacement: '<script><%= grunt.file.read("/var/tmp/index.min.js") %></script>'
                    ,
                        pattern: '<link rel="stylesheet" href="src/style/index.css">'
                        replacement: '<style><%= grunt.file.read("/var/tmp/index.min.css") %></style>'
                    ]

                files:
                    'build/index.html': 'build/index.html'

    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-cssmin'
    grunt.loadNpmTasks 'grunt-image-embed'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-string-replace'
    grunt.registerTask 'default', ['uglify', 'imageEmbed', 'cssmin', 'copy', 'string-replace']