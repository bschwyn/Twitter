require 'rubygems'
require 'restclient'
require 'crack'

MAX_NUMBER_OF_TWEETS = 3200
MAX_NUMBER_OF_TWEETS_PER_REQUEST = 200

TARGET_USERNAME = 'StephenAtHome'

DATA_DIRECTORY = "data-hold"

Dir.mkdir(DATA_DIRECTORY) unless File.exists?(DATA_DIRECTORY)

GET_USERINFO_URL = "http://api.twitter.com/1/users
	/show.xml?screen_name=#{TARGET_USERNAME}"
	
GET_STATUSES_URL = "http://api.twitter.com/1/statuses/
	user_timeline.xml?screen_name=#{TARGET_USERNAME}&
	trim_user=true&count=#{NUMBER_OF_TWEETS_PER_PAGE}
	&include_retweets=true&include_entities=true"
	
user_info = RestClient.get(GET_USERINFO_URL)