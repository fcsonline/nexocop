# frozen_string_literal: true

RSpec.describe Nexocop::Options do
  it 'extracts the json output file' do
    input_args = %w[
      --format json -o ncop.json --format html -o nexocop.html
    ]
    parsed_args = Nexocop::Options.parse_args(input_args)
    expect(parsed_args.json_outfile).to eq('ncop.json')
    expect(parsed_args.rubocop_args).to eq(input_args)
  end

  it 'defaults and adds the json output file if its not specified' do
    parsed_args = Nexocop::Options.parse_args([])
    expect(parsed_args.json_outfile).to eq(Nexocop::Options.default_json_file)
    expect(parsed_args.rubocop_args).to eq(
      %w[--format json -o].push(Nexocop::Options.default_json_file)
    )
  end
end
