# print_last_tweets_n_more.rb
# Ben Schwyn
# Last edited:  9/7/2013

#This program accesses the twitter API and prints the last n tweets from each person in a file.

require "rubygems"
require "oauth"
require "json"

access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"

name_file = "short.txt" #name of file to read usernames from
tweetcount= 10 #number of tweets from each username to print

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
def tweets_to_array(username,access_token,tweetcount,file)
	response = access_token.request(:get,
	"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{tweetcount}")
	result = JSON.parse(response.body)
	tweets_array = result.map{ |hash| hash["text"] }
end

# creates file, and prints tweets for each user
def print_all_tweets(array_of_usernames, access_token,tweetcount)
	if tweetcount > 200
		return puts "Error: Twitter will only give max 200 tweets at a time"
	end
	
	newfile = "tweet_output2.txt"
	file = File.open(newfile,"w")
	array_of_usernames.each { |name|
		tweets_array = tweets_to_array(name, access_token, tweetcount, file)
		mentions = tweeted_at(tweets_array)
		tweet_total = people_tweeted_at(mentions, name)
		
		puts "the last #{tweetcount} tweets of #{name} are:\n\n"
		#file.puts "the last #{tweetcount} tweets of #{name} are:\n\n"

		
		puts tweets_array
		#file.puts tweets_array
		puts "\n"
		#file.puts "\n"

		puts "#{name} mentioned these people:\n\n"
		#file.puts "#{name} mentioned these people:\n\n"
		
		puts mentions
		file.puts mentions
		puts "\n"
		file.puts "\n"
		
		puts tweet_total
		#file.puts tweet_total
		puts "\n"
		#file.puts "\n"
	}
	file.close
end

# This function returns an array of of twitter users that one twitter user tweeted at
#note: need better names

#mentions_all ---all people tweeted at from any person in the file  
#mentions_b ---all people one person tweeted at					now just "mentions"
#mentions_c ---all people tweeted at in one tweet by one person			now "mentions_b"

def tweeted_at(tweets_array)   #note error if somebody has "@joe@" in their tweet
	mentions = []
	tweets_array.each {|tweet|
		word_array = tweet.split(/[,!.#~`$%^&*()-=+\/\[{\]}\|;:'\",<.>?\\+ \t]+/)
		mentions_b =word_array.select{|word| word[0] == "@" }
		mentions_b.each { |name|
		mentions = mentions + mentions_b
		}
	}
	return mentions
end

#returns a string referring to the number of tweet usernames one person mentioned in their tweets
def people_tweeted_at(mentions,username)
	num = mentions.uniq.length
	"#{username} tweeted at #{num} people"
end

#*****************************************************************************************
	
access_token = prepare_access_token(access_token_key, access_token_secret,consumer_key,consumer_secret)
array_of_names = tweet_file_parser(name_file)
print_all_tweets(array_of_names,access_token,tweetcount)
