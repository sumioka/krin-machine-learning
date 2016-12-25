#! ruby -EShift_JIS
# -*- mode:ruby; coding:shift_jis -*-

require 'optparse'
require 'date'

pathname = File.dirname(__FILE__)
$LOAD_PATH.push(pathname)

require 'keirin_jp'

$opt = { }

opt = OptionParser.new
opt.on('-f DATE') { |v| $opt["from"] = Date.parse(v) }  
opt.on('-t DATE') { |v| $opt["to"] = Date.parse(v) }  
opt.on('-d DIR') { |v| $opt["dir"] = v }  
opt.parse!(ARGV)

x = $opt["from"].strftime("%Y").to_i
y = $opt["to"].strftime("%Y").to_i

a = $opt["from"].strftime("%m").to_i
b = $opt["to"].strftime("%m").to_i

(x..y).each do |year|
  (1..12).each do |mon|
    next if (year == x) and (mon < a)
    next if (year == y) and (mon > b)
    date = Date.new(year, mon)
    filename = date.strftime("#{$opt["dir"]}/racecalendar@NEN=%Y&MON=%m.html")
    sch = ScheduleWeb.new(date)
    sch.parse(filename)
    sch.racelist.each do |list|
      print list.gen_url, "\n"
    end
  end
end
