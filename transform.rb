#!/usr/bin/env ruby

# frozen_string_literal: true

require 'csv'
require 'byebug'
require 'uri'

filename = ARGV[0] || 'input.csv'

@final_data = []

def find_row(url, verb)
  @final_data.find_index { |item| item[:url] == url && item[:verb] == verb }
end

def parse_url(url)
  parsed_url = URI.parse(url)
  parsed_url = parsed_url.request_uri.split('?')[0]
  parsed_url = parsed_url[0...-1] if parsed_url.to_s.chars.last == '/'
  parsed_url
rescue URI::InvalidURIError => e
  puts "#{url} => Invalid url #{e}"
  url
end

CSV.foreach(filename, headers: true) do |row|
  count = row['f0_'].to_i
  url = parse_url(row['request_url'])
  url = row['request_url'] if url.empty?
  verb = row['request_verb']

  final_data_idx = find_row(url, verb)

  if final_data_idx.nil?
    @final_data << { url: url, verb: verb, count: count }
  else
    @final_data[final_data_idx][:count] += count
  end
end

output = "#{filename.split('.csv')[0]}_out.csv"
CSV.open(output, "w") do |csv|
  csv << ["f0_", "request_path", "request_verb"]
  @final_data.each do |row|
    csv << [row[:count], row[:url], row[:verb]]
  end
end
