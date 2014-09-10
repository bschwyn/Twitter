require "rubygems"
require "oauth"
require "json"

akey = access_token_key = "1090906981-hyHtAhkXVVkGu5mBjMHoEV5LxH3uepU9NAQ8RkA"
asecret = access_token_secret = "uB9C48ttAdygfKYjTik3ED9Sy4lQaekouASA18jM"

ckey = consumer_key = "vXpPW8VN0Bm9zKUjA8M0FA"
csecret = consumer_secret = "ST5t1LDjXj0v666Trua3I9HfNhb83efn8mzrGeQ143A"


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
			
#Exchange our oauth_token and oauth_token secret for the AccessToken instance.
access_token = prepare_access_token(access_token_key, access_token_secret,consumer_key,consumer_secret)


def print_tweets(number_of_tweets, username,access_token)
	response = access_token.request(:get,"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=#{username}&count=#{number_of_tweets}")
	result = JSON.parse(response.body)
	puts "the first #{number_of_tweets} tweets of #{username} are:\n\n"
	(1..number_of_tweets).each {|k|
	puts "#{k})"+result[k-1]["text"] + "\n\n"
	}
end

print_tweets(3, "twitter",access_token)

puts "******************"
response = access_token.request(:get,"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=USAGov&count=10")
result = JSON.parse(response.body)
puts result
puts "the first 10 tweets of USAGov are:\n\n"
#(1..10).each {|k|
#	puts "#{k}) "+result[k-1]["text"] + "\n\n"
#	}