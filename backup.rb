#!/usr/bin/env ruby

puts ARGV

def valid(argv)
  puts "needs 2 args" and return false if argv.size < 2 
  puts "needs 2 args only" and return false if argv.size > 2
  ["/mnt", "/media", "/run/media"].each do |x|
    puts "destination: #{argv[1]} not allowed" and return false if (/x/ =~ argv[1]) == 0
  end
  return true
end

def call_rsync(argv)
  it = Time.new
  
  sys_xlist = if (/\/\*/ =~ argv[0]) == 0
                '{"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"}'    
              else
                nil
              end
  
  cmd = ''
  cmd <<  'rsync -aAXv -h -P --log-file rsync.log --delete --delete-excluded '
  cmd <<  '--exclude=' << sys_xlist << ' ' if not sys_xlist.nil?
  cmd <<  argv[0] << ' ' << argv[1]

  puts cmd

  ot = Time.new

  puts "Time elapsed: #{'%.6f' % (ot-it).to_f}"
end

call_rsync(ARGV) and exit if valid(ARGV)

puts "illegal args, retry"
