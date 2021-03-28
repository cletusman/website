var webpack = require('webpack')
var path    = require('path')
var MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
  mode: 'production',

  entry: [
    path.resolve(__dirname, 'assets/javascripts/site.js'),
    path.resolve(__dirname, 'assets/stylesheets/site.scss'),
  ],

  resolve: {
    modules: [
      path.resolve(__dirname, 'assets/javascripts'),
      path.resolve(__dirname, 'node_modules'),
    ],
  },

  output: {
    path: path.resolve(__dirname, 'tmp/webpack'),
    filename: 'assets/javascripts/site.js',
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: 'assets/stylesheets/site.css',
    }),
  ],

  module: {
    rules: [
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader',
        ],
      },
      {
        test: /\.(eot|svg|ttf|woff2?)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              outputPath: 'assets/fonts',
              publicPath: '../fonts',
            },
          },
        ],
      },
    ],
  },
}
