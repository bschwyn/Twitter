# print_last_tweets_n_more.rb
# Ben Schwyn
# Last edited:  9/7/2013

#This program accesses the twitter API and prints the last n tweets from each person in a file.
#Currently it takes tweet handles from a list of usernames in the form "@joe\n@bekcy\n@samuel\n...". I want to change this so that it can pull the tweet handles out of any source file.

require "rubygems"
require "oauth"
require "json"
require "rgl/adjacency"

access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"


$PUNCTUATION = /[,!.#~`$%^&*()-=+\/\[{\]}\|;:'\",<.>?\\+ \t]+/

name_file = "bryan_caplan_network.txt" #name of file to read usernames from
tweetcount= 5 #number of tweets from each username to print
order = 2 #number of social connections away from original list


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

# takes a file of usernames,, character and returns array of usernames (no @ sign)
def tweet_file_parser(file)
	string_array = open(file,"r").readlines
	string_array.map{ |k|k[1..-2].downcase } #needs to be -1 if array only has 1, otherwise -2
end

#pareses response from twitter and puts tweets in an array
def tweets_to_array(username,token,tweetcount) #rename "getsTweetText"
	response = token.request(:get,
	"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{tweetcount}")
	result = JSON.parse(response.body)
	sleep 1
	tweets_array = result.map{ |hash|
		#When the twitter api return an error it returns an object with two things
		#-an error message and a code # instead of the larger object
		if hash.size ==2
			puts "Error: #{hash[1][0]["message"]}"
		else	
			hash["text"] #think about when to continue, but and when to raise errors and stop
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
	
	
	#array_of_usernames.each { |name|
		#tweets_array = tweets_to_array(name, token, tweetcount)
		#mentions = tweeted_at(tweets_array)
		#tweet_total = people_tweeted_at(mentions, name)

		#puts "the last #{tweetcount} tweets of #{name} are:\n\n"
		#file.puts "the last #{tweetcount} tweets of #{name} are:\n\n"

		#puts tweets_array
		#file.puts tweets_array
		#puts "\n"
		#file.puts "\n"

		#puts "#{name} mentioned these people:\n\n"
		#file.puts "#{name} mentioned these people:\n\n"
		
		#puts mentions
		#file.puts mentions
		#puts "\n"
		#file.puts "\n"
		
		#puts tweet_total
		#file.puts tweet_total
		#puts "\n"
		#file.puts "\n"
	#}
		
	rec_graph = create_rec_graph(array_of_usernames,token, tweetcount,2)
	puts "printing graph edges"
	puts rec_graph.edges
	file.close
end

# This function returns an array of people that one twitter user tweeted at
#note: need better names

#mentions ---array of all people one person tweeted at	
#mentions_b ---array of  people tweeted at in one tweet by one person	with @ sign
#mentions_c  ---mentions b w/out @ sign

def tweeted_at(tweets_array)   #note, possible error if somebody has "@joe@" in their tweet
	mentions = []
	tweets_array.each {|tweet|
		word_array = tweet.split($PUNCTUATION)
		mentions_b =word_array.select{|word| word[0] == "@" }	#words starting with @
		mentions_c =mentions_b.map{|x| x[1..-1].downcase} #chopping @
		mentions_c.each { |name|
		mentions = mentions + mentions_c
		}
	}
	return mentions
	
end
#consider SET
#extract all usernames--->Flatmap
#extract usernames from any string/array/tweets

#returns a string referring to the number of tweet usernames one person mentioned in their tweets
def people_tweeted_at(mentions,username)
	num = mentions.uniq.length
	"#{username} tweeted at #{num} people"
end

#not in use anymore

#This creates a directed adjacency graph
#there is an edge from A to B if A tweeted at B
#vertices are usernames
#second order graph

def create_graph_2(array_of_names, token, tweetcount)
	graph = RGL::DirectedAdjacencyGraph[]

	array_of_names.each {|name|
		tweets_array = tweets_to_array(name, token, tweetcount)
		mentions = tweeted_at(tweets_array)	
		mentions.map{|recipient|
			graph.add_edge(name, recipient)
		}
		mentions.each{|name|
			tweets_array = tweets_to_array(name, token, tweetcount)
			mentions = tweeted_at(tweets_array)	
			mentions.map{|recipient|
				graph.add_edge(name, recipient)
			}
		}
	}
	puts graph.edges
	return graph
end

#this is the header for  a recursive function that returns a graph object of who has tweeted at other people.
def create_rec_graph(array_of_names, token, tweetcount, order)
	graph = RGL::DirectedAdjacencyGraph[]
	depth = 0
	rec_add_edge(array_of_names, token, tweetcount, order, graph,depth)
	return graph
end

#This is a recursive function that adds edges to a graph of tweet users. Each call adds another order of social connection.
def rec_add_edge(name_array,token, tweetcount,order, graph, depth)
	#puts "the count is #{count}"
	if depth >= order
		#puts "returned graph"
		return graph
	else
		name_array.each {|name|
			tweets_array = tweets_to_array(name, token, tweetcount)
			#puts "name is #{name}"
			mentions = tweeted_at(tweets_array)
			mentions.each{ |recipient|
				if not graph.has_edge?(name, recipient) #probably a lot more inefficient than excluding vertices
					graph.add_edge(name, recipient)
					#puts "(#{name}- #{recipient})added"
				end
			}
			rec_add_edge(mentions, token, tweetcount, order, graph, depth+1)
		}
	end
end

#*****************************************************************************************	
token = prepare_access_token(access_token_key, access_token_secret, consumer_key, consumer_secret)
array_of_names = tweet_file_parser(name_file)
print_all(array_of_names, token, tweetcount)
puts "end of program"