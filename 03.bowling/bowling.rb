#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',').map { |n| n == 'X' ? 10 : n.to_i }

# 合計点がわかればいいので、フレームごとに区切らず、自点を加算する方針
bowl_count = 0

game_result = 10.times.sum do
  if scores[bowl_count] == 10 # strike
    frame_result = scores[bowl_count, 3].sum
    bowl_count += 1
  elsif scores[bowl_count, 2].sum == 10 # spare
    frame_result = scores[bowl_count, 3].sum
    bowl_count += 2
  else
    frame_result = scores[bowl_count, 2].sum
    bowl_count += 2
  end
  frame_result
end

puts game_result
