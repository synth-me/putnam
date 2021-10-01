{sleep } = require \sleep
readline = require \readline 
std = process.stdout
{replicate,map} = require \prelude-ls

rl = readline.createInterface input: process.stdin, output: process.stdout

r = rl.getCursorPos.row
c = rl.getCursorPos.column

rl.close!

export wait-spin = (p=0) ->
	std
		|> ->
			readline.clearLine it
			readline.cursorTo it, 0, r

	["◐","◓","◑","◒"]
		|> ->
			| it[p] is undefined => [0,it[0]]
			| _ 				 => [p,it[p]]
		|> ->
			process.stdout.write "Waiting changes... #{it[1]}"

export run-loading = ! -> 
	for x in [0,1,2,3]
		wait-spin x 
		sleep 1
	
# eof 
