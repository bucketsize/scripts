#!/usr/bin/ruby 
# ps_mem.rb
# print mem / process in ascending order of mem
# @author jb

def lexpand(str, len)
	" "*(len-str.size)+str
end

def report_mem_usage()
	list = `ps -e -o rss -o args k rss | sed 's/^\s*//'`
	list.split("\n").each do |x|
		a=x.split(" ")
		next if (a[1] == 'COMMAND' or a[0].to_i == 0)
		mem=( (1.0/1024) * a[0].to_i).round(3)
		prg=File.basename(a[1])
		puts "#{lexpand(mem.to_s, 8)} M\t#{prg}"
	end
end

report_mem_usage
