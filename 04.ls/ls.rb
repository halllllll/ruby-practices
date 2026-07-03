#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

COL = 3

files = Pathname.new('.').each_entry.map(&:to_path).sort.filter { it.match(/^(?!\..*)/) }

def create_smoose_table(arr, slice_number, filler = '')
  q, r = arr.size.divmod(slice_number)
  fixed_slice_length = q + (r.zero? ? 0 : 1)
  arr.each_slice(fixed_slice_length).map { it.fill(filler, it.size...fixed_slice_length) }
end

files_table = create_smoose_table(files, COL)

display_table = files_table.transpose

# 各列でファイル名の最長の長さに合わせて各行の文字列をブランクでpaddingする
column_width = files_table.map { it.map(&:length).max }

display_table.each do |row|
  puts row.map.with_index { |r, idx| r.ljust(column_width[idx]) }.join('\t')
end
