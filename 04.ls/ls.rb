#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
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
  ftype_table = {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's'
  }

  ftype_table[stat.ftype] || '?'
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
  permissions_str
end

def format_lastupdate(stat)
  last_update = stat.mtime.strftime('%b %e ')
  # 6ヶ月以上前の場合は時刻の代わりに西暦をつける
  six_months_ago = Date.today << 6
  last_update + ((stat.mtime.to_date < six_months_ago ? stat.mtime.year.to_s.rjust(5) : stat.mtime.strftime('%H:%M')))
end

options = parse_options

file_list = files_in(show_dotfile: options[:all])
ordered_files = options[:reverse] ? file_list.reverse : file_list

if options[:long]
  result = []
  total_blocksize = 0

  ordered_files.each do |file|
    stat = File.stat(file)
    permission = format_permission(stat)
    if stat.setuid?
      permission[2] = permission[2] == 'x' ? 's' : 'S'
    elsif stat.setgid?
      permission[5] = permission[5] == 'x' ? 's' : 'S'
    elsif stat.sticky?
      permission[8] = permission[8] == 'x' ? 't' : 'T'
    end

    file_permission = convert_filetype(stat) + permission
    last_update = format_lastupdate(stat)
    file_data = {
      permission: file_permission,
      link_count: stat.nlink,
      owner_name: Etc.getpwuid(stat.uid).name,
      group_name: Etc.getgrgid(stat.gid).name,
      size: stat.size,
      last_update: last_update,
      name: file
    }
    result.push(file_data)
    total_blocksize += stat.blocks
  end

  longest_link_count = result.map { |f| f[:link_count] }.max.to_s.size
  longest_ownername_size = result.map { |f| f[:owner_name] }.max.size
  longest_groupname_size = result.map { |f| f[:group_name] }.max.size
  biggest_filesize = result.map { |f| f[:size] }.max.to_s.size

  puts "total #{total_blocksize}"
  result.each do |file_data|
    puts [
      file_data[:permission],
      file_data[:link_count].to_s.rjust(longest_link_count),
      file_data[:owner_name].ljust(longest_ownername_size),
      file_data[:group_name].ljust(longest_groupname_size),
      file_data[:size].to_s.rjust(biggest_filesize),
      file_data[:last_update],
      file_data[:name]
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
