	\ utf-8
	\ Words that are for HTA only 

	s" misc.hta.f"	source-code-header
	
	: stamp ( -- ) \ Paste date-time at cursor position
		js> clipboardData.getData("text")  ( saved ) \ SAVE-restore
		now t.dateTime ( saved "date time" )
		js: clipboardData.setData("text",pop()) ( saved )
		<vb> WshShell.SendKeys "^v" </vb> 
		500 sleep js: clipboardData.setData("text",pop()) ( empty ) \ save-RESTORE
		;
		/// It works now 2016-05-16 18:11:03. Leave 'stamp' in inputbox then put cursor
		/// at target position, press Ctrl-Enter, then that's it! Date-time pasted to
		/// the target position. Only supported in 3hta so far.
	
	: beep ( -- ) \ Sounds a beep
		js: _beep_.play() 600 nap ;
		s" <embed id=_beep_ autostart=false enablejavascript=true src='" 
		char %WINDIR% env@ + s" \Media\chord.wav'></embed>" + </h> drop
		\ After html5.f and env.f, Setup embeded beep sound wave file
		\ Create an embed element that holds the beeping wave file.
		\ char embed createElement \ ele
		\ dup char id char beep setAttribute \ ele
		\ dup char src char %WINDIR% env@ s" \Media\Windows Ding.wav" + setAttribute \ ele
		\ dup char autostart char false setAttribute \ ele
		\ dup char enablejavascript char true setAttribute \ ele
		\ js: $(tos()).hide() eleHead swap appendChild \ 可以掛 header （與 body 同屬 document）但不能不掛

	<js>
		// HTA does not support Math.sign so far, fix it.
		// http://stackoverflow.com/questions/7624920/number-sign-in-javascript
		if (Math.sign==undefined)
			Math.sign = function sign(x) { return x > 0 ? 1 : x < 0 ? -1 : 0; };
	</js>

	: (aliases) ( Word [array] -- ) \ Make array of tokens to be aliases of the Word
		js> tos().length ( w a length ) ?dup if for ( w a )
			\ create one alias word
				js> tos().pop() ( w a name ) (create) reveal ( w a )
			\ copy from predecessor, arrays and objects are by reference
				<js> for(var i in tos(1)) last()[i] = tos(1)[i]; </js>
			\ touch up
				<js>
					last().type = "alias";
					last().predecessor = last().name;
					last().name = newname;
				</js>
		next then ( w a ) 2drop ;
		/// Used in DOS box batch program for jeforth to ignore DOS words.

	: aliases	( Word <name1 name2 ... > -- ) \ Make following tokens be aliases of the Word
		CR word s"  dummy" + :> split(/\s+/) 
		js: tos().pop() \ drop the dummy
		( Word array ) (aliases) ; 
		/// Used in DOS box batch program for jeforth to ignore DOS words.



				