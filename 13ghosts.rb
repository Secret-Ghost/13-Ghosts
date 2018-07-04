#---needed gems---#
#gem install tempfile
#gem install colorize

#--use -i to investigate shares 

#ruby scanner.rb -i 5000

#--- run without -i to scan and log only

require 'tempfile'
require 'colorize'



puts'                      :::!~!!!!!:.'
puts'                   .xUHWH!! !!?M88WHX:.'
puts'                 .X*#M@$!!  !X!M$$$$$$WWx:.'
puts'                :!!!!!!?H! :!$!$$$$$$$$$$8X:'
puts'               !!~  ~:~!! :~!$!#$$$$$$$$$$8X:'
puts'              :!~::!H!<   ~.U$X!?R$$$$$$$$MM!'
puts'              ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!'
puts'                !:~~~ .:!M"T#$$$$WX??#MRRMMM!'
puts'                ~?WuxiW*`   `"#$$$$8!!!!??!!!'
puts'              :X- M$$$$       `"T#$T~!8$WUXU~'
puts'             :%`  ~#$$$m:        ~!~ ?$$$$$$'
puts'           :!`.-   ~T$$$$8xx.  .xWW- ~""##*"'
puts' .....   -~~:<` !    ~?T#$$@@W@*?$$      /`'
puts' W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :'
puts' #"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`'
puts' :::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~'
puts' .~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `'
puts' Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!'
puts' $R@i.~~ !     :   ~$$$$$B$$en:``'
puts' ?MXT@Wx.~    :     ~"##*$$$$M~'
puts'      Thirteen'
puts'     ▄████  ██░ ██  ▒█████    ██████ ▄▄▄█████▓  ██████ '
puts'    ██▒ ▀█▒▓██░ ██▒▒██▒  ██▒▒██    ▒ ▓  ██▒ ▓▒▒██    ▒ '
puts'   ▒██░▄▄▄░▒██▀▀██░▒██░  ██▒░ ▓██▄   ▒ ▓██░ ▒░░ ▓██▄   '
puts'   ░▓█  ██▓░▓█ ░██ ▒██   ██░  ▒   ██▒░ ▓██▓ ░   ▒   ██▒'
puts'   ░▒▓███▀▒░▓█▒░██▓░ ████▓▒░▒██████▒▒  ▒██▒ ░ ▒██████▒▒'
puts'    ░▒   ▒  ▒ ░░▒░▒░ ▒░▒░▒░ ▒ ▒▓▒ ▒ ░  ▒ ░░   ▒ ▒▓▒ ▒ ░'
puts'     ░   ░  ▒ ░▒░ ░  ░ ▒ ▒░ ░ ░▒  ░ ░    ░    ░ ░▒  ░ ░'
puts'   ░ ░   ░  ░  ░░ ░░ ░ ░ ▒  ░  ░  ░    ░      ░  ░  ░  '
puts'         ░  ░  ░  ░    ░ ░        ░                 ░  '
puts ''                                                      




$i =  0
investigat = 'none'

if ARGV.length < 2
iR = ARGV[0].to_s
investigate = 'none'
else
investigate = ARGV[0].to_s 
iR = ARGV[1].to_s
end


puts 'INVESTIGATE ' + investigate.to_s
puts 'iR ' + iR.to_s
out_file = File.new('outshares.txt', "a")


def capture_stdout
  stdout = $stdout.dup
  Tempfile.open 'stdout-redirect' do |temp|
    $stdout.reopen temp.path, 'w+'
    yield if block_given?
    $stdout.reopen stdout
    temp.read
  end
end



msg = 'Running nmap scan for samba port 139 shares'

4.times do
  print "\r#{ msg }".green
  sleep 0.5
  print "\r#{ ' ' * msg.size }"
  sleep 0.5
  print "\r#{ msg }".green
  sleep 0.5
end

captured_content = capture_stdout do
 
system  " nmap -iR " + iR  + " -PN -p 139  --open   "

end

puts 'Nmap scan complete'.green
puts ''

#puts captured_content.to_s

if captured_content.include? "tcp open"
puts 'Succes, shares available for scanning!'.green
puts ''

else
puts 'Nmap did not find any samba shares, try again :).'.red
puts ''

end

captured_content.gsub(/[0-9]+(?:\.[0-9]+){3}+/i) do |ip|
puts 'Checking samba status for: '.green + ip.red
puts ''
captured_content2 = capture_stdout do
system " proxychains   nmblookup -A " +  ip
end




if captured_content2.include? "MAC Address"
puts captured_content2.to_s.green
out_file.puts( "########################################################")
out_file.puts(captured_content2.to_s)
if investigate.include? "-i"


captured_content2.gsub(/(.*)<00>/i) do |theshare|
$i +=1
puts '#' + $i.to_s + ': ' +   theshare

end

captured_content2.gsub(/(.*)<03>/i) do |theshare|
$i +=1
puts '#' + $i.to_s + ': ' +   theshare
end

captured_content2.gsub(/(.*)<1d>/i) do |theshare|
$i +=1
puts '#' + $i.to_s + ': ' +   theshare
end

captured_content2.gsub(/(.*)<1e>/i) do |theshare|
$i +=1
puts '#' + $i.to_s + ': ' +   theshare
end

captured_content2.gsub(/(.*)<20>/i) do |theshare|
$i +=1
puts '#' + $i.to_s + ': ' +   theshare
end
$i = 0
puts ''
puts'Select a share by name or use skip to check the next share instead'.yellow
puts ''

option = STDIN.gets.chomp

if option.include? "skip" 
puts 'Skipping..'
else

captured_content3 = capture_stdout do
system 'proxychains   smbclient -L //' + option.strip + ' -I ' + ip + ' -N'
 
end 

puts captured_content3.to_s
puts ''

captured_content3.gsub(/(.*)Disk/i) do |theshare|
$i +=1
puts '#' + $i.to_s + ': ' +   theshare
end


out_file.puts(captured_content3.to_s)


if captured_content3.include? "failed"  
puts 'Failed, moving on..'
puts ''
else
puts 'Please select where to mount from above. Note: you will drop into smb>'.yellow
option2 = STDIN.gets.chomp
system 'proxychains -q smbclient  //' + option.strip + '/' + option2.strip + ' -I ' + ip + ' -N'
 
end

$i =0

end


end
else
puts 'The share at: '.red + ip.to_s.green + ' did not respond.'.red
puts ''
 
 
end

end
puts ''
puts 'Finished scanning shares.'.green
out_file.close
 

