# print_last_tweets_n_more.rb
# Ben Schwyn
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

name_file = "mom.txt" #name of file to read usernames from
tweetcount= 5 #number of tweets from each username to print


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
	string_array.map{ |k|k[1..-1] }
end

#pareses response from twitter and puts tweets in an array
def tweets_to_array(username,token,tweetcount)
	response = token.request(:get,
	"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{tweetcount}")
	result = JSON.parse(response.body)
	sleep 1
	tweets_array = result.map{ |hash|
		if hash.size ==2
			puts "Error: #{hash[1][0]["message"]}"
		else	
			hash["text"]
		end
	}
end

# creates file, and prints the results of different methods
def print_all(array_of_usernames, token,tweetcount)
	if tweetcount > 200
		return puts "Error: Twitter will only give max 200 tweets at a time"
	end
	
	newfile = "tweet_output2.txt"
	file = File.open(newfile,"w")
	
	
	array_of_usernames.each { |name|
		tweets_array = tweets_to_array(name, token, tweetcount)
		mentions = tweeted_at(tweets_array)
		tweet_total = people_tweeted_at(mentions, name)

		puts "the last #{tweetcount} tweets of #{name} are:\n\n"
		file.puts "the last #{tweetcount} tweets of #{name} are:\n\n"

		puts tweets_array
		file.puts tweets_array
		puts "\n"
		file.puts "\n"

		puts "#{name} mentioned these people:\n\n"
		file.puts "#{name} mentioned these people:\n\n"
		
		puts mentions
		file.puts mentions
		puts "\n"
		file.puts "\n"
		
		puts tweet_total
		file.puts tweet_total
		puts "\n"
		file.puts "\n"
	}
	#puts "This should be a first order graph of bryan_caplan's message recipients"
	#graph = create_big_graph_1(array_of_usernames, token, tweetcount)
	#puts "\n"
	#puts "This should be a second order graph of bryan_caplan's recipients and their recipients"
	r#ec_graph = create_rec_graph(array_of_usernames,token, tweetcount,2)
	
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
		word_array = tweet.split($PUNCTUATION)
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


#This creates a directed adjacency graph
#vertices are usernames
#there is an edge from A to B if A tweeted at B
def create_big_graph_2(array_of_names, token, tweetcount)
	graph = RGL::DirectedAdjacencyGraph[]

	array_of_names.each {|name|
		tweets_array = tweets_to_array(name, token, tweetcount)
		mentions = tweeted_at(tweets_array)	
		mentions.map{|recipient|
			graph.add_edge(name, recipient)
		}
		mentions.each{|name|
			tweets_array = tweets_to_array(name[1,-1], token, tweetcount)
			mentions = tweeted_at(tweets_array)	
			mentions.map{|recipient|
				graph.add_edge(name, recipient)
			}
		}
	}
	puts graph.edges
	return graph
end

def create_big_graph_1(array_of_names, token, tweetcount)
	graph = RGL::DirectedAdjacencyGraph[]

	array_of_names.each {|name|
		tweets_array = tweets_to_array(name, token, tweetcount)
		mentions = tweeted_at(tweets_array)	
		mentions.map{|recipient|
			graph.add_edge(name, recipient)
		}
	}
	puts graph.edges
	return graph
end

def create_rec_graph(array_of_names, token, tweetcount, order)
	graph = RGL::DirectedAdjacencyGraph[]
	rec_add_edge(array_of_names, token, tweetcount, order, graph)
	puts graph.edges
end

#Here is my attempt to right a recursive function that does the same thing as the stuff inside create_big_graph
#order is the order of connections (first order connections, second order connections)
def rec_add_edge(name_array,token, tweetcount,order, graph)
	count = 0
	if count == order
		puts "count is equal to #{count}\n order is equal to #{order}"
		return graph
	else
		count=count+1
		name_array.each {|name|	
			tweets_array = tweets_to_array(name, token, tweetcount)
			mentions = tweeted_at(tweets_array)	
			mentions.map{|recipient|
				graph.add_edge(name, recipient)
			}
			rec_add_edge(name_array, token, tweetcount, order-1, graph)
		}
	end
end

#*****************************************************************************************	
token = prepare_access_token(access_token_key, access_token_secret, consumer_key, consumer_secret)
array_of_names = tweet_file_parser(name_file)
print_all(array_of_names, token, tweetcount)
