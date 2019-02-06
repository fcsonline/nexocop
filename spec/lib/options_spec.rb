# frozen_string_literal: true

RSpec.describe Nexocop::Options do
  it 'extracts the json output file' do
    input_args = %w[
      --format json -o ncop.json --format html -o nexocop.html
    ]
    parsed_args = Nexocop::Options.parse_args(input_args)
    expect(parsed_args.json_outfile).to eq('ncop.json')
    expect(parsed_args.rubocop_args[0..7]).to eq(input_args)
  end

  it 'defaults and adds the json output file if its not specified' do
    parsed_args = Nexocop::Options.parse_args([])
    expect(parsed_args.json_outfile).to eq(Nexocop::Options.default_json_file)
    expect(parsed_args.rubocop_args[0..3]).to eq(
      %w[--format json -o].push(Nexocop::Options.default_json_file)
    )
  end

  context 'changed files' do
    let(:changed_files) { %w[file1 file2 file3] }

    before(:each) do
      allow(Nexocop::Sh).to receive(:run_command) do
        OpenStruct.new(
          success?: true,
          exitstatus: 0,
          stdout: changed_files.join("\n")
        )
      end
    end

    it 'passes a list of changed files' do
      input_args = %w[
        --format json -o ncop.json --format html -o nexocop.html
      ]
      parsed_args = Nexocop::Options.parse_args(input_args)
      expect(parsed_args.json_outfile).to eq('ncop.json')
      expect(parsed_args.rubocop_args).to eq(input_args.dup.concat(Nexocop::Git.changed_files))
    end
  end
end
