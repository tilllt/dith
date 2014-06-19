class Disktools
	include Sys

	def self.availFS
	return %w(ext3 ext2 ext4 cramfs vfat msdos exfat hfsplus)
	end
	
	def merge_hashes_with_equal_values(array_of_hashes, key)
		# http://stackoverflow.com/questions/17409744/
  		array_of_hashes.sort { |a,b| a[key] <=> b[key] }.
    	chunk { |h| h[key] }.
    	each_with_object([]) { |h, result|  result << h.last.inject(&:merge) }
	end
	
	
	
	def availMounted
		avail = merge_hashes_with_equal_values(availDev + devMounted, :devname)
		fsmatch = avail.find_all {|d| d[:type].in? AVAILFS }
		return fsmatch
	end	

	def availDev
		devices = []
			`blkid -o export`.split(/\n\n/).each do |zeile|
				device={}
					zeile.split(/\n/).each do |pair|
						eachdev=pair.split("=")
						device[eachdev[0].downcase.to_sym] = eachdev[1]		
					end
			devices.push(device)
			end
			return devices
	end

	def devMounted
		mounted = []
			`mount`.split(/\n/).each do |zeile|
				mount={}
				mountArray = zeile[0...-1].split(/ on | type | \(/)
				mount[:devname] = mountArray[0]
				mount[:mountpoint] = mountArray[1]
				mount[:type] = mountArray[2]
				mount[:options] = mountArray[3]
				mounted.push(mount)
			end
			mounted.each do |space|
				fs = Filesystem.stat ('/')
				space.store(:blocksize, fs.block_size)
				space.store(:blocksfree, fs.blocks_free)
				space.store(:blocksavailable, fs.blocks_available)
			end
			return mounted
	end

	def mount (devname, fstype='', options='')
		#http://stackoverflow.com/questions/10584326/
	    uuid = availDev.find { |h| h[:devname] == devname }['uuid'];
	 	cmd='mount' + devname + ` `+ uuid
	 	if fstype 
	 		cmd = cmd+' -t'+fstype
	 	end
	 	if options 
	 		cmd = cmd+' -o'+options 
	 	end
	 return cmd;
	end
	
	def unmount (mountpoint)
	end
	
	def format
	end
	
	def setLabel
	end
end
