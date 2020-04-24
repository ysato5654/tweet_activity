#! /opt/local/bin/ruby
# coding: utf-8

module TweetActivity
	class CSVFormatError < StandardError
		attr_reader :message

		def initialize
			@message = 'CSV format error'
		end
	end

	class NotFound < StandardError
		attr_reader :message

		def initialize
			@message = 'No such file or directory'
		end
	end

	class ArgumentError < StandardError
		attr_reader :message

		def initialize
			@message = 'Missing argument: ' + ENVIRONMENT
		end
	end

	class Sqlite3Connection < StandardError
		attr_reader :message

		def initialize
			@message = 'No database file specified'
		end
	end
end
