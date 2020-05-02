#! /opt/local/bin/ruby
# coding: utf-8

require 'optparse'
require 'date'

require File.dirname(File.realpath(__FILE__)) + '/../lib/tweet_activity'

Year    = '2020'
Month   = 'May'
Day     = 02
Build   = [Day, Month, Year].join(' ')

Version = Build + ' ' + '(' + 'tweet_activity' + ' ' + 'v' + TweetActivity::VERSION + ')'

def parse_option
	opt = OptionParser.new

	option = Hash.new
	option[:daily] = false
	option[:weekly] = false
	option[:monthly] = false

	opt.on('-d', '--daily', 'daily activity by daily tweet') { |v| option[:daily] = v }
	opt.on('-w', '--weekly', 'weekly activity by daily tweet') { |v| option[:weekly] = v }
	opt.on('-m', '--monthly', 'monthly activity by daily tweet') { |v| option[:monthly] = v }

	begin
		opt.parse(ARGV)
	rescue SystemExit => e
		exit(0)
	rescue Exception => e
		#e.class
		# => OptionParser::InvalidOption

		STDERR.puts "#{__FILE__}:#{__LINE__}: #{e}"
		STDOUT.puts

		exit(0)
	end

	option
end

def parse_db option, database
	STDOUT.puts '---- input ----'
	STDOUT.puts YAML.load_file(database)['production']['database']
	STDOUT.puts

	begin
		TweetActivity.connect(database)
	rescue Exception => e
		case e.class
			when TweetActivity::NotFound then STDERR.puts "#{__FILE__}:#{__LINE__}: #{e.message} - #{database} (#{e.class})"
			else                              STDERR.puts "#{__FILE__}:#{__LINE__}: #{e.message} (#{e.class})"
		end

		exit(0)
	end

	if option[:daily]
		daily_tweet_activity_list = TweetActivity::ByDays.all.order(:date => 'ASC').select(:date, :tweets_published, :impressions, :engagements, :engagement_rate)
	#elsif option[:weekly]
	elsif option[:monthly]
		daily_tweet_activity_list = TweetActivity::ByDays.all.order(:date => 'ASC').select(:date, :tweets_published, :impressions, :engagements, :engagement_rate, :user_profile_clicks, :follows)
	end

	if option[:daily]
		STDOUT.puts '---- output ----'

		key = [:date, :tweets_published, :impressions, :engagements, :engagement_rate]

		STDOUT.puts key.join("\t")

		daily_tweet_activity_list.each do |tweet_activity|
			STDOUT.print tweet_activity.date
			STDOUT.print "\t"
			STDOUT.print tweet_activity.tweets_published
			STDOUT.print "\t"
			STDOUT.print tweet_activity.impressions
			STDOUT.print "\t"
			STDOUT.print tweet_activity.engagements
			STDOUT.print "\t"
			STDOUT.print (tweet_activity.engagement_rate * 100.0).to_f.round(2)
			STDOUT.puts
		end

		STDOUT.puts
	#elsif option[:weekly]
		#weekly_tweet_activity_list = pack_every_week(daily_tweet_activity_list)
	elsif option[:monthly]
		monthly_tweet_activity_list = pack_every_month(daily_tweet_activity_list)

		STDOUT.puts '---- output ----'

		monthly_tweet_activity_list.each_with_index do |tweet_activity, idx|
			if idx == 0
				STDOUT.puts tweet_activity.keys.join("\t")
			end

			STDOUT.puts tweet_activity.values.join("\t")
		end

		STDOUT.puts
	end
end

def pack_every_month daily_tweet_activity_list
	monthly_tweet_activity_list = Array.new

	# start date
	date = Date.parse(daily_tweet_activity_list.first.date)
	monthly_tweet_activity = init_monthly_tweet_activity(date)

	daily_tweet_activity_list.each do |daily_tweet_activity|
		date = Date.parse(daily_tweet_activity.date)

		if monthly_tweet_activity[:month] == date.month
			monthly_tweet_activity[:tweets_published]    += daily_tweet_activity.tweets_published
			monthly_tweet_activity[:impressions]         += daily_tweet_activity.impressions
			monthly_tweet_activity[:engagements]         += daily_tweet_activity.engagements
			monthly_tweet_activity[:engagement_rate]     += daily_tweet_activity.engagement_rate
			monthly_tweet_activity[:user_profile_clicks] += daily_tweet_activity.user_profile_clicks
			monthly_tweet_activity[:follows]             += daily_tweet_activity.follows
		else
			monthly_tweet_activity[:engagement_rate] = (monthly_tweet_activity[:engagement_rate] * monthly_tweet_activity[:engagements] / monthly_tweet_activity[:impressions] * 100.0).to_f.round(2)

			monthly_tweet_activity_list.push monthly_tweet_activity

			monthly_tweet_activity = init_monthly_tweet_activity(date)

			monthly_tweet_activity[:tweets_published]    += daily_tweet_activity.tweets_published
			monthly_tweet_activity[:impressions]         += daily_tweet_activity.impressions
			monthly_tweet_activity[:engagements]         += daily_tweet_activity.engagements
			monthly_tweet_activity[:engagement_rate]     += daily_tweet_activity.engagement_rate
			monthly_tweet_activity[:user_profile_clicks] += daily_tweet_activity.user_profile_clicks
			monthly_tweet_activity[:follows]             += daily_tweet_activity.follows
		end
	end

	monthly_tweet_activity_list
end

def init_monthly_tweet_activity date
	{
		:year                => date.year,
		:month               => date.month,
		:tweets_published    => 0,
		:impressions         => 0,
		:engagements         => 0,
		:engagement_rate     => 0,
		:user_profile_clicks => 0,
		:follows             => 0
	}
end

if $0 == __FILE__

	option = parse_option

	filename = File.basename(__FILE__).gsub(File.extname(__FILE__), '')

	STDOUT.puts filename + ' ' + Version
	STDOUT.puts

	database = File.expand_path(File.dirname(__FILE__) + '/database.yml')

	parse_db(option, database)

end
