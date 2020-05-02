[![Build Status](https://travis-ci.org/ysato5654/tweet_activity.svg?branch=master)](https://travis-ci.org/ysato5654/twicas_stream)
[![Coverage Status](https://coveralls.io/repos/github/ysato5654/tweet_activity/badge.svg?branch=master)](https://coveralls.io/github/ysato5654/tweet_activity?branch=master)

# tweet_activity

## Usage

### parse tweet activity's csv file

```rb
TweetActivity.parse_csv(file) # 'file' : tweet activity's csv file path
# => [
#      {
#        :Tweet_id => "xxxx",
#        :Tweet_permalink => "xxxx",
#        :Tweet_text => "xxxx",
#        :time => "xxxx",
#        :impressions => "xxxx",
#        :engagements => "xxxx",
#        :engagement_rate => "xxxx",
#            :
#      },
#        :
#    ]
```

### record to database

```rb
tweet_activity = {
    :Tweet_id => "xxxx",
    :Tweet_permalink => "xxxx",
    :Tweet_text => "xxxx",
            :
}

database = 'database.yml' # example file is in config/database.yml
TweetActivity.connect(database)

TweetActivity::ByTweets.find_or_create_by(:tweet_id => tweet_activity[:Tweet_id]) do |t|
    t.tweet_id = tweet_activity[:Tweet_id]
    t.tweet_permalink = tweet_activity[:Tweet_permalink]
    t.tweet_text = tweet_activity[:Tweet_text]
            :
end
```
