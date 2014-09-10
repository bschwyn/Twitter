name = "JLo"
x = ["jlo", "JLo","asdf", "odin","asd"]
puts "jlo".casecmp("JLo")== 0
puts "JLo".casecmp("JLo")==0

puts "loop thingy now"
x.each{|thingy|
	puts "#{thingy} being tested"
	if thingy.casecmp("JLo")==0
		puts "#{thingy} was the same as JLo"
		x.delete(thingy)
	else
		puts "#{thingy} was not the same as JLo"
	end
	puts x.join(', ')
	}

#puts "qwertyuiopasdfghjklzxcvbnm"==casecmp("QWERTYUIOPASDFGHJKLZXCVBNM")