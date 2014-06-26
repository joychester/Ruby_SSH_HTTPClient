require 'net/ssh'
require 'date'
require 'httpclient'

C3_SSH_HOST="10.WW.EEE.XXX"
C3_SSH_Loginname="XXX"
C3_SSH_PWD="XXXXXXX"

currentDate = Date.today
currentDateStr = currentDate.to_s

result_dev = ""
result_qe = ""

QADash_URL = "http://qahub.mycorp.dev:8000/getlines"

client=HTTPClient.new

Net::SSH.start(C3_SSH_HOST,C3_SSH_Loginname,:password => C3_SSH_PWD) do |ssh|

    result_dev = ssh.exec!('./countlines.sh p4list.txt')

    result_qe = ssh.exec!('./countlines_qe.sh p4list_qe.txt')
	
end

result_dev.each_line  do |row| 
		puts row
		temp = row.split('=>')
		case temp[0]
			when '/home/cchi/mycorp/source/depot/main/reorganized_code'					   
				repo = 'depot_main'
			when '/home/cchi/mycorp/source/mycorp/domain'					   
				repo = 'mycorp_domain'
			else
		end
		lines = temp[1].chomp.to_i

		puts "HTTPClient POST method start"
		post_body = { :tag => repo, :path => temp[0], :lines => lines, :cdate => currentDateStr}
		client.post(QADash_URL, post_body)
		puts "HTTPClient POST method end!"
end

result_qe.each_line  do |row| 
		puts row
		temp = row.split('=>')
		case temp[0]
			when '/home/cchi/mycorp/source/mycorp/qe'					   
				repo = 'mycorp_qe'
			else
		end
		lines = temp[1].chomp.to_i

		puts "HTTPClient POST method start"
		post_body = { :tag => repo, :path => temp[0], :lines => lines, :cdate => currentDateStr}
		client.post(QADash_URL, post_body)
		puts "HTTPClient POST method end!"
end
