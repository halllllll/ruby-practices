#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

COLUMN_SIZE = 3

def get_files(dir: '*', show_dotfile: false)
  files = if show_dotfile
            Pathname.glob(dir, flags: File::FNM_DOTMATCH)
          else
            Pathname.glob(dir)
          end

  files.each_entry.map(&:to_path).sort
end

def create_smoose_table(arr:, slice_number:, filler: '')
  q, r = arr.size.divmod(slice_number)
  fixed_slice_length = q + (r.zero? ? 0 : 1)
  arr.each_slice(fixed_slice_length).map { it.fill(filler, it.size...fixed_slice_length) }
end

files = get_files

files_table = create_smoose_table(arr: files, slice_number: COLUMN_SIZE)

display_table = files_table.transpose

# 各列のファイル名の最長の長さに合わせて各行の文字列をブランクでpaddingする
column_width = files_table.map { it.map(&:length).max }

display_table.each do |row|
  puts row.map.with_index { |r, idx| r.ljust(column_width[idx]) }.join("\t")
end
