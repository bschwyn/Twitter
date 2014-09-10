#ignore header and footer of table

table = "Name, Profit, loss
James,100,12
Bob,20,42
Sara,50,0
Totals 170 (54)"

table2 = table.split("\n")

puts table2[1..3]