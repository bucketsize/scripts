#!/usr/bin/ruby

require 'pp'

def discover ip
  `nmap -v -n -sP -PU161 #{ip} | grep -E '([0-9]{1,3}[\.]){3}[0-9]{1,3}' > /tmp/o.nmap`
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

def deepscan ip
  s=`nmap -T5 -A #{ip}`
  puts s
end

def help
  puts "net_scan help -  displayes this help"
  puts "net_scan disc <ip> - discovers network"
  puts "net_scan scan <ip> - deepscan the <ip>"
end

if ARGV.size < 1 
  help
elsif ARGV[0] == 'disc'
  discover ARGV[1]
elsif ARGV[0] == 'scan'
  deepscan ARGV[1]
end
