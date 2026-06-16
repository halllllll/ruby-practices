#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',').map { |n| n == 'X' ? 10 : n.to_i }

# 合計点がわかればいいので、フレームごとに区切らず、自点を加算する方針
scores_result = scores.sum
frame_count = 0
bowl_count = 0

while frame_count < 9
  if scores[bowl_count] == 10 # strike
    scores_result += scores[bowl_count + 1]
    scores_result += scores[bowl_count + 2]
    bowl_count += 1
  elsif scores[bowl_count] + scores[bowl_count + 1] == 10 # spare
    scores_result += scores[bowl_count + 2]
    bowl_count += 2
  else
    bowl_count += 2
  end
  frame_count += 1
end

puts scores_result
