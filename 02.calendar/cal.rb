#!/usr/bin/env ruby

require "date"
require "optparse"

opt = OptionParser.new
params = {}
opt.on("-y [VAL]"){|v| params[:year] = v}
opt.on("-m [VAL]"){|v| params[:month] = v}

opt.parse!(ARGV)

target_calendar = Date.new(Date.today.year, Date.today.month)

WEEKDAY_HEADER = ['日', '月', '火', '水', '木', '金', '土']

# オプションに渡された年・月をセット
if params[:month] || params[:year]
  y = params[:year].nil? ? target_calendar.year : params[:year].to_i
  m = params[:month].nil? ? target_calendar.mon : params[:month].to_i
  target_calendar = Date.new(y, m)
end

# ヘッダーの出力
puts "#{target_calendar.mon}月 #{target_calendar.year}".rjust(13)
puts WEEKDAY_HEADER.join(" ")

# 最初の日と最後の日を取得する
first_day = target_calendar
last_day = first_day.next_month.prev_day

# 初日からさかのぼって最初の日曜日ぶんまで空白で埋めておく
week = first_day.sunday? ? [] : ["  "] * first_day.wday

(first_day..last_day).each do |date|
  week << date.strftime('%e')
  if date.saturday? || date == last_day
    puts week.join(" ")
    week = []
  end
end
