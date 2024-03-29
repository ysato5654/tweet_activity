#! /opt/local/bin/ruby
# coding: utf-8

require 'date'
require 'tweet_activity'
require File.dirname(File.realpath(__FILE__)) + '/command_line_option'

Year    = '2021'
Month   = 'Dec'
Day     = '18'
Build   = [Day, Month, Year].join(' ')

Version = Build + ' ' + '(' + 'tweet_activity' + ' ' + 'v' + TweetActivity::VERSION + ')'

Type = [:by_day, :by_tweet]
User = [:taikabu0, :y_y_y_1214]
Options = [
	{:short => 't', :long => 'type', :arg => Type, :description => "activity csv file type (#{Type.join(' or ')})"},
	{:short => 'u', :long => 'username', :arg => User, :description => "twitter username (#{User.join(' or ')})"}
]

def parse_csv(type:, username:, base_dir:)
	tweet_activity_list = Array.new

	case type
	when :by_day
		tweet_activity_csv_list = Dir::entries('.').select { |file| file =~ /^daily_tweet_activity_metrics_#{username}_/ and file =~ /_en.csv$/ }
	when :by_tweet
		tweet_activity_csv_list = Dir::entries('.').select { |file| file =~ /^tweet_activity_metrics_#{username}_/ and file =~ /_en.csv$/ }
	else
		tweet_activity_csv_list = Array.new
	end

	STDOUT.puts '---- input ----'

	if tweet_activity_csv_list.empty?
		STDOUT.puts "No any tweet activity csv file"
		STDOUT.puts

		exit(0)
	end

	tweet_activity_csv_list.each do |filename|
		STDOUT.puts filename

		filepath = base_dir + '/' + filename

		begin
			tweet_activity_list.push TweetActivity.parse_csv(filepath)
		rescue Exception => e
			if e.class == TweetActivity::NotFound
				STDERR.puts "#{__FILE__}:#{__LINE__}: #{e.message} - #{filepath} (#{e.class})"
			else
				STDERR.puts "#{__FILE__}:#{__LINE__}: #{e.message} (#{e.class})"
			end

			exit(0)
		end

		tweet_activity_list.flatten!
	end

	tweet_activity_list
end

def record_db(type:, database:, tweet_activity_list:)
	STDOUT.puts '---- output ----'
	STDOUT.puts YAML.load_file(database)['production']['database']
	STDOUT.puts

	begin
		TweetActivity.connect(database)
	rescue Exception => e
		if e.class == TweetActivity::NotFound
			STDERR.puts "#{__FILE__}:#{__LINE__}: #{e.message} - #{database} (#{e.class})"
		else
			STDERR.puts "#{__FILE__}:#{__LINE__}: #{e.message} (#{e.class})"
		end

		exit(0)
	end

	if type == :by_day
		before_count = TweetActivity::ByDays.all.count
	elsif type == :by_tweet
		before_count = TweetActivity::ByTweets.all.count
	end

	tweet_activity_list.each do |tweet_activity|
		if type == :by_day
			TweetActivity::ByDays.find_or_create_by(:date => tweet_activity[:Date]) do |t|
				t.date = tweet_activity[:Date]
				t.tweets_published = tweet_activity[:Tweets_published]
				t.impressions = tweet_activity[:impressions]
				t.engagements = tweet_activity[:engagements]
				t.engagement_rate = tweet_activity[:engagement_rate]
				t.retweets = tweet_activity[:retweets]
				t.replies = tweet_activity[:replies]
				t.likes = tweet_activity[:likes]
				t.user_profile_clicks = tweet_activity[:user_profile_clicks]
				t.url_clicks = tweet_activity[:url_clicks]
				t.hashtag_clicks = tweet_activity[:hashtag_clicks]
				t.detail_expands = tweet_activity[:detail_expands]
				t.permalink_clicks = tweet_activity[:permalink_clicks]
				t.app_opens = tweet_activity[:app_opens]
				t.app_installs = tweet_activity[:app_installs]
				t.follows = tweet_activity[:follows]
				t.email_tweet = tweet_activity[:email_tweet]
				t.dial_phone = tweet_activity[:dial_phone]
				t.media_views = tweet_activity[:media_views]
				t.media_engagements = tweet_activity[:media_engagements]
				t.promoted_impressions = tweet_activity[:promoted_impressions]
				t.promoted_engagements = tweet_activity[:promoted_engagements]
				t.promoted_engagement_rate = tweet_activity[:promoted_engagement_rate]
				t.promoted_retweets = tweet_activity[:promoted_retweets]
				t.promoted_replies = tweet_activity[:promoted_replies]
				t.promoted_likes = tweet_activity[:promoted_likes]
				t.promoted_user_profile_clicks = tweet_activity[:promoted_user_profile_clicks]
				t.promoted_url_clicks = tweet_activity[:promoted_url_clicks]
				t.promoted_hashtag_clicks = tweet_activity[:promoted_hashtag_clicks]
				t.promoted_detail_expands = tweet_activity[:promoted_detail_expands]
				t.promoted_permalink_clicks = tweet_activity[:promoted_permalink_clicks]
				t.promoted_app_opens = tweet_activity[:promoted_app_opens]
				t.promoted_app_installs = tweet_activity[:promoted_app_installs]
				t.promoted_follows = tweet_activity[:promoted_follows]
				t.promoted_email_tweet = tweet_activity[:promoted_email_tweet]
				t.promoted_dial_phone = tweet_activity[:promoted_dial_phone]
				t.promoted_media_views = tweet_activity[:promoted_media_views]
				t.promoted_media_engagements = tweet_activity[:promoted_media_engagements]
			end
		elsif type == :by_tweet
			TweetActivity::ByTweets.find_or_create_by(:tweet_id => tweet_activity[:Tweet_id]) do |t|
				t.tweet_id = tweet_activity[:Tweet_id]
				t.tweet_permalink = tweet_activity[:Tweet_permalink]
				t.tweet_text = tweet_activity[:Tweet_text]
				t.time = DateTime.parse(tweet_activity[:time])
				t.impressions = tweet_activity[:impressions]
				t.engagements = tweet_activity[:engagements]
				t.engagement_rate = tweet_activity[:engagement_rate]
				t.retweets = tweet_activity[:retweets]
				t.replies = tweet_activity[:replies]
				t.likes = tweet_activity[:likes]
				t.user_profile_clicks = tweet_activity[:user_profile_clicks]
				t.url_clicks = tweet_activity[:url_clicks]
				t.hashtag_clicks = tweet_activity[:hashtag_clicks]
				t.detail_expands = tweet_activity[:detail_expands]
				t.permalink_clicks = tweet_activity[:permalink_clicks]
				t.app_opens = tweet_activity[:app_opens]
				t.app_installs = tweet_activity[:app_installs]
				t.follows = tweet_activity[:follows]
				t.email_tweet = tweet_activity[:email_tweet]
				t.dial_phone = tweet_activity[:dial_phone]
				t.media_views = tweet_activity[:media_views]
				t.media_engagements = tweet_activity[:media_engagements]
				t.promoted_impressions = tweet_activity[:promoted_impressions]
				t.promoted_engagements = tweet_activity[:promoted_engagements]
				t.promoted_engagement_rate = tweet_activity[:promoted_engagement_rate]
				t.promoted_retweets = tweet_activity[:promoted_retweets]
				t.promoted_replies = tweet_activity[:promoted_replies]
				t.promoted_likes = tweet_activity[:promoted_likes]
				t.promoted_user_profile_clicks = tweet_activity[:promoted_user_profile_clicks]
				t.promoted_url_clicks = tweet_activity[:promoted_url_clicks]
				t.promoted_hashtag_clicks = tweet_activity[:promoted_hashtag_clicks]
				t.promoted_detail_expands = tweet_activity[:promoted_detail_expands]
				t.promoted_permalink_clicks = tweet_activity[:promoted_permalink_clicks]
				t.promoted_app_opens = tweet_activity[:promoted_app_opens]
				t.promoted_app_installs = tweet_activity[:promoted_app_installs]
				t.promoted_follows = tweet_activity[:promoted_follows]
				t.promoted_email_tweet = tweet_activity[:promoted_email_tweet]
				t.promoted_dial_phone = tweet_activity[:promoted_dial_phone]
				t.promoted_media_views = tweet_activity[:promoted_media_views]
				t.promoted_media_engagements = tweet_activity[:promoted_media_engagements]
			end
		end
	end

	if type == :by_day
		after_count = TweetActivity::ByDays.all.count
	elsif type == :by_tweet
		after_count = TweetActivity::ByTweets.all.count
	end

	STDOUT.puts 'record count before : ' + before_count.to_s
	STDOUT.puts 'record count after  : ' + after_count.to_s
	STDOUT.puts

end

if $0 == __FILE__

	command_line_option = TweetActivityScript::CommandLineOption.new(Options)

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

	base_dir = File.expand_path(File.dirname(__FILE__))

	tweet_activity_list = parse_csv(:type => option[:type], :username => option[:username], :base_dir => base_dir)

	STDOUT.puts

	#database = File.expand_path(File.dirname(__FILE__) + '/../config/database.yml')
	database = File.expand_path(File.dirname(__FILE__) + '/database.yml')

	record_db(:type => option[:type], :database => database, :tweet_activity_list => tweet_activity_list)

end
