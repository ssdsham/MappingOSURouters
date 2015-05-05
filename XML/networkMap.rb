/*
 * Sham Dorairaj
 * Spring 2014 - Network Programming
 */
 

require "csv"
require "nokogiri"
require "matrix"

inputFile = File.open("input/megascan.xml") 
doc = Nokogiri::XML(inputFile) { |s| s.noblanks }

csvNodes = File.open("output/nodes.csv", "w")
csvNodes.puts "nid,ip,name"

csvRels = File.open("output/rels.csv", "w")
csvRels.puts "parent,child,rtt"

attrHost=doc.xpath("//host")
attrName=doc.xpath("//host/hostnames/hostname")
attrTrace=doc.xpath("//host/trace")
attrHop=doc.xpath("//host/trace/hop")

# Master Array of IP, Names and RTT, Visited (bool)
totalHosts =  attrHop.count
hostMatrix = Matrix.build(4,totalHosts) {|row, col| 0 }


for i in 0..totalHosts-1
	hostMatrix.send(:[]=,0,i,"#{attrHop[i].values[0]}") # RTT
	hostMatrix.send(:[]=,1,i,"#{attrHop[i].values[1]}") # host
	hostMatrix.send(:[]=,2,i,"#{attrHop[i].values[2]}") # IP
	hostMatrix.send(:[]=,3,i,"F") # Visited?
end

nodes = []
for i in 0..totalHosts-1
	n = [hostMatrix[2,i],hostMatrix[1,i]]
	nodes.push n
end

uniqNodes = nodes.uniq
for i in 0..uniqNodes.count-1
	csvNodes.puts i.to_s + "," +uniqNodes[i][0] + "," +uniqNodes[i][1]
end
csvNodes.close

csvInput = CSV.read("output/nodes.csv", headers:true)
#p csvInput['ip'][1]

for i in 1..uniqNodes.count-1
	for j in 1..totalHosts-1
		if csvInput['ip'][i]==attrHop[j].values[2]
			csvRels.puts "#{attrHop[j-1].values[2]},#{csvInput['ip'][i]},#{attrHop[j].values[0]}"
		end
	end
end
csvRels.close

temp = []
final = []
a = Array.new
CSV.foreach("output/rels.csv") do |csvInput|
	temp.push csvInput
end
 #puts temp.count
 final = temp.uniq
 #p final



CSV.open("output/rels.csv", "w") do |csv| #
	final.each do |row|
		csv << row
	end
end
puts "parse complete"
