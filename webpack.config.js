var webpack = require('webpack')
var path    = require('path')

module.exports = {
  mode: 'production',

  entry: {
    site: path.resolve(__dirname, 'assets/javascripts/site.js'),
  },

  resolve: {
    modules: [
      path.resolve(__dirname, 'assets/javascripts'),
      path.resolve(__dirname, 'node_modules'),
    ],
  },

  output: {
    path: path.resolve(__dirname, 'tmp/webpack'),
    filename: 'assets/javascripts/[name].js',
  },
}
