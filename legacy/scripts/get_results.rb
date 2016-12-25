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
opt.on('-d DIR')  { |v| $opt["dir"] = v }  
opt.parse!(ARGV)

x = $opt["from"].strftime("%Y").to_i
y = $opt["to"].strftime("%Y").to_i

a = $opt["from"].strftime("%m").to_i
b = $opt["to"].strftime("%m").to_i

files = Dir.glob("#{$opt["dir"]}/*.html")

while filename = files.shift do 
  if /raceprogram@KCD=(\d+)&KST=(\d+)\.html/ =~ filename
    kcd = $1
    date = Date.parse($2)
    next if (date.year == x) and (date.mon < a)
    next if (date.year == y) and (date.mon > b)
    prg = RaceProgWeb.new(date, kcd)
    prg.parse(filename)
    prg.results.each do |kbi, races|
      races.each do |r|
        print "#{r.gen_url}\n"
        print "#{r.gen_startlist_url}\n"
      end
    end
  end
end
