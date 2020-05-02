#! /opt/local/bin/ruby
# coding: utf-8

require 'csv'
require 'yaml'
require 'active_record'

require File.expand_path(File.dirname(__FILE__) + '/tweet_activity/version')
require File.expand_path(File.dirname(__FILE__) + '/tweet_activity/error')

module TweetActivity

	ENVIRONMENT = 'production'

	class << self
		def parse_csv file
			tweet_activity_list = Array.new
			key = Array.new

			raise NotFound unless File.exist?(file)

			csv = CSV.parse(File.read(file, encoding: 'UTF-8'))

			csv.each_with_index do |line, idx|
				# get key name
				if idx.is_zero?
					key = line.map { |m| m.gsub(/\s/, '_').to_sym }
				# store value
				else
					raise CSVFormatError if key.size != line.size

					tweet_activity = key.zip(line).to_h

					tweet_activity_list.push tweet_activity
				end
			end

			tweet_activity_list
		end

		def connect database
			raise NotFound unless File.exist?(database)

			yaml = YAML.load_file(database)

			raise ArgumentError if yaml[ENVIRONMENT].nil?

			conn = {
				:adapter => yaml[ENVIRONMENT]['adapter'],
				:database => yaml[ENVIRONMENT]['database']
			}

			raise Sqlite3Connection if conn[:database].nil?

			ActiveRecord::Base.default_timezone = :local

			# connect database
			ActiveRecord::Base.establish_connection(conn)

			unless ActiveRecord::Migration.connection.table_exists?('by_days')
				# create table
				ActiveRecord::Migration.connection.create_table(:by_days, force: true) do |t|
					t.string    :date, :null => false
					t.integer   :tweets_published, :null => false
					t.integer   :impressions, :null => false
					t.integer   :engagements, :null => false
					t.decimal   :engagement_rate, :null => false
					t.integer   :retweets, :null => false
					t.integer   :replies, :null => false
					t.integer   :likes, :null => false
					t.integer   :user_profile_clicks, :null => false
					t.integer   :url_clicks, :null => false
					t.integer   :hashtag_clicks, :null => false
					t.integer   :detail_expands, :null => false
					t.integer   :permalink_clicks, :null => false
					t.integer   :app_opens, :null => false
					t.integer   :app_installs, :null => false
					t.integer   :follows, :null => false
					t.integer   :email_tweet, :null => false
					t.integer   :dial_phone, :null => false
					t.integer   :media_views, :null => false
					t.integer   :media_engagements, :null => false
					t.string    :promoted_impressions, :null => false
					t.string    :promoted_engagements, :null => false
					t.string    :promoted_engagement_rate, :null => false
					t.string    :promoted_retweets, :null => false
					t.string    :promoted_replies, :null => false
					t.string    :promoted_likes, :null => false
					t.string    :promoted_user_profile_clicks, :null => false
					t.string    :promoted_url_clicks, :null => false
					t.string    :promoted_hashtag_clicks, :null => false
					t.string    :promoted_detail_expands, :null => false
					t.string    :promoted_permalink_clicks, :null => false
					t.string    :promoted_app_opens, :null => false
					t.string    :promoted_app_installs, :null => false
					t.string    :promoted_follows, :null => false
					t.string    :promoted_email_tweet, :null => false
					t.string    :promoted_dial_phone, :null => false
					t.string    :promoted_media_views, :null => false
					t.string    :promoted_media_engagements, :null => false

					t.timestamps
				end
			end

			unless ActiveRecord::Migration.connection.table_exists?('by_tweets')
				# create table
				ActiveRecord::Migration.connection.create_table(:by_tweets, force: true) do |t|
					t.integer   :tweet_id, :null => false
					t.string    :tweet_permalink, :null => false
					t.text      :tweet_text, :null => false
					t.datetime  :time, :null => false
					t.integer   :impressions, :null => false
					t.integer   :engagements, :null => false
					t.decimal   :engagement_rate, :null => false
					t.integer   :retweets, :null => false
					t.integer   :replies, :null => false
					t.integer   :likes, :null => false
					t.integer   :user_profile_clicks, :null => false
					t.integer   :url_clicks, :null => false
					t.integer   :hashtag_clicks, :null => false
					t.integer   :detail_expands, :null => false
					t.integer   :permalink_clicks, :null => false
					t.integer   :app_opens, :null => false
					t.integer   :app_installs, :null => false
					t.integer   :follows, :null => false
					t.integer   :email_tweet, :null => false
					t.integer   :dial_phone, :null => false
					t.integer   :media_views, :null => false
					t.integer   :media_engagements, :null => false
					t.string    :promoted_impressions, :null => false
					t.string    :promoted_engagements, :null => false
					t.string    :promoted_engagement_rate, :null => false
					t.string    :promoted_retweets, :null => false
					t.string    :promoted_replies, :null => false
					t.string    :promoted_likes, :null => false
					t.string    :promoted_user_profile_clicks, :null => false
					t.string    :promoted_url_clicks, :null => false
					t.string    :promoted_hashtag_clicks, :null => false
					t.string    :promoted_detail_expands, :null => false
					t.string    :promoted_permalink_clicks, :null => false
					t.string    :promoted_app_opens, :null => false
					t.string    :promoted_app_installs, :null => false
					t.string    :promoted_follows, :null => false
					t.string    :promoted_email_tweet, :null => false
					t.string    :promoted_dial_phone, :null => false
					t.string    :promoted_media_views, :null => false
					t.string    :promoted_media_engagements, :null => false

					t.timestamps
				end
			end
		end
	end

	class ByDays < ActiveRecord::Base; end

	class ByTweets < ActiveRecord::Base; end
end

class Integer
	def is_zero?
		self == 0
	end
end
