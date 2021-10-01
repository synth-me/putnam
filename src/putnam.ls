fs        		= require \fs
diff      		= require \diff
colors 	  		= require \colors
{ sleep } 		= require \sleep
{ run-loading } = require "./spin.ls"
{ Str, map, filter, elem-index, Func, last, tail, Obj, all, join, any, first,drop, break-list, flatten} = require \prelude-ls

IO = 
	puts       : console.log 
	line       : map -> console.log it
	read       : -> 
					try 
						fs.readFileSync it, \utf-8 
					catch 
						throw new Error "Could not open #{it}".red 
	folder 	   : -> 
					try 
						fs.readdirSync it
					catch 
						throw new Error "Could not open #{it}".red
	lineFail  : -> throw new Error "Not enough arguments passed".red
	cmdFail   : -> throw new Error "Command not recognized".red
	regexFail : -> throw new Error "Could not parse your chunk or its's absent".red
	absent	  : -> throw new Error "There's no chunk to be parsed".red

check = 
	p0 : (isnt /(node.exe)$/)
	p1 : (isnt /(lsc)$/)
		
left-add = Func.curry (+)
		
parser = (chunk) -> 
	chunk 
		|> ->
			| it is undefined => IO.absent!
			| _    		  	  => it 
		|> (is /^(forall T.) [a-zA-Z0-9]{1,} -> [a-zA-Z0-9]{1,}(( -> [a-zA-Z0-9]{1,})?){0,}/)
		|> ->
			| !it => IO.regexFail!
			| it  => chunk 
		|> Str.split "forall T. "
		|> last  
		|> left-add ":: "
		
findTypes = Func.curry (eq,text) -> 
		
	regex = new 
		# [a-zA-Z0-9]{1,} :: [a-zA-Z0-9]{1,} -> [a-zA-Z0-9]{1,} (-> [a-zA-Z0-9]{1,}){0,}?
		# [a-zA-Z0-9]{1,} :: [a-zA-Z0-9]{1,} -> [a-zA-Z0-9]{1,}(( -> [a-zA-Z0-9]{1,})?){0,}
		@type = -> /[a-zA-Z0-9]{1,} :: [a-zA-Z0-9]{1,} -> [a-zA-Z0-9]{1,}(( -> [a-zA-Z0-9]{1,})?){0,}/ is it
		@spec = -> (new RegExp "(#{parser eq})") isnt it
		@test = -> (@type and @spec) it 
	
	pure_text = [ [(regex.test i) , i] for i in text]
	
	get_line = (chunk) ->
		chunk
		|> last  
		|> elem-index _, text
	
	cmb = new 
		@frt = map first, pure_text 
		@n 	 = all (is null),    @frt
		@f   = all (isnt true),  @frt 
		@l   = x:@n, y:@f
	
	log = (x,n) ->
		x 
		|> last 
		|> left-add \:  
		|> left-add (get_line x)
		|> -> 
			| n => it 
			| _ => it.red
			
	cmb.l 
		|> -> 
			| it.x  &&  it.y    => "\n[ No patterns found ]"
			| it.x  && !(it.y)  => "\n[ No patterns found ]"
			| !(it.x) &&  it.y  => "\n[ Success : no issues found ]".green 
			| _ => 
				try
					pure_text
						|> break-list (-> first it)
						|> -> 
							(first it).push (first last it)
							it
						|> first
						|> map (->
								| first it => log it
								| _ 	   => log it, 1 )
						|> -> [\\n] ++ it 
						|> -> it ++ [" ^^^^ Not permitted\n"]
				catch
					pure_text


run_single_file = Func.curry (line,file) ->
		IO.puts \Running file
		file
			|> IO.read
			|> Str.split \\n
			|> findTypes line
			|> -> 
				| typeof! it is \Array => it |> IO.line
				| _ 				   => it |> IO.puts

main = do
	
	ts 		= Date.now();
	ob 		= new Date(ts);	
	date 	= ob.getDate();
	month 	= ob.getMonth() + 1;
	year 	= ob.getFullYear();

	unless process.argv[3] is \--help
		IO.puts "Using file: #{process.argv[4]} at [ #{month}|#{date}|#{year} ]"
		IO.puts "Starting analysis".green
	
	process.argv
		|> filter (-> (check.p0 and check.p1) it)
		|> tail
		|> -> 
			| it.length < 3 && it.0 isnt \--help => IO.lineFail!
			| _ 		    => it
		|> (_) -> 
			| _.0 is \--help  =>
				IO.puts """
				
lsc putnam.ls [-option] [file] expression 

--run     [single file] :: Check the current file  
--folder  [folder path] :: Will search for errors in all folder's files
--watch   [single file] :: Watches a single file and searching for errors
--watch-d [single file] :: Watches a single file and searching for errors and changes

				"""
			| _.0 is \--run    => 
				_.1
					|> run_single_file _.2
			| _.0 is \--folder =>
				_.1
					|> IO.folder
					|> map (left-add _.1+\/) 
					|> map (run_single_file _.2)
			| _.0 is \--watch  => 
				do watch = (x=_.1,y="",v=0.0) -> 
					x
					|> IO.read
					|> -> 
						| it is y   => 
							IO.puts "version: #{v} of #{x}"
							[it,v]
						| it isnt y => 
							IO.puts "\nChanged...".green 
							IO.puts "version: #{v+0.1} of #{x}"
							run_single_file _.2, x
							IO.puts \\n
							[it,v+0.1]
					|> -> watch x, it.0, it.1 
					sleep 1
					
			| _.0 is \--watch-d =>
				do watch-diff = (x=_.1,y="",v=0.0) -> 
					| y is "" and v is 0.0   => 
						x
						|> IO.read 
						|> diff.diffChars y, _
						|> filter (.added) 
						|> map (.value)  
						|> ->
							| !(it.length) => ""
							| _    		   => Str.join "\n" it 
						|> watch-diff x, _, v+0.1
						sleep 1																	 																				
						 
					| y is "" and v > 0.0 	 =>
						do wait-update = (nw=y,c=0) ->
							sleep 1 
							run-loading!
							x 
							|> IO.read 
							|> ->
								| (it isnt nw) && (c == 0) => wait-update it, c+0.1
								| (it is   nw) && (c >= 0) => wait-update it, c+0.1
								| (it isnt nw) && (c >= 0) => watch-diff x, it, v+0.1
																		
					| y isnt "" and v > 0.0  =>
						y
						|> Str.split \\n
						|> findTypes _.2
						|> -> 
							| typeof! it is \Array => it |> IO.line
							| _ 				   => it |> IO.puts
						sleep 1
						watch-diff x, "", v+0.1							 
					
			| _ 			   =>
				IO.cmdFail!

# eof 
