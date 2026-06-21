#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',').map { |n| n == 'X' ? 10 : n.to_i }

# 合計点がわかればいいので、配点を加算する方針
scores_result = 0
bowl_count = 0

10.times do
  if scores[bowl_count] == 10 # strike
    scores_result += scores[bowl_count, 3].sum
    bowl_count += 1
  elsif scores[bowl_count, 2].sum == 10 # spare
    scores_result += scores[bowl_count, 3].sum
    bowl_count += 2
  else
    scores_result += scores[bowl_count, 2].sum
    bowl_count += 2
  end
end

puts scores_result
