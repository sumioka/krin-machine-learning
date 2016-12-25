#! ruby -EShift_JIS
# -*- mode:ruby; coding:shift_jis -*-

class KeirinJPWeb
  URL_BASE = "http://keirin.jp/pc/dfw/dataplaza/guest/"
  def initialize()
  end
  def get_page
# not yet
  end
  def gen_url_common(cgi,hsh)
    ary = []
    hsh.each {|k,v| ary.push "#{k}=#{v}"} 
    url = "#{URL_BASE}#{cgi}?" + ary.join("&")
    return url
  end
end

class Bank
  attr_accessor :no
  BANK_NAME_TBL = { 
    11=>"函館",12=>"青森",13=>"いわき平",
    21=>"弥彦",22=>"前橋",23=>"取手",24=>"宇都宮",25=>"大宮",26=>"西武園",27=>"京王閣",28=>"立川",
    31=>"松戸",32=>"千葉",33=>"花月園",34=>"川崎",35=>"平塚",36=>"小田原",37=>"伊東",38=>"静岡",
    41=>"一宮",42=>"名古屋",43=>"岐阜",44=>"大垣",45=>"豊橋",46=>"富山",47=>"松阪",48=>"四日市",
    51=>"福井",52=>"大津",53=>"奈良",54=>"向日町",55=>"和歌山",56=>"岸和田",58=>"甲子園",59=>"西宮",
    61=>"玉野",62=>"広島",63=>"防府",
    71=>"高松",72=>"観音寺",73=>"小松島",74=>"高知",75=>"松山",
    81=>"小倉",82=>"門司",83=>"久留米",84=>"武雄",85=>"佐世保",86=>"別府",87=>"熊本",
  }
  def initialize(no)
    @no = no
  end
  def name
    return BANK_NAME_TBL[no]
  end
end

class ResultWeb < KeirinJPWeb
  attr_accessor :bank, :date, :no
  def initialize(date, kcd, rno)
    @date = date
    @bank = Bank.new(kcd)
    @no  = rno
  end
  def gen_url
    kbi = @date.strftime("%Y%m%d")
    return gen_url_common("raceresult", {"KCD" => @bank.no, "KBI" => kbi, "RNO" => @no })
  end
  def gen_startlist_url
    kbi = @date.strftime("%Y%m%d")
    return gen_url_common("racemember", {"KCD" => @bank.no, "KBI" => kbi, "RNO" => @no })
    return url
  end
end

class RaceProgWeb < KeirinJPWeb
  attr_accessor :results, :bank, :date
  def initialize(date, kcd)
    @date = date
    @bank = Bank.new(kcd)
    @results = {}
  end
  def gen_url
    kst = @date.strftime("%Y%m%d")
    return gen_url_common("raceprogram", {"KCD" => @bank.no, "KST" => kst })
  end
  def parse(filename)
    File.foreach(filename, :encoding => Encoding::UTF_8) do |line|
      str = line.encode(Encoding::Shift_JIS)
      if /raceresult\?KCD=(\d+)&KBI=(\d+)&RNO=(\d+)/ =~ str
        kcd = $1
        kbi = Date.parse($2)
        rno = $3
        @results[kbi] = [] unless @results[kbi]
        @results[kbi].push(ResultWeb.new(kbi,kcd,rno))
      end
    end
  end
end

class ScheduleWeb < KeirinJPWeb
  attr_accessor :racelist
  def initialize(date)
    @date = date
    @racelist = []
  end
  def gen_url
    nen = @date.strftime("%Y")
    mon = @date.strftime("%m")
    return gen_url_common("racecalendar", {"NEN" => nen, "MON" => mon })
  end
  def parse(filename)
    File.foreach(filename, :encoding => Encoding::UTF_8) do |line|
      str = line.encode(Encoding::Shift_JIS)
      if /raceprogram\?KCD=(\d+)&KST=(\d+)/ =~ str
        kst = Date.parse($2)
        kcd = $1
        @racelist.push(RaceProgWeb.new(kst, kcd))
      end
    end
  end
end
