#dinking around with rest-client

require "rubygems"
require "rest-client"
require 'json'
require 'open-uri'

test1 = RestClient.get("https://www.ruby-toolbox.com/projects/rest-client")
test2 = open("https://www.ruby-toolbox.com/projects/rest-client")

puts test2
#puts test1.body

#jsontest = JSON.parse(test1)

#puts test1.code
#200
#puts test1.headers[:server]
#nginx/1.4.2 I don't know what this is
#puts test1