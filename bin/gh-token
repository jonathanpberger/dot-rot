#!/usr/bin/env ruby

# Keep track of GitHub tokens in a .gh-tokens file.
#
# USAGE
#
# Setting a token:
#
#   $ gh-token nakajima SOME-GITHUB-TOKEN-HERE
#
# Getting a token:
#
#   $ gh-token nakajima
#
# Unsetting a token:
#
#   $ gh-token nakajima --unset
#
# Listing all tokens:
#
#   $ gh-token list
#
# TODO Real options
require 'yaml'

class GHToken
  def initialize(args)
    sym = case
    when args.empty?            then :list
    when args.delete('--unset') then :unset
    else args.length > 1 ? :set : :get
    end ; send(sym, *args)
  end

  def get(key)
    if token = store[key]
      puts token
    end
  end

  def set(key, val)
    store[key] = val and save(store)
    puts "set #{key} token to #{val}"
  end

  def unset(key)
    store.delete(key) and save(store)
    puts "unset #{key} token"
  end

  def list
    puts "GitHub Tokens:"
    store.each do |key, val|
      puts "- #{key}: #{val}"
    end
  end

  private

  def save(new_store)
    File.open(tokens, 'w+') do |file|
      YAML.dump(store, file)
    end
  end

  def store
    @store ||= YAML.load_file(tokens) || {}
  end

  def tokens
    File.join(ENV['HOME'], '.gh-tokens')
  end
end

GHToken.new(ARGV.dup)
