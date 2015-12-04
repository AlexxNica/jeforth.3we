
	char %HOMEDRIVE%%HOMEPATH%\Downloads\jeforth.3htm.html 
		env@ value command-file // ( -- "pathname" ) 
	char %HOMEDRIVE%%HOMEPATH%\Documents\GitHub\jeforth.3we\playground\template.f 
		env@ value target-file // ( -- "pathname" ) 
	"" value command // ( -- string ) Remaining string
	"" value target // ( -- string ) Target string to be modified.
	0  value itarget  // ( -- int ) Pointer of target
	"" value pattern  // ( -- string ) The next pattern ^^^==>...^^^ in command. Specify the target position.
	: init  ( -- ) \ Initialize everything before a run.
		command-file readTextFile to command
		target-file  readTextFile to target 
		0 to itarget "" to pattern \ reset
		;
		
	: ^^^==> ( -- T/f ) \ Move icommand and get pattern. Return true if found.
		js> vm.g.command.indexOf("^^^==&gt;") ( idx )
		dup -1 = if ( �S�ư��F ) drop false else ( idex )
			\ ���F
			js> vm.g.command.slice(pop()) to command \ chop leading garbage
			js> vm.g.command.search(/\^\^\^[+-]/) ( idx ) 
			dup -1 = if ( idx )
				\ �G�N�d�U idx 
				abort" Error! anticipating ^^^+ or ^^^- command not found!" 
			else
				js> vm.g.command.slice(0,tos()) to pattern \ get pattern
				js> vm.g.command.slice(pop()) to command   \ chop processed portion
			then
			true
		then ;
		
		

