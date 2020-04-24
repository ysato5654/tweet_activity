require 'spec_helper'

RSpec.describe TweetActivity do
	it 'has a version number' do
		expect(TweetActivity::VERSION).not_to be nil
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
