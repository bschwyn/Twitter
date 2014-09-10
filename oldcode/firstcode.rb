#first require the open-uri library
#This library allows the open method to open things that are not files but are url's
require "rubygems"
require "rest-client"
require "crack"
require "oauth"

def name_getter(string)
	array_of_names = string.split('\n')
	return array_of_names
end

base_url = "http://api.twitter.com/1/statuses/user_timeline.xml?count=100&screen_name="

#parameters
first_user = 1
last_user = 10
#there should be some sort of error that pops up if last_user >first user
#or last_user > the actual last user
#it would be nice if the thingy cycled Until the end, OR the last user

(first_user..last_user).each{
	|k|
	twitter_user = array_of_names[k]
	remote_full_url = base_url + twitter_user
	unparsed_website_html = RestClient.get(remote_full_url)
	parsed_website_ html = Crack::XML.parse(unparsed_website_html)
	
	
	my_local_filename = open(whatever is the output of me parsing stuff,"w")
	my_local_filename.close
	#puts "#{k}\t#{longest_tweet}\t#{otherstuff}"
	sleep 5
	}
end

#Get followers/ids
#Get friendships/lookup

#also consider something like this:
#File.open("sample.txt").readlines.each do }line}




#first I need something that takes a tweet name from the file
#opens the file, reads the name, assigns it to a variable
#then takes the variable and makes it so that it is now attatched to the URL so that stuff is being pulled from the twitter website for that user



#
	#to pull a name from the file I need to find when a name begins and when it ends
	#it begins with an @ and ends w/ a newline character
	#lets do that first with a method
	
#file = "filename"
#data_from_file = open(file) #this is a string I think

test_string = "@john\n@brian\n@newguy"


	
	
	
	
#old, not using anymore	

#I can write a method that cycles through each letter until a newline character

def name_getter_old(string)
	#this takes a string and returns the first twitter user name in it
	str = ""
	character = 0
	until string[character]=="\n" do
		str += string[character]
		character +=1
	end
	return str
end


#puts test_string[1]
#successfully returns "j"
#puts name_getter(test_string)
#successfully returns @john

#would be nice to do something  where I go through each line 

#puts name_getter(test_string)