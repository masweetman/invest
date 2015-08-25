namespace :invest do
	task :get_data => :environment do
		Company.all.each do |company|
			command = 'casperjs '
			command += Rails.root.join('app/assets/javascripts/get_data.js').to_s
			command += ' ' + company.ticker.gsub('-','.')
			command += ' ' + Rails.root.to_s
			sh command
		end
		if Setting.find_by_name("last_updated").nil?
			s = Setting.create
		else
			s = Setting.find_by_name("last_updated")
		end
		s.value = Date.current.to_s
		s.save
	end
end