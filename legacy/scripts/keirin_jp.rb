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
    11=>"����",12=>"�X",13=>"���킫��",
    21=>"��F",22=>"�O��",23=>"���",24=>"�F�s�{",25=>"��{",26=>"������",27=>"�����t",28=>"����",
    31=>"����",32=>"��t",33=>"�Ԍ���",34=>"���",35=>"����",36=>"���c��",37=>"�ɓ�",38=>"�É�",
    41=>"��{",42=>"���É�",43=>"��",44=>"��_",45=>"�L��",46=>"�x�R",47=>"����",48=>"�l���s",
    51=>"����",52=>"���",53=>"�ޗ�",54=>"������",55=>"�a�̎R",56=>"�ݘa�c",58=>"�b�q��",59=>"���{",
    61=>"�ʖ�",62=>"�L��",63=>"�h�{",
    71=>"����",72=>"�ω���",73=>"������",74=>"���m",75=>"���R",
    81=>"���q",82=>"��i",83=>"�v����",84=>"���Y",85=>"������",86=>"�ʕ{",87=>"�F�{",
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
