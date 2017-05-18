class Setting < ActiveRecord::Base
  def self.init
    s = Setting.new(:name => 'update_frequency_days', :value => '90')
    s.save
  end
  def self.initialized?
    if Setting.find_by_name('update_frequency_days').nil?
      return false
    else
      return true
    end
  end
end
