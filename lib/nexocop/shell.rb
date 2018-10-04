# frozen_string_literal: true

require 'ostruct'

module Nexocop
  module Sh
    def self.run_command(command)
      stdout = `#{command}`
      OpenStruct.new(
        success?: $?.exitstatus.zero?,
        exitstatus: $?.exitstatus,
        stdout: stdout
      )
    end
  end

  module Bash
    def self.escape_double_quotes(str)
      str.gsub('"', '\\"')
    end

    def self.run_command(command)
      stdout = `bash -c "#{escape_double_quotes(command)}"`
      OpenStruct.new(
        success?: $?.exitstatus.zero?,
        exitstatus: $?.exitstatus,
        stdout: stdout
      )
    end
  end
end
