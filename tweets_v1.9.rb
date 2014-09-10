# print_last_tweets_n_more.rb
# Ben Schwyn
# Last edited:  9/7/2013

#This program accesses the twitter API and prints the last n tweets from each person in a file.
#Currently it takes tweet handles from a list of usernames in the form "@joe\n@bekcy\n@samuel\n...". I want to change this so that it can pull the tweet handles out of any source file.

#***version history***
#1.0
#1.1
#1.2
#1.3
#1.4
#1.5
#1.6
#1.7 changed a tweets_at name. Hopefully made program stop doing stuff when it reaches certain errors.
#1.8 Added version history, can now read usenames from any file. changed name of tweets_to_array to getsTweetText
	#note: It would be nice to use a program that showed me when i accidentally deleted entire lines
#1.9 changed structure of print_all, replaced "people_tweeted_at" with a function from RGL.
	#added print number of cycles, added abort to error/escape thing
	
#things to do:
#Add graph queries
#How many times did person A mention person B?
#Make a visual representation
#???store multiple different things in the graph structure so that each name has both tweets and tweet-recipients attached
#rather than storing stuff in a file as a list, add formatting such as tabs Store it in columns:
	#example: "username" \t "number of people tweeted at" \t "Number of 2nd order people" "number of 3rd order people" \t "most retweeted tweet" "etc"

#This was a suggestion for the fileparser thingy.
#consider SET
#extract all usernames--->Flatmap
#extract usernames from any string/array/tweets

require "rubygems"
require "oauth"
require "json"
require "rgl/adjacency"
require "rgl/dot"
require "graphviz"

access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"


$PUNCTUATION = /[,!.#~`$%^&*()-=+\/\[{\]}\|;:'\",<.>?\\+\n \t]+/

name_file = "test_tweeters_ignore_format.txt" #name of file to read usernames from
tweetcount= 3 #number of tweets from each username to print
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

def file_open(file)
	array = open(file,"r").readlines
	gets_username(array)
end

#pareses response from twitter and puts tweets in an array
def getsTweetText(username,token,tweetcount)
	response = token.request(:get,
	"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{tweetcount}")
	result = JSON.parse(response.body)
	sleep 1
	tweets_array = result.map{ |hash|
		#When the twitter api return an error it returns an object with two things
		#-an error message and a code # instead of the larger object
		if hash.size ==2
			puts "Error: #{hash[1][0]["message"]}"
			if hash[1][0]["code"] !=34
				abort("program ended prematurely\nError: #{hash[1][0]["message"]}") #find documentation about abort
			end
		else
			hash["text"] #think about when to continue, but and when to raise errors and stop
		end
	}
end



# creates file, and prints the results of different methods
def print_all(array_of_usernames, token,tweetcount,order)
	if tweetcount > 200
		return puts "Error: Twitter will only give max 200 tweets at a time"
	end
	
	newfile = "tweet_output2.txt"
	file = File.open(newfile,"w")
	
	graph = create_rec_graph(array_of_usernames,token, tweetcount,order)
	puts "printing graph edges"
	puts graph.edges
	
	cycles = graph.cycles() #returns an array of minimum cycles
	p cycles #should I find a way to 'print' print this?
	puts "the number of cycles is #{cycles.size}"
	
	
	array_of_usernames.each { |name|
		tweets_array = getsTweetText(name, token, tweetcount)
		mentions = gets_username(tweets_array)
		tweet_total = graph.out_degree(name)

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
		
		puts "#{name} tweeted at #{tweet_total} unique users\n"
		#file.puts tweet_total
		#puts "\n"
		#file.puts "\n"
	}
		
	
	graph.write_to_graphic_file('png', "graphfile" )
	#gvRender(
	file.close
end



# This function returns an array of people that one twitter user tweeted at

#mentions ---array of all people one person tweeted at	
#mentions_b ---array of  people tweeted at in one tweet by one person	with @ sign
#mentions_c  ---mentions b w/out @ sign

def gets_username(array)   #does not detect a split if there is no punctuation before @sign.  adfkjklj@joe does not add @joe. @joe@joe2 returned "could not authenticate you" error
	mentions = []
	array.each {|line|
		word_array = line.split($PUNCTUATION)
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


#This creates a directed adjacency graph
#there is an edge from A to B if A tweeted at B
#vertices are usernames
#second order graph

def create_graph_2(array_of_names, token, tweetcount)
	graph = RGL::DirectedAdjacencyGraph[]

	array_of_names.each {|name|
		tweets_array = getsTweetText(name, token, tweetcount)
		mentions = gets_username(tweets_array)	
		mentions.map{|recipient|
			graph.add_edge(name, recipient)
		}
		mentions.each{|name|
			tweets_array = getsTweetText(name, token, tweetcount)
			mentions = gets_username(tweets_array)	
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
			tweets_array = getsTweetText(name, token, tweetcount)
			#puts "name is #{name}"
			mentions = gets_username(tweets_array)
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
puts "preparing token"
token = prepare_access_token(access_token_key, access_token_secret, consumer_key, consumer_secret)
puts "opening file"
array_of_names = file_open(name_file)

print_all(array_of_names, token, tweetcount,order)
puts "end of program"
