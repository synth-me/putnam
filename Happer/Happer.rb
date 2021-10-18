class Engine

	def merge_file(a,b)
		af = (File.read a).split("\n")
		bf = File.read b

		af.each do |line|
			indx = af.find_index(line)
			if line.match(/({- slot -})/)
				af.insert(indx,bf)
				break
			end
		end 
		aj = af.join("\n")
		file_w = File.open(a,"w")
		file_w.write(aj)
		file_w.close()
	end 

	def merge_chunk(a,chunk)
		af = (File.read a).split("\n")
		af.each do |line|
			indx = af.find_index(line)
			if line.match(/({- slot -})/)
				af.insert(indx,chunk)
				break
			end
		end 
		aj = af.join("\n")
		file_w = File.open(a,"w")
		file_w.write(aj)
		file_w.close()
	end 

end 

class Putnam
	
	def initialize 
		@index = {}
	end 
	
	def defp(name,&block)
		# here we define the structure as file 
		# interchanging so one file will enter in
		# another one 
		c = Internals1.new(name).instance_eval &block
		i = {mode:0 , command: c}
		@index[name] = i 
	end 
	
	def defc(name,&block)
		# here we define the new structure by sending 
		# code chunks to it not files 
		c = Internals2.new(name).instance_eval &block
		i = {mode:1 ,command: c}
		@index[name] = i  				 
	end 

	def do_run(name)
		info = @index[name]
		extension = File.expand_path('../putnam.ls', __dir__)
		if info[:mode] == 0
			system("lsc",extension,"--run",info[:command][:src_name],info[:command][:rule_name])
		else
			lines = info[:command][:chunk].split("\n")
			rule = info[:command][:rule_name]
			lines.each do |a|
				unless a == ""
					system("lsc",extension,"--run-l",a,rule)
				end
			end
		end 
	end 

	def do_merge(name)
		info = @index[name]
		if info[:mode] == 0
			file0 = info[:command][:src_name]
			file1 = info[:command][:file_name]
			Engine.new.merge_file file0, file1		
			puts "Sucessfully merged #{file0} with #{file1}"						
		else
			file = info[:command][:file_name]
			Engine.new.merge_chunk file, info[:command][:chunk]
			puts "Sucessfully merged the chunk with #{file}"
		end 
	end 

end

class Internals1

	attr_accessor :group
	
	def initialize(group)
		@files = {}
	end

	def source(file)
		# here we spawn the file that the changes
		# may come from
		@files[:src_name] = file
	end				

	def target(file)
		# here we spawn the file that will receive 
		# all the changes commited
		@files[:file_name] = file
	end

	def given(rule_name,&block)
		# here we instatiate and create the rules that must be
		# followed by the new code 
		rule_name 
		r = RuleMaker.new.instance_eval &block
		@files[:rule_name] = r
		return @files 
	end 
	
end 

class Internals2

	attr_accessor :group

	def initialize(group)
		@files = {}
	end

	def chunk(text)
		# here we spawn the file that the changes
		# may come from 
		@files[:chunk] = text  
		return text
	end
									
	def target(file)
		# here we spawn the file that will receive 
		# all the changes commited
		@files[:file_name] = file
		return file
	end

	def given(rule_name,&block)
		# here we instatiate and create the rules that must be
		# followed by the new code 
		rule_name 
		r = RuleMaker.new.instance_eval &block
		@files[:rule_name] = r
		return @files
	end 
							
end 

class RuleMaker
	
	def initialize
		@rules
	end 

	def forallT(*enter,exit)
		e = enter.map do |x|
			x = x+" ->"
		end
		e << exit
		e.insert(0,"forall T.")
		w = e.join(" ")
		return w 
	end 

end 

f = File.read ARGV[0]
p = Putnam.new 
p.instance_eval f 


# eof 
