# frozen_string_literal: true

RSpec.describe Nexocop::Rubocop do
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

  context '#offense_in_diff?' do
    let(:singleline_offense1) do
      JSON.parse(<<~EOF)
        {
          "path": "lib/nexocop/file.rb",
          "severity": "convention",
          "message": "Style/Encoding: Unnecessary utf-8 encoding comment.",
          "cop_name": "Style/Encoding",
          "corrected": false,
          "location": {
            "start_line": 1,
            "start_column": 1,
            "last_line": 1,
            "last_column": 15,
            "length": 15,
            "line": 1,
            "column": 1
          }
        }
      EOF
    end

    # slo1 == singleline_offense1
    let(:slo1_in_diff) do
      {
        'lib/nexocop/file.rb' => [[1, 1], [15, 15]]
      }
    end

    let(:slo1_not_in_diff1) do
      {
        'lib/nexocop/file.rb' => [[15, 15]]
      }
    end

    let(:slo1_not_in_diff2) do
      # line numbers match, but file name doesn't
      {
        'lib/nexocop/wrongfile.rb' => [[1, 1], [15, 15]]
      }
    end

    let(:singleline_offense2) do
      JSON.parse(<<~EOF)
        {
          "path": "lib/nexocop/file.rb",
          "severity": "convention",
          "message": "Layout/EmptyLineAfterMagicComment: Add an empty line after magic comments.",
          "cop_name": "Layout/EmptyLineAfterMagicComment",
          "corrected": false,
          "location": {
            "start_line": 2,
            "start_column": 1,
            "last_line": 2,
            "last_column": 1,
            "length": 1,
            "line": 2,
            "column": 1
          }
        }
      EOF
    end

    # slo2 == singleline_offense1
    let(:slo2_in_diff) do
      {
        'lib/nexocop/file.rb' => [[1, 5]]
      }
    end

    let(:slo2_not_in_diff) do
      {
        'lib/nexocop/file.rb' => [[5, 9]]
      }
    end

    let(:multiline_offense) do
      JSON.parse(<<~EOF)
        {
          "path": "lib/nexocop/file.rb",
          "severity": "convention",
          "message": "Metrics/MethodLength: Method has too many lines. [12/10]",
          "cop_name": "Metrics/MethodLength",
          "corrected": false,
          "location": {
            "start_line": 17,
            "start_column": 3,
            "last_line": 34,
            "last_column": 5,
            "length": 559,
            "line": 17,
            "column": 3
          }
        }
      EOF
    end

    # mlo == multiline_offense
    let(:mlo_in_diff1) do
      # simulates adding to beginning of method
      {
        'lib/nexocop/file.rb' => [[1, 19]]
      }
    end

    let(:mlo_in_diff2) do
      # Simulates adding to middle of the method
      {
        'lib/nexocop/file.rb' => [[19, 24]]
      }
    end

    let(:mlo_in_diff3) do
      # Last part of method is new (simulates method being added to)
      {
        'lib/nexocop/file.rb' => [[24, 45]]
      }
    end

    let(:mlo_in_diff4) do
      # Entire methed is new
      {
        'lib/nexocop/file.rb' => [[1, 45]]
      }
    end

    let(:mlo_not_in_diff) do
      # Entire methed is new
      {
        'lib/nexocop/file.rb' => [[45, 90]]
      }
    end

    it 'correctly tells if an offense is part of the diff' do
      #
      # Checks for various ranges of line numberse in same file,
      # and makes sure that line numbers from different files don't erroneously match
      #
      expect(Nexocop::Rubocop.offense_in_diff?(singleline_offense1, slo1_in_diff)).to be_truthy
      expect(Nexocop::Rubocop.offense_in_diff?(singleline_offense2, slo2_in_diff)).to be_truthy
      expect(Nexocop::Rubocop.offense_in_diff?(multiline_offense, mlo_in_diff1)).to be_truthy
      expect(Nexocop::Rubocop.offense_in_diff?(multiline_offense, mlo_in_diff2)).to be_truthy
      expect(Nexocop::Rubocop.offense_in_diff?(multiline_offense, mlo_in_diff3)).to be_truthy
      expect(Nexocop::Rubocop.offense_in_diff?(multiline_offense, mlo_in_diff4)).to be_truthy

      expect(Nexocop::Rubocop.offense_in_diff?(singleline_offense1, slo1_not_in_diff1)).to be_falsey
      expect(Nexocop::Rubocop.offense_in_diff?(singleline_offense1, slo1_not_in_diff2)).to be_falsey
      expect(Nexocop::Rubocop.offense_in_diff?(singleline_offense2, slo2_not_in_diff)).to be_falsey
      expect(Nexocop::Rubocop.offense_in_diff?(multiline_offense, mlo_not_in_diff)).to be_falsey
    end
  end

  context '#has_offenses?' do
    it 'correctly knows if there are offenses in json' do
      expect(Nexocop::Rubocop.has_offenses?(
        'files' => [
          {
            'offenses' => [{}, {}]
          },
          {
            'offenses' => [{}, {}]
          }
        ]
      )).to be_truthy
      expect(Nexocop::Rubocop.has_offenses?(
        'files' => [{
          'offenses' => [{}, {}]
        }]
      )).to be_truthy
    end

    it 'correctly knows if there are no offenses in the json' do
      expect(Nexocop::Rubocop.has_offenses?(
        'files' => [{
          'offenses' => []
        }]
      )).to be_falsey
    end
  end

  context '#count_offenses' do
    it 'counts the number of offenses correctly' do
      expect(Nexocop::Rubocop.count_offenses(
        'files' => [
          {
            'offenses' => [{}, {}]
          },
          {
            'offenses' => [{}]
          }
        ]
      )).to eq(3)
    end
  end
end
