def longest_tweet(anArray, file)
	max_length =  anArray.max_by(&: length).length
	all_with_max_length = anArray{ |x| x.length = max_length}

	puts "the longest tweet has #{max_length} characters"
	file.puts "the longest tweet has #{max_length} characters"
	
	puts all_with_max_length
	file.puts all_with_max_length
end