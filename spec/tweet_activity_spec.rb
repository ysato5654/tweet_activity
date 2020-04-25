require 'spec_helper'

RSpec.describe TweetActivity do
	it 'has a version number' do
		expect(TweetActivity::VERSION).not_to be nil
	end

	describe '#parse_csv(file)' do
		subject do
			TweetActivity.parse_csv(file)
		end

		describe 'success' do
			let :file do
				File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_parse_csv_success/tweet_activity.csv')
			end

			it 'tweet activity list is created' do
				expect(subject.class).to be Array
				expect(subject.empty?).to be false
			end
		end

		describe 'unsuccess' do
			context 'raise error' do
				let :file do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_parse_csv_unsuccess/TweetActivity_NotFound/hoge.csv')
				end

				it '' do
					expect { subject }.to raise_error(TweetActivity::NotFound)
				end
			end

			context 'raise error' do
				let :file do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_parse_csv_unsuccess/TweetActivity_CSVFormatError/tweet_activity.csv')
				end

				it '' do
					expect { subject }.to raise_error(TweetActivity::CSVFormatError)
				end
			end
		end
	end

	describe '#connect(database)' do
		describe 'success' do
			before do
				TweetActivity.connect(database)
			end

			subject do
				File.exist?(file)
			end

			after do
				File.delete(file)
			end

			context 'database existance' do
				let :database do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_connect_success/database.yml')
				end

				let :yaml do
					YAML.load_file(database)
				end

				let :file do
					yaml['production']['database']
				end

				it '' do
					expect(subject).to be true
				end
			end
		end

		describe 'unsuccess' do
			subject do
				TweetActivity.connect(database)
			end

			context 'raise error' do
				let :database do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_connect_unsuccess/TweetActivity_NotFound/hoge.yml')
				end

				it '' do
					expect { subject }.to raise_error(TweetActivity::NotFound)
				end
			end

			context 'raise error' do
				let :database do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_connect_unsuccess/TweetActivity_ArgumentError/database.yml')
				end

				it '' do
					expect { subject }.to raise_error(TweetActivity::ArgumentError)
				end
			end

			context 'raise error' do
				let :database do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_connect_unsuccess/LoadError/database.yml')
				end

				it '' do
					expect { subject }.to raise_error(LoadError)
				end
			end

			context 'raise error' do
				let :database do
					File.expand_path(File.dirname(__FILE__) + '/config/TweetActivity_connect_unsuccess/TweetActivity_Sqlite3Connection/database.yml')
				end

				it '' do
					expect { subject }.to raise_error(TweetActivity::Sqlite3Connection)
				end
			end
		end
	end
end
