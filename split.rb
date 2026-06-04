require 'icalendar'
require 'open-uri'

# 1. 下载原始日历
url = 'https://calendars.icloud.com/holidays/cn_zh.ics'
File.write('original_calendar.ics', URI.open(url).read, encoding: 'UTF-8')

# 2. 读取并清洗文件（移除无效 UTF-8 字符）
content = File.read('original_calendar.ics', encoding: 'UTF-8', invalid: :replace, undef: :replace)
File.write('original_calendar.ics', content, encoding: 'UTF-8')

# 3. 解析日历
cal_file = File.open('original_calendar.ics')
cals = Icalendar::Calendar.parse(cal_file)
cal = cals.first

# 4. 创建三个空日历
holiday_cal = Icalendar::Calendar.new
workday_cal = Icalendar::Calendar.new
festival_cal = Icalendar::Calendar.new

# 5. 分类事件
cal.events.each do |event|
  summary = event.summary.to_s
  if summary.include?('休')
    holiday_cal.add_event(event)
  elsif summary.include?('班')
    workday_cal.add_event(event)
  elsif summary.include?('节') || summary == '除夕'
    festival_cal.add_event(event)
  end
end

# 6. 写入文件
File.open('holiday_green.ics', 'w') { |f| f.write(holiday_cal.to_ical) }
File.open('workday_red.ics', 'w') { |f| f.write(workday_cal.to_ical) }
File.open('festival_blue.ics', 'w') { |f| f.write(festival_cal.to_ical) }

puts '已生成: holiday_green.ics (含“休”)'
puts '已生成: workday_red.ics (含“班”)'
puts '已生成: festival_blue.ics (含“节”或“除夕”)'
