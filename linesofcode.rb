require 'net/ssh'
require 'date'
require 'httpclient'

C3_SSH_HOST="10.WW.EEE.XXX"
C3_SSH_Loginname="XXX"
C3_SSH_PWD="XXXXXXX"

result_dev, result_qe = ""

QADash_URL = "http://qahub.mycorp.dev:8000/getlines"

Net::SSH.start(C3_SSH_HOST,C3_SSH_Loginname,:password => C3_SSH_PWD) do |ssh|

    result_dev = ssh.exec!('./countlines.sh p4list.txt')

    result_qe = ssh.exec!('./countlines_qe.sh p4list_qe.txt')
	
end

def post_line_of_code(folder_type)
	currentDate = Date.today.to_s
	client=HTTPClient.new
	
	folder_type.each_line  do |row| 
		temp = row.split('=>')
		case temp[0]
			when '/home/cchi/mycorp/source/depot/main/reorganized_code'
				repo = 'depot_main'
			when '/home/cchi/mycorp/source/mycorp/domain'
				repo = 'mycorp_domain'
			when '/home/cchi/mycorp/source/mycorp/qe'
				repo = 'mycorp_qe'
			else
		end
		lines = temp[1].chomp.to_i

		p "HTTPClient POST method start"
		post_body = { :tag => repo, :path => temp[0], :lines => lines, :cdate => currentDate}
		client.post(QADash_URL, post_body)
		p "HTTPClient POST method end!"
	end
end

post_line_of_code(result_dev)
post_line_of_code(result_qe)
