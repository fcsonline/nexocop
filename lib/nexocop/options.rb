# frozen_string_literal: true

require 'rubocop'
require 'ostruct'

module Nexocop
  module Options
    def self.default_json_file
      'nexocop.json'
    end

    def self.parse_args(args)
      # We need to know where the json file will be.  If one isn't specified,
      # set it explicitly so that we know it is there

      # Use Rubocop's parser so we stay synced
      options, _paths = RuboCop::Options.new.parse(args)
      rubocop_args = args.dup
      json_outfile = nil

      if options[:formatters] && options[:formatters].count { |f| f[0]['json'] } == 1
        json_outfile = options[:formatters].select { |f| f[0]['json'] }[0][1]
      else
        options[:formatters] = [] unless options[:formatters]
        json_outfile = default_json_file
        rubocop_args.push(%w[--format json -o].push(default_json_file)).flatten!
      end

      # Filter files that haven't changed at all so rubocop doesn't waste time
      # checking them when we are going to throw them away anyway
      rubocop_args.concat(Git::changed_files)

      OpenStruct.new(
        json_outfile: json_outfile,
        rubocop_args: rubocop_args
      )
    end
  end
end
