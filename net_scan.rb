#!/usr/bin/ruby

require 'pp'

def discover
  `nmap -v -n -sP -PU161 192.168.2.1/24 | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' > /tmp/o.nmap`
  s=`cat /tmp/o.nmap`
  s.split('Nmap').each do |l|
    #puts 'line: '+l
    m = (l =~ /down/)
    #puts 'match: ' + m.to_s
    if m.nil? and not l.empty?
      h = l.split(/\s/).last
      puts h
    end
  end
end

def deep_scan ip
  s=`nmap -T5 -A #{ip}`
  puts s
end

if ARGV.size < 1 
  discover
else
  deep_scan ARGV[0]
end
