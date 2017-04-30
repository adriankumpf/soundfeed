exports.config = {
  files: {
    javascripts: {
      joinTo: 'js/app.js'
      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/master/docs/config.md#files
      // joinTo: {
      //  "js/app.js": /^(js)/,
      //  "js/vendor.js": /^(vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      // order: {
      //   before: [
      //     "vendor/js/jquery-2.1.1.js",
      //     "vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: 'css/app.css'
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  paths: {
    watched: ['static', 'css', 'js', 'vendor'],
    public: '../priv/static'
  },

  plugins: {
    babel: {
      ignore: [/vendor/]
    },
    cleancss: {
      ignored: false
    }
  },

  modules: {
    wrapper: false,
    definition: false
  },

  npm: {
    enabled: false
  }

  // if npm modules are needed:

  // modules: {
  //   autoRequire: {
  //     'js/app.js': ['js/app']
  //   }
  // },
  //
  // npm: {
  //   enabled: true
  // }

}
