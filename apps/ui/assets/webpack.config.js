const path = require("path");
const glob = require("glob");

const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = (env, options) => ({
  entry: {
    "./js/app.js": ["./js/app.js"]
  },
  output: {
    filename: "app.js",
    path: path.resolve(__dirname, "../priv/static/js")
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"]
      },
      {
        test: /\.styl(us)?/,
        use: [MiniCssExtractPlugin.loader, "css-loader", "stylus-loader"]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: "../css/app.css" }),
    new OptimizeCSSPlugin(),
    new CopyWebpackPlugin([{ from: "static/", to: "../" }])
  ]
});
