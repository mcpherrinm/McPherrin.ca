#!/bin/sh

exec docker run --rm -it --init \
  -v "$PWD":/site -w /site \
  -v mcpherrin-ca-gems:/usr/local/bundle \
  -p 4000:4000 \
  ruby:3.3 sh -c 'bundle install && exec bundle exec jekyll serve --host 0.0.0.0'
