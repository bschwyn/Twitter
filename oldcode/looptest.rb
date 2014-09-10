#for k in 1..100 do
 #  puts "#{k}. This is not as fun the each construct"
#end

#(1..100).each do |k|
  # puts "#{k}. This is Ruby preferred way of doing loops, when possible"
#end                  

#(1..100).each{ |k| puts "#{k}. Curly braces make it even shorter"}

array = ["three","2","dasd3",4,"5asdf","adsf6",7,8,9,"10asdfasd"]

array.each { |k| puts k}