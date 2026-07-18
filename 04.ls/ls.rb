#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'

COLUMN_SIZE = 3

params = { all: false }

opt = OptionParser.new
opt.on('-a') { params[:all] = true }
opt.parse!(ARGV)

def get_files(directory: '.', show_dotfile: false)
  dir = Pathname.new(directory)
  flags = show_dotfile ? File::FNM_DOTMATCH : 0
  dir.glob('*', flags).each_entry.map(&:to_path).sort
end

def to_filename_matrix(files:, slice_number:, filler: '')
  fixed_slice_length = files.size.ceildiv(slice_number)
  if fixed_slice_length <= 0
    [[]]
  else
    files.each_slice(fixed_slice_length).map { it.fill(filler, it.size...fixed_slice_length) }
  end
end

files = get_files(show_dotfile: params[:all])

files_table = to_filename_matrix(files: files, slice_number: COLUMN_SIZE)

display_table = files_table.transpose

# 各列のファイル名の最長の長さに合わせて各行の文字列をブランクでpaddingする
column_width = files_table.map { it.map(&:length).max }

display_table.each do |row|
  puts row.map.with_index { |r, idx| r.ljust(column_width[idx]) }.join("\t")
end
