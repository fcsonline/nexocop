# frozen_string_literal: true

RSpec.describe Nexocop::Git do
  context 'filenames' do
    it 'identifies filename lines' do
      expect(Nexocop::Git.filename?('+++ b/Gemfile.d/app.rb')).to be_truthy
      expect(Nexocop::Git.filename?('@@ -81,0 +78,33 @@')).to be_falsey
    end

    it 'parses the filenames' do
      expect(Nexocop::Git.parse_filename('+++ b/Gemfile.d/app.rb')).to eq('Gemfile.d/app.rb')
      expect(Nexocop::Git.parse_filename('+++ b/some/nested/dir/file.rb')).to eq('some/nested/dir/file.rb')
    end
  end

  context 'line numbers' do
    it 'identifies line number lines' do
      expect(Nexocop::Git.count_line?('@@ -81,0 +78,33 @@')).to be_truthy
      expect(Nexocop::Git.count_line?('-81,0 +78,33@')).to be_falsey
    end

    it 'extracts the line numbers' do
      expect(Nexocop::Git.parse_count_line('@@ -20 +20 @@')).to eq([20, 20])
      expect(Nexocop::Git.parse_count_line('@@ -49,5 +49 @@ elsif RUBY_VERSION >= "2.3" && RUBY_VERSION < "2.4"')).to eq([49, 49])
      expect(Nexocop::Git.parse_count_line('@@ -81,0 +78,33 @@')).to eq([78, 111])
    end
  end

  context 'changed lines' do
    let(:git_diff) do
      <<~EOF
        diff --git a/Dockerfile b/Dockerfile
        index 8fe9210a6..3ea84a67c 100644
        --- a/Dockerfile
        +++ b/Dockerfile
        @@ -12 +12 @@ RUN addgroup --gid 1000 docker \
        -# Update all packages and install some common dependencies
        +# Update/upgrade all packages and install some common dependencies
        @@ -14,0 +15 @@ RUN apt-get update \
        + && apt-get upgrade -y \
        diff --git a/docker-compose.yml b/docker-compose.yml
        index f581313c6..2e7fdafa3 100644
        --- a/docker-compose.yml
        +++ b/docker-compose.yml
        @@ -24 +24 @@ services:
        -    image: mysql:5.7
        +    image: mysql:5.6
        @@ -53,39 +52,0 @@ services:
        -#  zookeeper:
        -#    image: wurstmeister/zookeeper
        -#    ports:
        -#      - "2181:2181"
        -#
        -#  kafka:
        -#    image: wurstmeister/kafka
        -#    ports:
        diff --git a/bin/nexocop b/bin/nexocop
        index 4cbb448..251e0c0 100755
        --- a/bin/nexocop
        +++ b/bin/nexocop
        @@ -1,4 +1,30 @@
         #!/usr/bin/env ruby

        -json_formatter_outfile, rubocop_args = Nexocop.parse_args(ARGV)
        +require 'rainbow'
        +
        +module Nexocop
        +  def self.rubocop_cmd
        +    if Sh.run_command('which bundle >/dev/null 2>&1').success?
        +      "bundle exec rubocop"
        +    elsif Sh.run_command('which rubocop >/dev/null 2>&1').success?
        +      "rubocop"
      EOF
    end

    it 'gets files and changed lines as expected' do
      expect(Nexocop::Git.changed_lines(git_diff)).to eq(
        'Dockerfile' => [[12, 12], [15, 15]],
        'docker-compose.yml' => [[24, 24], [52, 52]],
        'bin/nexocop' => [[1, 31]]
      )
    end

    it 'handles no changes as expected' do
      expect(Nexocop::Git.changed_lines('')).to eq({})
    end
  end
end
