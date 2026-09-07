#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'pathname'

class Wordcount
  attr_accessor :lines, :words, :characters

  def initialize(text, name = '')
    @lines = text.split(/\R/).count
    @words = text.split(/\s+/).count
    @characters = text.bytesize
    @displayname = name
  end

  def format_row(flags)
    values = { line: @lines, word: @words, character: @characters }

    counts = values.map do |key, val|
      next '' unless flags[key]

      val.to_s.rjust([8, val.to_s.size + 1].max)
    end

    "#{counts.join} #{@displayname}"
  end
end

def parse_options(argv = ARGV)
  params = {
    line: false,
    word: false,
    character: false
  }
  OptionParser.new do |opt|
    opt.on('-l') { params[:line] = true }
    opt.on('-w') { params[:word] = true }
    opt.on('-c') { params[:character] = true }
  end.parse!(argv)

  params.each_key { |k| params[k] = true } if params.values.all? { |v| v == false }

  { params: params, files: ARGV }
end

options = parse_options

if options[:files].empty?
  wc = Wordcount.new($stdin.read)
  puts wc.format_row(options[:params])
else
  total = Wordcount.new('', 'total')
  options[:files].each do |file_path|
    file = Pathname.new(file_path)
    if file.exist? && file.file?
      wc = Wordcount.new(file.read, file_path)
      total.lines += wc.lines
      total.words += wc.words
      total.characters += wc.characters
      puts wc.format_row(options[:params])
    elsif file.directory?
      puts "wc: #{file_path}: read: Is a directory"
    else
      puts "wc: #{file_path}: open: No such file or directory"
    end
  end
  puts total.format_row(options[:params]) if options[:files].size.positive?
end
