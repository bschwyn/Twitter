#This is a method that reads the names from a file of twitter handles
#and returns the name.

filename = "tweet_users.txt"

def open_file(file)
	#assuming the file is a string, data is also a string
	data = open(file,"r").read
	return data
end


def name_parser(string)
	string[0] = ''
	array_of_names = string.split("\n@")
	return array_of_names
end


test = open_file(filename)
puts name_parser(test)


#why does string.split('\n') give me the same result as
# string.split('\n@')?
#answer---because you didn't use double quotes


#Here is a larger method that takes the file and returns an array

def tweet_file_parser(file)
	string = open(file,"r").read
	string[0] = ''
	array_of_names = string.split("\n@")
	return array_of_names
end