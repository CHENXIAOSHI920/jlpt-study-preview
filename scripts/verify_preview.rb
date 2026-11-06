#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

ROOT = File.expand_path("..", __dir__)
EXPECTED_SESSION = "2026.7"
EXPECTED_IDS = {
  "n1-q4" => (20..25).map { |number| format("2026-07-%02d", number) },
  "n2-q6" => (26..30).map { |number| "2026-7-#{number}" }
}.freeze

def assert(condition, message)
  raise message unless condition
end

def embedded_json(path, variable)
  source = File.read(path)
  pattern = %r{const #{Regexp.escape(variable)} = (.*?);\s*/\*__(?:DATA|QUESTIONS)_END__\*/}m
  match = source.match(pattern)
  assert(match, "Cannot find #{variable} in #{path}")
  JSON.parse(match[1])
end

EXPECTED_IDS.each do |tool, expected_ids|
  data = embedded_json(File.join(ROOT, tool, "index.html"), "DATA")
  questions = data.fetch("questions")
  actual_ids = questions.map { |question| question.fetch("id") }
  assert(questions.all? { |question| question.fetch("year") == EXPECTED_SESSION },
         "#{tool}: contains a question outside #{EXPECTED_SESSION}")
  assert(actual_ids.sort == expected_ids.sort, "#{tool}: unexpected question IDs #{actual_ids.inspect}")
  %w[matches evidence].each do |collection|
    related_ids = data.fetch(collection).map { |item| item.fetch("id") }
    assert(related_ids.sort == expected_ids.sort,
           "#{tool}: #{collection} does not match the preview question IDs")
  end
end

n1_q6 = embedded_json(File.join(ROOT, "n1-q6", "index.html"), "questions")
n1_q6_ids = n1_q6.map { |question| question.fetch("id") }
expected_q6_ids = (36..40).map { |number| format("2026-07-%d", number) }
assert(n1_q6_ids.sort == expected_q6_ids.sort,
       "n1-q6: expected five questions 36-40, got #{n1_q6_ids.inspect}")
assert(n1_q6.all? { |question| question.fetch("session") == EXPECTED_SESSION },
       "n1-q6: contains a question outside #{EXPECTED_SESSION}")

homepage = File.read(File.join(ROOT, "index.html"))
%w[n1-q4 n1-q6 n2-q6].each do |tool|
  assert(homepage.include?(%(href="./#{tool}/index.html")), "Homepage is missing #{tool}")
  tool_source = File.read(File.join(ROOT, tool, "index.html"))
  assert(tool_source.include?(%(href="../index.html")), "#{tool} is missing its return link")
  assert(tool_source.include?("主页个人服务即可购买"), "#{tool} is missing the purchase note")
  assert(tool_source.include?('class="tool-nav"'), "#{tool} is missing the navigation group")
end
assert(!Dir.exist?(File.join(ROOT, "abab")), "ABAB must not be included")
assert(homepage.include?('class="level-section level-section--n1"'), "Homepage is missing the N1 section")
assert(homepage.include?('class="level-section level-section--n2"'), "Homepage is missing the N2 section")
assert(homepage.include?('class="creator-bear-card"'), "Homepage is missing the creator card")
assert(!homepage.include?('class="topbar"'), "Homepage must not restore the old topbar")
assert(!homepage.include?('class="hero__note"'), "Homepage must not restore the old hero note")
assert(!homepage.include?('class="hero__lead"'), "Homepage must not restore the old hero lead")
assert(!homepage.include?('class="principles"'), "Homepage must not restore the old boundary section")

manifest = JSON.parse(File.read(File.join(ROOT, "site-manifest.json")))
assert(manifest.fetch("site").fetch("examSession") == EXPECTED_SESSION, "Manifest session is stale")
assert(manifest.fetch("tools").map { |tool| tool.fetch("id") }.sort == %w[n1-q4 n1-q6 n2-q6],
       "Manifest tool list is incomplete or unexpected")

required_files = %w[
  index.html
  README.md
  AGENTS.md
  COPYRIGHT.md
  site-manifest.json
  .nojekyll
  .github/workflows/pages.yml
  assets/bear-author.jpg
  n1-q4/index.html
  n1-q4/sw.js
  n1-q4/manifest.webmanifest
  n1-q6/index.html
  n2-q6/index.html
  n2-q6/sw.js
  n2-q6/manifest.webmanifest
  n2-q6/update.html
]
required_files.each do |relative_path|
  assert(File.file?(File.join(ROOT, relative_path)), "Missing required file: #{relative_path}")
end

n1_q4 = File.read(File.join(ROOT, "n1-q4", "index.html"))
n2_q6 = File.read(File.join(ROOT, "n2-q6", "index.html"))
n1_q6_source = File.read(File.join(ROOT, "n1-q6", "index.html"))
n1_q4_sw = File.read(File.join(ROOT, "n1-q4", "sw.js"))
n2_q6_sw = File.read(File.join(ROOT, "n2-q6", "sw.js"))

assert(n1_q4.include?("jlpt-preview-n1-q4-2026-7-v1"), "N1 Q4 storage key is not isolated")
assert(n2_q6.include?("jlpt-preview-n2-q6-2026-7-v1"), "N2 Q6 storage key is not isolated")
assert(n1_q6_source.include?("jlpt-study-preview-n1-q6-2026-7-v1"), "N1 Q6 storage key is not isolated")
assert(n1_q4_sw.include?("jlpt-preview-n1-q4-2026-7-v4"), "N1 Q4 cache is stale")
assert(n2_q6_sw.include?("jlpt-preview-n2-q6-2026-7-v4"), "N2 Q6 cache is stale")

puts "PASS: 2026.7 preview contains N1 Q4 6 questions, N1 Q6 5 questions, and N2 Q6 5 questions."
