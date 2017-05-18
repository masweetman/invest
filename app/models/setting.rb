class Setting < ActiveRecord::Base
  def self.update_frequency_days
    if Setting.find_by_name('update_frequency_days').nil?
      s = Setting.new(:name => 'update_frequency_days', :value => '90')
      s.save
    end
    return Setting.find_by_name('update_frequency_days')
  end
end
