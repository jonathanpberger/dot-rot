#!/usr/bin/env ruby

require 'yaml'

class GemspecGetter
  def initialize(name=nil)
    raise ArgumentError, "You must pass a name" unless name
    @name = name
  end
  
  def gemspec
    File.read(matches.last)
  end
  
  private
  
  def matches
    env['GEM PATHS'].inject([]) do |res, path|
      specs = Dir[File.join(path, 'specifications', '*.gemspec')]
      specs.reject! { |filename| ! filename.include?(@name) } if @name
      res + specs
    end
  end
  
  def env
    @env ||= begin
      config = YAML.load(`gem env`)['RubyGems Environment']
      config = config.inject({}) { |res, val| res.merge(val) }
  
      if config['RUBYGEMS VERSION'] != '1.3.1'
        puts 'Rubygems version has changed.'
        puts 'This might not work.'
      end

      config
    end
  end
end

if __FILE__ == $0
  puts GemspecGetter.new(ARGV.first).gemspec
end