require "rubygems"
require "oauth"
require "json"

akey = access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
asecret = access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

ckey = consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
csecret = consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"

name_file = "tweet_users.txt"
tweetcount= 3 #tweetcount

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
def tweet_file_parser(file)
	string_array = open(file,"r").readlines
	string_array.map{ |k|k[1..-2] }
end
#***************************************************************************************

def print_tweets(username,access_token,tweetcount, file)
	response = access_token.request(:get,
	"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{tweetcount}")
	result = JSON.parse(response.body)
	
	puts "the last #{tweetcount} tweets of #{username} are:\n\n"
	file.puts "the last #{tweetcount} tweets of #{username} are:\n\n"
	
	result.each { |hash|
		puts "  * " + hash["text"]
		file.puts "  * " + hash["text"]
	}
	
	puts "\n"
	file. puts "\n"
end

			
#***************************************************************************************			

def print_all_tweets(array_of_usernames,access_token, tweetcount)
	if tweetcount > 200
		puts "Error: Twitter will only give <200 tweets at a time"
	end
	newfile = "tweet_output.txt"
	file = File.open(newfile,"w")
	
	array_of_usernames.each {|name| 
		print_tweets(name, access_token,tweetcount,file)
	}
	file.close
end
	
access_token = prepare_access_token(access_token_key, access_token_secret,consumer_key,consumer_secret)
array_of_names = tweet_file_parser(name_file)

newfile = "tweet_output.txt"
File.open(newfile,"w")

print_all_tweets(array_of_names,access_token,tweetcount)