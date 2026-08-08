#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'debug'
require 'etc'
require 'optparse'
require 'pathname'

COLUMN_SIZE = 3

def parse_options(argv = ARGV)
  params = {
    all: false,
    reverse: false,
    list: false
  }
  OptionParser.new do |opt|
    opt.on('-a') { params[:all] = true }
    opt.on('-r') { params[:reverse] = true }
    opt.on('-l') { params[:long] = true }
  end.parse!(argv)
  params
end

def files_in(directory: '.', show_dotfile: false)
  dir = Pathname.new(directory)
  flags = show_dotfile ? File::FNM_DOTMATCH : 0
  dir.glob('*', flags).map(&:to_path).sort
end

def to_filename_matrix(files:, slice_number:, filler: '')
  fixed_slice_length = files.size.ceildiv(slice_number)
  if fixed_slice_length <= 0
    [[]]
  else
    files.each_slice(fixed_slice_length).map { it.fill(filler, it.size...fixed_slice_length) }
  end
end

def convert_filetype(stat)
  case stat.ftype
  when 'fifo' then 'p'
  when 'characterSpecial' then 'c'
  when 'directory' then 'd'
  when 'blockSpecial' then 'b'
  when 'file' then '-'
  when 'link' then 'l'
  when 'socket' then 's'
  else '?'
  end
end

def format_permission(stat)
  file_mode = stat.mode
  permissions = file_mode & 0o777

  # 3bitずつ取り出す
  permissions_str = ''
  3.times do |i|
    bits = (permissions >> 6 - (i * 3))
    permissions_str += ((bits & 4).positive? ? 'r' : '-') + ((bits & 2).positive? ? 'w' : '-') + ((bits & 1).positive? ? 'x' : '-')
  end

  if stat.setuid?
    permissions_str[2] = permissions_str[2] == 'x' ? 's' : 'S'
  elsif stat.setgid?
    permissions_str[5] = permissions_str[5] == 'x' ? 's' : 'S'
  elsif stat.sticky?
    permissions_str[8] = permissions_str[8] == 'x' ? 't' : 'T'
  end

  permissions_str
end

options = parse_options

file_list = files_in(show_dotfile: options[:all])
ordered_files = options[:reverse] ? file_list.reverse : file_list

if options[:long]
  result = []
  total_blocksize = 0
  ordered_files.each do |f|
    stat = File.stat(f)
    file_permission = convert_filetype(stat) + format_permission(stat)
    last_update = stat.mtime.strftime('%b %e ')
    # 6ヶ月以上前の場合は時刻の代わりに西暦をつける
    last_update_time = last_update + ((stat.mtime.to_date < (Date.today << 6) ? stat.mtime.year.to_s.rjust(5) : stat.mtime.strftime('%H:%M')))
    result.push([file_permission, stat.nlink, Etc.getpwuid(stat.uid).name, Etc.getgrgid(stat.gid).name, stat.size, last_update_time, f])
    total_blocksize += stat.blocks
  end

  transposed_result = result.transpose
  longest_link_count = transposed_result[1].max.to_s.size
  longest_ownername_size = transposed_result[2].max.size
  longest_groupname_size = transposed_result[3].max.size
  biggest_filesize = transposed_result[4].max.to_s.size

  puts "total #{total_blocksize}"
  result.map do |row|
    puts [
      row[0],
      row[1].to_s.rjust(longest_link_count),
      row[2].ljust(longest_ownername_size),
      row[3].ljust(longest_groupname_size),
      row[4].to_s.rjust(biggest_filesize),
      row[5..6]
    ].join(' ')
  end

else
  files_table = to_filename_matrix(files: ordered_files, slice_number: COLUMN_SIZE)

  display_table = files_table.transpose

  # 各列のファイル名の最長の長さに合わせて各行の文字列をブランクでpaddingする
  column_width = files_table.map { it.map(&:length).max }

  display_table.each do |row|
    puts row.map.with_index { |r, idx| r.ljust(column_width[idx]) }.join("\t")
  end
end
