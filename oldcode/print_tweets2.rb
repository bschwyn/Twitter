

require "rubygems"
require "oauth"

akey = access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
asecret = access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

ckey = consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
csecret = consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"

name_file = "tweet_users.txt"


#******************************************************************************************
#exchange your oauth_token and oauth_token_secret for an AccessToken instance.
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

#****************************************************************************************

#****************************************************************************************
#opens a text file and returns a list of namess as an array
def tweet_file_parser(file)
	string = open(file,"r").read
	string[0] = ''
	array_of_names = string.split("\n@")
	return array_of_names
end
#***************************************************************************************


			
#***************************************************************************************			
#given an array of tweet names

def print_tweets(array_of_usernames,how_many_tweets_do_you_want,akey,asecret,ckey,csecret)
	if how_many_tweets_do_you_want > 200
		puts "Error: Twitter will only give <200 tweets at a time"
	end
	array_of_usernames.each {
		|k| #note k is a reference to the username elements
		
		#Exchange our oauth_token and oauth_token secret for the AccessToken instance.
		access_token = prepare_access_token(akey, asecret, ckey, csecret)
		# use the access token to get a url
		response = access_token.request(:get,
		"https://api.twitter.com/1.1/statuses/user_timeline.json?
		screen_name=#{k}
		&count=#{how_many_tweets_do_you_want}")
	
		puts "the first #{how_many_tweets_do_you_want} tweets of #{k} are:"
		puts response
	}
end


array_of_names = tweet_file_parser(name_file)
print_tweets(array_of_names,1,akey,asecret,ckey,csecret)