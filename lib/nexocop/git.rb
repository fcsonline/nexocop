# frozen_string_literal: true

require 'rubocop'
require 'ostruct'

module Nexocop
  module Git
    # Get an array of line numbers that have been changed
    #
    # For example, you will get a structure that looks like this:
    #
    # {
    #     'Dockerfile' => [[12, 12], [15, 15]],
    #     'docker-compose.yml' => [[24, 24], [52, 52]],
    #     'bin/nexocop' => [[1, 31]]
    # }
    #
    def self.changed_lines(git_diff = nil)
      git_diff ||= Sh.run_command('git diff --unified=0 origin/master').stdout
      lines = {}
      cur_file = ''
      git_diff.split("\n").each do |line|
        # look for filenames and update cur_file, or for count lines
        if filename?(line)
          cur_file = parse_filename(line)
        elsif count_line?(line)
          lines[cur_file] ||= []
          lines[cur_file].push(parse_count_line(line))
        end
      end
      lines
    end

    def self.filename?(line)
      line.start_with?('+++ b/')
    end

    def self.parse_filename(line)
      line.gsub(%r{^\+\+\+\sb/}, '')
    end

    def self.count_line?(line)
      line =~ /@@.*@@/
    end

    #
    # Extract line numbers from this, return array of length 2 with
    # beginning line num and ending line num respectively
    #
    def self.parse_count_line(line)
      pos_block = line.split('@@')[1].strip.split('+')[1].split(',').map(&:to_i)
      if pos_block.count == 1
        [pos_block[0], pos_block[0]]
      else
        [pos_block[0], pos_block[0] + pos_block[1]]
      end
    end
  end
end
