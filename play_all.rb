#!/usr/sbin/env ruby    

a = ARGV
f = `ls`

f.split(/\n/).each do |fn|
  fn = fn
    .gsub(/ /, '\ ')
    .gsub(/\(/, '\(')
    .gsub(/\)/, '\)')
  cmd = 'mplayer '+fn
  puts
  puts
  puts '------------ playing -------------'
  puts cmd
  status=system(cmd)
end
