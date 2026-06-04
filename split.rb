require 'icalendar'
require 'open-uri'

# 下载原始日历
url = 'https://calendars.icloud.com/holidays/cn_zh.ics'
File.write('original_calendar.ics', URI.open(url).read)

# 解析日历
cal_file = File.open('original_calendar.ics')
cals = Icalendar::Calendar.parse(cal_file)
cal = cals.first

# 创建三个空日历
holiday_cal = Icalendar::Calendar.new
workday_cal = Icalendar::Calendar.new
festival_cal = Icalendar::Calendar.new

cal.events.each do |event|
  summary = event.summary.to_s
  if summary.include?('休')
    new_event = Icalendar::Event.new
    new_event.dtstart = event.dtstart
    new_event.dtend = event.dtend
    new_event.summary = '休'
    new_event.dtstamp = event.dtstamp
    new_event.uid = event.uid
    holiday_cal.add_event(new_event)
  elsif summary.include?('班')
    new_event = Icalendar::Event.new
    new_event.dtstart = event.dtstart
    new_event.dtend = event.dtend
    new_event.summary = '班'
    new_event.dtstamp = event.dtstamp
    new_event.uid = event.uid
    workday_cal.add_event(new_event)
  elsif summary.include?('节') || summary == '除夕'
    festival_cal.add_event(event)
  end
end

File.open('holiday_green.ics', 'w') { |f| f.write(holiday_cal.to_ical) }
File.open('workday_red.ics', 'w') { |f| f.write(workday_cal.to_ical) }
File.open('festival_blue.ics', 'w') { |f| f.write(festival_cal.to_ical) }

puts "已生成: holiday_green.ics (事件标题为‘休’)"
puts "已生成: workday_red.ics (事件标题为‘班’)"
puts "已生成: festival_blue.ics (保留原节日名称)"
