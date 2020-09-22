// Karma configuration

// TODO: Use the same Chrome bin as the Ruby specs
process.env.CHROME_BIN = require('puppeteer').executablePath()

module.exports = function (config) {
  config.set({

    // frameworks to use
    frameworks: ['esm', 'mocha', 'chai'],

    // list of files / patterns to load in the browser
    files: [
      { pattern: 'javascript/parseBindings.js', type: 'module' },
      { pattern: 'spec/javascript/**/*.js', type: 'module' }
    ],

    plugins: [
      require.resolve('@open-wc/karma-esm'),

      // fallback: resolve any karma- plugins
      'karma-*'
    ],

    // preprocess matching files before serving them to the browser
    preprocessors: {
      'javascript/parseBindings.js': ['coverage']
    },

    // test results reporter to use
    reporters: ['dots', 'coverage'],

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,

    // start these browsers
    browsers: ['ChromeHeadless'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true,

    esm: {
      nodeResolve: true,
      coverage: true
    }
  })
}
