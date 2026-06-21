#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',').map { |n| n == 'X' ? 10 : n.to_i }

# 合計点がわかればいいので、フレームごとに区切らず、自点を加算する方針
scores_result = scores.sum
bowl_count = 0

9.times do
  if scores[bowl_count] == 10 # strike
    # 2投先まで加点
    scores_result += scores[bowl_count + 1, 2].sum
    bowl_count += 1
  elsif scores[bowl_count] + scores[bowl_count + 1] == 10 # spare
    # 1投先までがスペアのセット。2投先が加点対象の投球
    scores_result += scores[bowl_count + 2]
    bowl_count += 2
  else
    bowl_count += 2
  end
end

puts scores_result
