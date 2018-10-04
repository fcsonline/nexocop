# frozen_string_literal: true

require 'rubocop'
require 'ostruct'

module Nexocop
  module Rubocop
    def self.available?
      !rubocop_cmd.empty?
    end

    def self.rubocop_cmd
      if Sh.run_command('which bundle >/dev/null 2>&1').success?
        'bundle exec rubocop'
      elsif Sh.run_command('which rubocop >/dev/null 2>&1').success?
        'rubocop'
      else
        ''
      end
    end

    def self.run(rubocop_args)
      Sh.run_command("#{rubocop_cmd} #{rubocop_args.join(' ')}")
    end

    def self.offense_in_diff?(offense, changed_lines)
      # make sure this offense is in a file that has changed
      return false unless changed_lines.key?(offense['path'])

      changed_lines[offense['path']].any? do |line_range|
        start_line = offense['location']['start_line']
        last_line  = offense['location']['last_line']
        range = (line_range[0]..line_range[1])
        (start_line..last_line).to_a.any? { |line_num| range.include?(line_num) }
      end
    end

    def self.has_offenses?(rubocop_json)
      rubocop_json['files']
        .map { |file| file['offenses'] }
        .map(&:count)
        .any?(&:positive?)
    end

    def self.count_offenses(rubocop_json)
      rubocop_json['files']
        .map { |file| file['offenses'] }
        .map(&:count)
        .reduce(:+)
    end

    def self.count_files(rubocop_json)
      rubocop_json['files'].count
    end
  end
end
