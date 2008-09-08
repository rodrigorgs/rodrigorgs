require 'java'
require 'net/ssh'

import 'com.xerox.amazonws.ec2.Jec2'
import 'com.xerox.amazonws.ec2.ReservationDescription'
import 'com.xerox.amazonws.ec2.LaunchConfiguration'

# Input
numInstances = 0
imageId = ''
awsAccessKeyId = ''
secretAccessKey = ''
keyFilename = ''
keyName = ''
###

# http://www.jcraft.com/jsch/examples/Exec.java

class ReservationDescription::Instance
	attr_accessor :peer_deployed, :worker_deployed	

	def run_ssh
		# TODO return channel
		Net::SSH.start(self.getDnsName, 'root', 
				:auth_methods => ['public_key'], 
				:keys => [keyFilename]) do |ssh| 
			ssh.open_channel do |ch|
				yield ch
			end
		end
	end

	def addWorkers array
		run_ssh ...
	end

	def deployPeer
		# TODO throw exception if it's not running
		run_ssh do |ssh|
			ssh.exec 'wget ...; tar xzf ...' {}
			ssh.exec 'cd peer; bin/peer start' {}
		end
		@peer_deployed = true
	end

	def deployWorker(peer)
		run_ssh do |ssh|
			ssh.exec 'wget ...; tar xzf ...' {}
			ssh.exec 'cd mygrid; ./useragent start' {}

			ssh.exec 'apt-get install at' {}
			ssh.exec 'echo "shutdown -h now" | at now + X min' {}
			# TODO: number of minutes
		end
		
		@worker_deployed = true
	end
end

def describe(jec2, instances)
	ec2.describeInstances(
			instances.map{ |i| i.getInstanceId }.to_java(:string)).getInstances
end

ec2 = Jec2.new(awsAccessKeyId, '') #secretAccessKey)
launchCfg = LaunchConfiguration.new(imageId, numInstances, numInstances)
launchCfg.setKeyName keyName
launchCfg.setUserData 'byte[] userData'

reservation = ec2.runInstances launchCfg

instances = reservation.getInstances

# deploy peer
numRunning = 0
until instances.any? { |x| x.isRunning }
	# sleep ...
	instances = describe ec2, instances # not sure if it's needed
end
peer = instances.find { |x| x.isRunning }
peer.deployPeer

# Callback code that will add peer to the gdf and call "mygrid setgrid ..."
# TODO: verify if we benefit from new workers added to a peer 

# deploy workers
begin
	# sleep ...
	instances = describe ec2, instances # not sure if it's needed

	to_deploy = instances.select { |x| x.isRunning && !x.worker_deployed }
	to_deploy.each do |inst|
		inst.deployWorker(peer)
	end
	peer.addWorkers to_deploy
end until instances.all? { |x| x.isRunning && x.worker_deployed }

