import { defineConfig } from '@rsbuild/core';

export default defineConfig({
  tools: {
    webpack: {
      modules: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          use: {
            loader: 'elm-webpack-loader',
            options: {
              optimize: process.env.NODE_ENV === 'production',
              debug: process.env.NODE_ENV !== 'production'
            }
          }
        }
      ]
    }
  },
  source: {
    entry: {
      index: './src/index.ts'
    }
  },
  html: {
    template: './src/index.html'
  }
});
