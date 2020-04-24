require 'spec_helper'

RSpec.describe TweetActivity do
	it 'has a version number' do
		expect(TweetActivity::VERSION).not_to be nil
	end
end
