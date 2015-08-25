namespace :invest do
	task :get_data => :environment do
		Company.all.each do |company|
			command = 'casperjs '
			command += Rails.root.join('app/assets/javascripts/get_data.js').to_s
			command += ' ' + company.ticker
			command += ' ' + Rails.root.to_s
			sh command
		end
		if LastUpdated.first.nil?
			u = LastUpdated.create
		else
			u = LastUpdated.first
		end
		u.last_updated = Date.current
		u.save
	end
end