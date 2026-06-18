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

puts format("%2d月 %4d年".rjust(14), target_calendar.mon, target_calendar.year)
puts WEEKDAY_HEADER.join(" ")

# 最初の日と最後の日を取得する
first_day = target_calendar
last_day = first_day.next_month.prev_day

# 初日からさかのぼって最初の日曜日からスタートする
cursor_day = first_day
while !cursor_day.sunday?
  cursor_day = cursor_day.prev_day
end

week = []
while cursor_day <= last_day
  if cursor_day < first_day
    week << "  "
  else
    week << format("%2d", cursor_day.day)
  end

  if cursor_day.saturday? || cursor_day == last_day
    puts week.join(" ")
    week = []
  end
  cursor_day = cursor_day.next
end
