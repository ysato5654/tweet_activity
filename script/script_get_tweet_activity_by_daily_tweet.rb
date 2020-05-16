#! /opt/local/bin/ruby
# coding: utf-8

require 'date'
require 'tweet_activity'
require File.dirname(File.realpath(__FILE__)) + '/command_line_option'

Year    = '2020'
Month   = 'May'
Day     = '17'
Build   = [Day, Month, Year].join(' ')

Version = Build + ' ' + '(' + 'tweet_activity' + ' ' + 'v' + TweetActivity::VERSION + ')'

Period = [:daily, :weekly, :monthly]
Options = {
	:short => 'p',
	:long => 'period',
	:arg => Period,
	:description => "period of packing tweet activity (#{Period.join('/')})"
}

def parse_db(period:, database:)
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

	case period
	when :daily
		key = [:date, :tweets_published, :impressions, :engagements, :engagement_rate]
	when :weekly, :monthly
		key = [:date, :tweets_published, :impressions, :engagements, :engagement_rate, :user_profile_clicks, :follows]
	end

	daily_tweet_activity_list = TweetActivity::ByDays.all.order(:date => 'ASC').select(key)

	case period
	when :daily
		STDOUT.puts '---- output ----'

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
	when :weekly
		STDOUT.puts '---- output ----'

		#weekly_tweet_activity_list = pack_every_week(daily_tweet_activity_list)

		STDOUT.puts '---- output ----'

		# header
		STDOUT.puts weekly_tweet_activity_list.first.keys.join("\t")

		# body
		weekly_tweet_activity_list.each { |tweet_activity| STDOUT.puts tweet_activity.values.join("\t") }

		STDOUT.puts
	when :monthly
		monthly_tweet_activity_list = pack_every_month(daily_tweet_activity_list)

		STDOUT.puts '---- output ----'

		# header
		STDOUT.puts monthly_tweet_activity_list.first.keys.join("\t")

		# body
		monthly_tweet_activity_list.each { |tweet_activity| STDOUT.puts tweet_activity.values.join("\t") }

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

	monthly_tweet_activity[:engagement_rate] = (monthly_tweet_activity[:engagement_rate] * monthly_tweet_activity[:engagements] / monthly_tweet_activity[:impressions] * 100.0).to_f.round(2)

	monthly_tweet_activity_list.push monthly_tweet_activity

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

	command_line_option = TweetActivityScript::CommandLineOption.new(:param => Options)

	# parse option
	begin
		option = command_line_option.parse

	# display help or no necessary option fail
	rescue SystemExit => e
		exit(0)

	rescue TweetActivityScript::MissingOption => e
		STDERR.puts "#{__FILE__}: #{e.message} (--help will show valid options)"
		exit(0)

	# invalid option (undefined option) or missing argument or invalid argument
	rescue Exception => e
		STDERR.puts "#{__FILE__}: #{e} (--help will show valid options)"
		exit(0)

	end

	filename = File.basename(__FILE__).gsub(File.extname(__FILE__), '')

	STDOUT.puts filename + ' ' + Version
	STDOUT.puts

	database = File.expand_path(File.dirname(__FILE__) + '/database.yml')

	parse_db(:period => option[:period], :database => database)

end
