# split_clean.rb
require 'icalendar'

input_file = 'original_calendar.ics'
holiday_file = 'holiday_green.ics'
workday_file = 'workday_red.ics'
festival_file = 'festival_blue.ics'

cal_file = File.open(input_file)
cals = Icalendar::Calendar.parse(cal_file)
cal = cals.first

holiday_cal = Icalendar::Calendar.new
workday_cal = Icalendar::Calendar.new
festival_cal = Icalendar::Calendar.new

cal.events.each do |event|
  summary = event.summary.to_s
  if summary.include?('休')
    # 复制事件，但修改标题为 "休"
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
    # 保留原节日名称
    festival_cal.add_event(event)
  end
end

# 写入文件
File.open(holiday_file, 'w') { |f| f.write(holiday_cal.to_ical) }
File.open(workday_file, 'w') { |f| f.write(workday_cal.to_ical) }
File.open(festival_file, 'w') { |f| f.write(festival_cal.to_ical) }

puts "已生成: holiday_green.ics (事件标题为‘休’)"
puts "已生成: workday_red.ics (事件标题为‘班’)"
puts "已生成: festival_blue.ics (保留原节日名称)"
