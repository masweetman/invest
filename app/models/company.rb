require 'nokogiri'
require 'open-uri'

class Company < ActiveRecord::Base
  has_many :earnings, :dependent => :destroy
  has_many :dividends, :dependent => :destroy
  validates :ticker, presence: true, length: { minimum: 1 }

  def scrape
    a = 'casperjs '
    a += Rails.root.join('app/assets/javascripts/get_data.js').to_s
    a += ' ' + ticker.gsub('-','.')
    a += ' ' + Rails.root.to_s
    h = %x[ #{a} ]
    html = Nokogiri::HTML(h)

    self.name = html.css('div.wrapper div.r_bodywrap div.r_header div.reports_nav div.r_title h1')[0].content if html.css('div.wrapper div.r_bodywrap div.r_header div.reports_nav div.r_title h1')[0]
    if self.name.nil? || self.name.downcase.include?("pref share")
      self.no_data = true unless self.earnings.any?
    else
      self.bv_per_share = html.css('td[headers$="i8"]')[9].content.to_f if html.css('td[headers$="i8"]')[9]
      update_eps(html)
      update_div(html)
      self.last_earnings_update = Date.today
      self.require_update = false
    end
    self.save
  end

  def update_eps(html)
    titles = html.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
      i.content
    end
    eps = html.css('td[headers$="i5"]').map do |i|
      i.content
    end

    if titles.length == 0
      self.no_data = true unless self.earnings.any?
    end

    unless titles.length == 0 || eps.length == 0
      earnings_per_share = Hash.new
      titles.each_with_index do |title, earnings|
        if title.include?('-')
          earnings_per_share[title] = eps[earnings].to_f unless eps[earnings].to_f == 0
        end
      end
      earnings_per_share.each do |eps|
        if self.earnings.where(year: eps[0]).empty?
          e = self.earnings.create
        else
          e = self.earnings.where(year: eps[0]).last
        end
        date = eps[0].split /-/
        e.year = date.first.to_i
        e.month = date.last.to_i
        e.value = eps[1]
        e.save
      end
    end
  end

  def update_div(html)
    titles = html.css('table.r_table1 thead tr th[id^="Y"]').map do |i|
      i.content
    end
    divs = html.css('td[headers$="i6"]').map do |i|
      i.content
    end

    unless titles.length == 0 || divs.length == 0
      dividends = Hash.new
      titles.each_with_index do |title, dividend|
        if title.include?('-')
          dateComponents = title.split /-/
          dividends[dateComponents[0].to_i] = divs[dividend].to_f unless divs[dividend].to_f == 0 
        end
      end
      dividends.each do |divs|
        if self.dividends.where(year: divs[0]).empty?
          d = self.dividends.create
        else
          d = self.dividends.where(year: divs[0]).last
        end
        d.year = divs[0]
        d.value = divs[1]
        d.save
      end
    end
  end

  def quote
    quote = YahooFinance::Client.new.quote(ticker)
    if !quote.nil? && (quote.exchange == 'NYQ' || quote.exchange == 'NMS')
      update_quote(quote)
    else
      #self.destroy
    end
  end

  def update_quote(quote)
    self.price = quote.regularMarketPrice.to_f
    self.price_change_pct = quote.regularMarketChangePercent.to_f
    self.market_cap_val = quote.marketCap.to_f
    bil = (quote.marketCap.to_f/1000000000).round 2
    mil = (quote.marketCap.to_f/1000000).round 2
    self.market_cap = bil.to_s + "B" if bil >= 1
    self.market_cap = mil.to_s + "B" if bil < 1

    if (self.no_data == false && self.last_earnings_update.nil?) ||
       (self.no_data == false && (Date.today > self.last_earnings_update + Setting.update_frequency_days.value.to_i.days))
      self.require_update = true
    else
      self.require_update = false
    end

    earnings = self.earnings.where('year >= ? AND year <= ?', Date.current.year - 6, Date.current.year).map { |e| e.value }
    average = (earnings.sum.round(3) / earnings.length).round(3) unless earnings.length == 0

    last_div = self.dividends.map{ |d| d.year }.max
    if self.dividends.where(year: last_div).any?
      dividend = self.dividends.where(year: last_div).last.value.to_f
    else
      dividend = 0.0
    end

    self.calculated_pe = self.price.to_f / average unless average.to_f == 0
    self.div_yield = dividend / self.price.to_f unless self.price.to_f == 0
    self.p_to_bv = self.price.to_f / self.bv_per_share.to_f unless self.bv_per_share.to_f == 0

    self.save
  end

end
