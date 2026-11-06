#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

unless ARGV.length == 2
  warn "Usage: ruby scripts/filter_embedded_data.rb PATH EXAM_SESSION"
  exit 1
end

path, exam_session = ARGV
source = File.read(path)
data_pattern = %r{/\*__DATA_START__\*/\s*const DATA = (.*?);\s*/\*__DATA_END__\*/}m
match = source.match(data_pattern)
abort "Embedded DATA block not found in #{path}" unless match

data = JSON.parse(match[1])
questions = data.fetch("questions").select { |question| question["year"] == exam_session }
ids = questions.map { |question| question.fetch("id") }

abort "No questions found for #{exam_session} in #{path}" if questions.empty?

%w[matches evidence].each do |collection|
  data[collection] = data.fetch(collection).select { |item| ids.include?(item.fetch("id")) }
  actual_ids = data[collection].map { |item| item.fetch("id") }
  next if actual_ids.sort == ids.sort

  abort "#{collection} does not exactly match the filtered question IDs in #{path}"
end

data["questions"] = questions
replacement = "/*__DATA_START__*/\nconst DATA = #{JSON.pretty_generate(data)};\n/*__DATA_END__*/"
File.write(path, source.sub(data_pattern, replacement))
puts "Filtered #{File.basename(path)}: #{questions.length} questions for #{exam_session}"
