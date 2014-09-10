# print_last_tweets.rb #not needed
# Ben Schwyn
# Last edited:  9/7/2013 #also

#This program accesses the twitter API and prints the last n tweets from each person in a file.
#good!
require "rubygems"
require "oauth"
require "json"

access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"

name_file = "famous_people.txt" #name of file to read usernames from #this should be a parameter
tweetcount= 10 #number of tweets from each username to print

#******************************************************************************************
#takes access tokens and consumer tokens to give an access token instance
#copied from  https://dev.twitter.com/docs/auth/oauth/single-user-with-examples#ruby

def prepare_access_token(access_key, access_secret, consumer_key, consumer_secret)
	consumer = OAuth::Consumer.new(consumer_key,consumer_secret,
		{	:site => "http://api.twitter.com",
			:scheme => :header
		})
	# now create the access token object from passed values
	token_hash = {	:oauth_token => access_key,
				:oauth_token_secret => access_secret
			}
	access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
end

#****************************************************************************************

# takes a file of usernames, removes "@" character and returns array of usernames
def tweet_file_parser(file)
	string_array = open(file,"r").readlines
	string_array.map{ |k| k[1..-2] }
end
#***************************************************************************************
# parses response from twitter and prints tweets to file
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
# creates file, and prints tweets for each user
def print_all_tweets(array_of_usernames,access_token, tweetcount)
	if tweetcount > 200
		return puts "Error: Twitter will only give max 200 tweets at a time"
	end
	
	newfile = "tweet_output.txt"
	file = File.open(newfile,"w")
	array_of_usernames.each {|name| 
		print_tweets(name, access_token,tweetcount,file)
	}
	file.close
end

#*****************************************************************************************
	
access_token = prepare_access_token(access_token_key, access_token_secret,consumer_key,consumer_secret)
array_of_names = tweet_file_parser(name_file)
print_all_tweets(array_of_names,access_token,tweetcount)
