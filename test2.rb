# Last edited:  9/7/2013

#This program accesses the twitter API and prints the last n tweets from each person in a file.

require "rubygems"
require "oauth"
require "json"
require "rgl/adjacency"

access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"


$PUNCTUATION = /[,!.#~`$%^&*()-=+\/\[{\]}\|;:'\",<.>?\\+ \t]+/

name_file = "jlo.txt" #name of file to read usernames from
tweetcount= 5 #number of tweets from each username to print
order = 1

#******************************************************************************************
#takes access tokens and consumer tokens to give an access token instance
#copied from  https://dev.twitter.com/docs/auth/oauth/single-user-with-examples#ruby

def prepare_access_token(access_key, access_secret, consumer_key, consumer_secret)
	consumer = OAuth::Consumer.new(consumer_key,consumer_secret,
		{	:site => "http://api.twitter.com",
			:scheme => :header
		})
	# now create the access token object form passed values
	token_hash = {	:oauth_token => access_key,
				:oauth_token_secret => access_secret
			}
	access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
end

# takes a file of usernames, removes "@" character and returns array of usernames
def tweet_file_parser(file)
	
	string_array = open(file,"r").readlines
	string_array.map{ |k|k[1..-2] }
end

#pareses response from twitter and puts tweets in an array
def tweets_to_array(username,access_token,tweetcount)
	response = access_token.request(:get,
	"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{tweetcount}")
	result = JSON.parse(response.body)
	tweets_array = result.map{ |hash|
	#This should help with mistyped usernames, and when I run over the 
	if hash.size ==2
		puts hash[1][0]["message"]
	else	
		hash["text"]
	end
	puts tweets_array
	}
end

token = prepare_access_token(access_token_key, access_token_secret, consumer_key, consumer_secret)
tweets_to_array("bryan_caplan",token,10)