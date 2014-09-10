require "rubygems"
require "rest-client"
#require "crack"



remote_base_url = "http://api.twitter.com/1/statuses/user_timeline.xml?count=100&screen_name="
twitter_user = "USAGov"
remote_full_url = remote_base_url + twitter_user

puts remote_full_url
wtfisthis = RestClient.get(remote_full_url)
#this_works= RestClient.get("http://en.wikipedia.org/wiki")
#puts twitter_html.code
#parsed_twitter_html = Crack::JSON.parse(twitter_html)

#puts parsed_twitter_html


