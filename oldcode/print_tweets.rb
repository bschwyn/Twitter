#given an array of tweet names

def print_tweets(array_of_usernames,how_many_tweets_do_you_want)
	if how_many_tweets_do_you_want > 200
		puts "Error: Twitter will only give <200 tweets at a time"
		
	mdir
	end
	array_of_usernames.each {
		|k| #note k is a reference to the username elements
	
		#This method uses the GET statusus/user_timeline from the twitter API
		res = RestClient.get("https://api.twitter.com/1.1/statuses/user_timeline.json?
		screen_name=#{k}
		&count=#{how_many_tweets_do_you_want}")
	
		puts "the first #{how_many_tweets_do_you_want} tweets of #{k} are:"
		puts res
	}
end

