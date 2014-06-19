class StatusController < ApplicationController

 	def index		
 		d = Disktools.new
 		@devices = d.availMounted
	end
		
	def update
		d = Disktools.new
		if params[:mountpoint]
			cmd="umount "+params[:mountpoint]
			system(cmd)
			cmd="rmdir "+params[:mountpoint]
			system(cmd)
			@devices = d.availMounted
	    	redirect_to status_url, notice: params[:devname]+" unmounted"
		else
			cmd="mkdir /mnt/"+params[:uuid]+"&&mount " +params[:devname]+" /mnt/"+params[:uuid]
			system(cmd)
			@devices = d.availMounted
		    redirect_to status_url, notice: params[:devname]+" mounted on "+@devices.find { |h| h[:devname] == params[:devname] }[:mountpoint]
		end		
	end
end
