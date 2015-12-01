
\ platform.f for jeforth.3htm, jeforth.3hta, and jeforth.3nw
\ KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html

s" platform.f"		source-code-header

also forth definitions

: {F5}			( -- boolean ) \ Hotkey handler, Confirm the HTA window refresh
				<js> confirm("Really want to restart?") </jsV> ;
				/// Return a false to stop the hotkey event handler chain.
				/// Must intercept onkeydown event to avoid original function.

: {F2}			( -- false ) \ Hotkey handler, Toggle input box EditMode
				[ last literal ] ( _me )
				js> event&&event.shiftKey if ( shift+F2 for outputbox )
					drop ." Output box EditMode = " 
					js> outputbox.contentEditable!="true" if
						js> document.designMode="on";outputbox.contentEditable="true"
					else
						js> document.designMode="off";outputbox.contentEditable="false"
					then
					. cr
				else ( F2 for inputbox )
					." Input box EditMode = " 
					\ 以下這行不能用 cr, 因其中有 1 nap suspend, event handler 不能 suspend! 否則此處會吃掉 TOS
					js> tos().EditMode=Boolean(tos().EditMode^true) nip dup . js: type('\n')
					if   <text> textarea:focus { border: 0px solid; background:#FFE0E0; }</text> \ pink as a warning of edit mode
					else <text> textarea:focus { border: 0px solid; background:#E0E0E0; }</text> \ grey
					then js: styleTextareaFocus.innerHTML=pop()
				then
				js: jump2endofinputbox.click();inputbox.focus();
				false ;
				/// return a 'false' to stop the hotkey event handler chain.

code {F9}		( -- false ) \ Hotkey handler, Smaller the input box
				var r = inputbox.rows;
				if(r<=4) r-=1; else if(r>8) r-=4; else r-=2;
				inputbox.rows = Math.max(r,1);
				if (!r) $("#inputbox").hide();
				jump2endofinputbox.click();inputbox.focus();
				push(false);
				end-code
				/// return a false to stop the hotkey event handler chain.
				last alias {F6} // ( -- flase ) Hotkey handler, Smaller the input box
								/// Duplicated to recover PowerCam conflict.

code {F10}		( -- false ) \ Hotkey handler, Bigger the input box
				$("#inputbox").show()
				var r = 1 * inputbox.rows;
				if(r<4) r+=1; else if(r>8) r+=4; else r+=2;
				inputbox.rows = Math.max(r,1);
				jump2endofinputbox.click();inputbox.focus();
				push(false);
				end-code
				/// return a false to stop the hotkey event handler chain.
				/// Must intercept onkeydown event to avoid original function.
				last alias {F7} // ( -- flase ) Hotkey handler, Bigger the input box
								/// Duplicated to recover PowerCam conflict.

code {F4}		( -- false ) \ Hotkey handler, copy marked string into inputbox
				var selection = getSelection();
				var start, end, ss;
				if (!selection.isCollapsed) {
					if (selection.anchorNode==selection.focusNode) {
						start = Math.min(selection.anchorOffset,selection.focusOffset);
						end   = Math.max(selection.anchorOffset,selection.focusOffset);
						ss = selection.anchorNode.data.slice(start,end);
					} else {
						if (selection.anchorNode.data){  // 我根據實例亂湊的，搞不懂對的用法。
							start = selection.anchorOffset;
							end   = selection.anchorNode.data.length;
							ss = selection.anchorNode.data.slice(start,end);
						} else {
							// 啟動時 mark "VBScript V5.8 Build:16384" 其中那個 16384 就會出這種情形！
							ss = selection.focusNode.data.slice(0,selection.anchorOffset);
						}
					}
					document.getElementById("inputbox").value += " " + ss;
				}
				jump2endofinputbox.click();inputbox.focus();
				push(false);
				end-code
				/// return a false to stop the hotkey event handler chain.
				/// The selection must be made from start to end.

code {esc}		( -- false ) \ Inputbox keydown handler, clean inputbox
				inputbox.value="";
				jump2endofinputbox.click(); inputbox.focus();
				push(true); // 別的 handler 還可以收得到 Esc key。
				end-code

: history-selector ( -- ) \ Popup command history for selection
				<o> <br><select style="width:800px;padding-left:2px;font-size:16px;"></select></o> ( select )
				<js> 
					tos().size = Math.min(16,vm.cmdhistory.array.length);
					for (var i=0; i<vm.cmdhistory.array.length; i++){
						var option = document.createElement("option");
						option.text = vm.cmdhistory.array[i];
						js: tos().add(option);
					}
					tos().selectedIndex=tos().length-1;
					jump2endofinputbox.click();tos().focus();
					var select = tos().onclick = function(){
						inputbox.value = tos().value;
						execute("removeElement");
						inputbox.focus();
						return (false);
					}
					tos().onkeydown = function(e){
						e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
						switch(keycode) {
							case 27: /* Esc  */ execute("removeElement"); inputbox.focus(); break;
							case 38: /* Up   */ tos().selectedIndex = Math.max(0,tos().selectedIndex-1); break;
							case 40: /* Down */ tos().selectedIndex = Math.min(tos().length-1,tos().selectedIndex+1); break;
							case 13: /* Enter*/ setTimeout(select,1); break;
						}
						return (false);
					}
				</js> ;
				
true value up/down-recall-needs-alt-key? // ( -- boolean ) An optional setting. Up/Down key to recall command history needs the Alt-key?

: {up}			( -- boolean ) \ Inputbox keydown handler, get previous command history.
				js> event.altKey if 
					history-selector false \ eat the key
				else
					js> event.ctrlKey if
						js: inputbox.value=vm.cmdhistory.up() false \ eat the key
					else 
						js> inputbox.value==""||inputbox.value=="\n" 
						up/down-recall-needs-alt-key? not and
						if
							history-selector false \ eat the key
						else
							true \ don't eat the key, let it pass down
						then
					then 
				then ;
				/// Alt-Up pops up history-selector menu.
				/// Ctrl-Up/Ctrl-Down recall command line history.
				/// Use Ctrl-M instead of 'Enter' when you want a 'Carriage Return' in none EditMode.

: {down}		( -- boolean ) \ Inputbox keydown handler, get next command history.
				js> event.altKey if 
					history-selector false \ eat the key
				else
					js> event.ctrlKey if
						js: inputbox.value=vm.cmdhistory.down() false \ eat the key
					else 
						js> inputbox.value==""||inputbox.value=="\n" 
						up/down-recall-needs-alt-key? not and
						if
							history-selector false \ eat the key
						else
							true \ don't eat the key, let it pass down
						then
					then 
				then ;
				/// Alt-Up pops up history-selector menu.
				/// Ctrl-Up/Ctrl-Down recall command line history.
				/// Use Ctrl-M instead of 'Enter' when you want a 'Carriage Return' in none EditMode.

: {backSpace}	( -- boolean ) \ Inputbox keydown handler, erase output box when input box is empty
				js> inputbox.focus();inputbox.value!=""&&inputbox.value!="\n" if 
					true \ inputbox is not empty, do the norm.
				else \ inputbox is empty, clear outputbox bottom up
					js> event==null||!event.altKey \ So as to allow calling {backSpace} programmatically	
					if \ erase bottom up 
						js> outputbox.lastChild ?dup if
							js> tos().nodeName char BR = if removeElement else drop then
						then				
						js> event==null||!event.shiftKey \ So as to allow calling {backSpace} programmatically
						if 1 else 30 then for
							js> event&&event.ctrlKey if
								js> outputbox.lastChild ?dup if removeElement then
							else
								js> outputbox.lastChild ?dup if
									js> tos().nodeName  char BR    =
									js> tos(1).nodeName char #text =
									or if removeElement else drop then
								then
							then
						next
					else \ erase top down
						js> event==null||!event.shiftKey \ So as to allow calling {backSpace} programmatically
						if 1 else 30 then for
							js> event&&event.ctrlKey if
								js> outputbox.firstChild ?dup if removeElement then
							else
								js> outputbox.firstChild ?dup if
									js> tos().nodeName  char BR    =
									js> tos(1).nodeName char #text =
									or if removeElement else drop then
								then
							then
						next
					then	
					false
				then ;
				/// {backSpace} erase only the last <BR> and text node. To erase other node
				/// types, use Ctrl-{backSpace}. To erase faster, use Shift-{backSpace} or
				/// Shift-Ctrl-{backSpace}. To erase top down, use Alt key.

code {Tab} 		( -- ) \ Inputbox auto-complete
				with(this){
					if(index == 0){ // index 初值來自 document.onkeydown event, 這是剛按下 Tab 的線索。
						var a=('h '+inputbox.value+' t').split(/\s+/);
						a.pop(); a.shift();
						this.hint = a.pop()||""; // the partial word to be autocompleted
						this.cmdLine = inputbox.value.slice(0,inputbox.value.lastIndexOf(hint))||"";
						this.candidate = []; 
						if(hint){
							for(var key in wordhash) {
								if(key.toLowerCase().indexOf(hint.toLowerCase())!=-1) candidate.push(key); 
							}
							candidate.push(hint);
						}
					}
					if(hint){
						if(index >= candidate.length) index = 0;
						inputbox.value = cmdLine + candidate[index++];
						push(false); // 吃掉這個 Tab key。
					} else {
						push(true); // 不吃掉這個 Tab key，給別人處理。
					}
				}
				end-code
				last :: index=0

: {ctrl-break}	( -- boolean ) \ Inputbox keydown handler, stop outer loop
				."  {ctrl-break} " stop false ;

: help(word) 	( word -- ) \ Show help messages of a word in a HTML table
				js> typeof(help_words)=='object' if else
						<o> <style id=help_words>
							.help_words table, .help_words td , .help_words th, .help_words caption {
								padding:8px;
								border-collapse: collapse;
								border: 2px solid #F0F0F0;
							}
							.help_words tr {background: #E8E8FF}
							.help_words tr:nth-child(1) {background: #D0D0FF}
						</style></o> drop
				then
				<text>
					<table class=help_words style="width:90%">
					<tr>
					  <td style="width:200px"><b>_name_</b></td><td colspan=4><b>_help_</b>
					  [_type_][_vid_][_immediate_][_compile_]</td>
					</tr>
					_comment_
					</table>
				</text> ( word html )
				js> pop().replace(/_name_/,vm.plain(tos().name))
				js> pop().replace(/_help_/,vm.plain(tos().help))
				js>	pop().replace(/_type_/,vm.plain(tos().type))
				js>	pop().replace(/_vid_/,vm.plain(tos().vid))
				( word html ) <js> 
					if (tos(1).comment) {
						push(pop().replace(
							/_comment_/,
							"<tr><td colspan=5>"+vm.plain(tos().comment)+"</td></tr>"
						))
					} else push(pop().replace(/_comment_/,""))
					if (tos(1).immediate)  
						 push(pop().replace(/_immediate_/,"IMMEDIATE")); 
					else push(pop().replace(/_immediate_/,""));
					if (tos(1).compileonly) 
						 push(pop().replace(/_compile_/,"COMPILE-ONLY")); 
					else push(pop().replace(/_compile_/,""));
				</js> 
				</o> 2drop ;

code (help)		( "[pattern [-t|-T|-n|-N]]" -- )  \ Print help message of screened words
				// execute("parser(words,help)"); var option = pop();
				var spec = pop().replace(/\s+/g," ").split(" "); // [pattern,option,rests]
				for (var j=0; j<order.length; j++) { // 越後面的 priority 越新
					push(order[j]); // vocabulary
					push(spec[0]||""); // pattern
					push(spec[1]||""); // option
					execute("(words)"); // [words...]
					var word_list = pop();
					var voc = "\n--------- " + order[j] +" ("+ word_list.length + " words) ---------\n";
					// 印出
					if (word_list.length) type(voc);
					for (var i=0; i<word_list.length; i++) {
						push(word_list[i]); execute('help(word)')
					}
				} 
				end-code
				/// Modified by platform.f for HTML table.
				/// Pattern matches name, help and comment.
				/// It can be qualified by an option of:
				///	  -n matches name pattern, case insensitive.
				///	  -N matches exact name, case sensitive.
				///   -t matches type pattern, case insensitive.
				///   -T matches exact type, case sensitive.
				/// Example: 
				///   help ! -n  shows words with '!' in their name

: help			( <[pattern [-t|-T|-n|-N]]> -- )  \ Print help message of screened words
                char \n|\r word js> tos().length if 
					js> tos()=='*' if drop "" then
					(help) 
				else
					drop js> typeof(help3we)=='object' if else
						<o> <style id=help3we>
							.help3we table, .help3we td , .help3we th, .help3we caption {
								padding:8px;
								font-size:18px;
								font-family: cursive;
								border-collapse: collapse;
								border: 2px solid #F0F0F0;
							}
							.help3we tr:nth-child(odd)  {background: #D0D0FF}
							.help3we tr:nth-child(even) {background: #E0E0FF}
							.help3we td {min-width: 200px}
						</style></o> drop
					then
					<o>
						<table class=help3we style="width:80%;">
						<caption><h3>jeforth.3we for HTM, HTA, and Node-webkit basic usages</h3></caption>
						<tr>
						  <td><b>Topic</b></td>
						  <td><b>Descriptions</b> (watch video)</td>
						</tr>
						<tr>
						  <td>Introduction</td>
						  <td>jeforth.3we is an implementation of the Forth programming 
						  language written in JavaScript and runs on HTA, HTM, Node.js, and Node-webkit. 
						  Watch <a href="http://www.camdemy.com/media/19253">video</a>.</td>
						</tr>
						<tr>
						  <td>How to</td>
						  <td><a href="http://www.camdemy.com/media/19254">Run the HTML version online</a>. Click <a href="http://figtaiwan.org/project/jeforth/jeforth.3we-master/index.html">here</a> to run.</td>
						</tr>
						<tr>
						  <td>How to</td>
						  <td><a href="http://www.camdemy.com/media/19255">Run the HTML version on local computer</a></td>
						</tr>
						<tr>
						  <td>How to</td>
						  <td><a href="http://www.camdemy.com/media/19256">Run the HTA version</a></td>
						</tr>
						<tr>
						  <td>How to</td>
						  <td><a href="http://www.camdemy.com/media/19257">Run Node.js and Node-Webkit version</a></td>
						</tr>
						<tr>
						  <td>Hotkey F2</td>
						  <td><a href="http://www.camdemy.com/media/19258">Toggle input box EditMode</a></td>
						</tr>
						<tr>
						  <td>Hotkey F4</td>
						  <td><a href="http://www.camdemy.com/media/19259">Copy marked string to inputbox</a></td>
						</tr>
						<tr>
						  <td>Hotkey F5</td>
						  <td><a href="http://www.camdemy.com/media/19260">Restart the jeforth system</a></td>
						</tr>
						<tr>
						  <td>Hotkey F9/F10</td>
						  <td><a href="http://www.camdemy.com/media/19261">Bigger/Smaller input box</a></td>
						</tr>
						<tr>
						  <td>Hotkey Esc</td>
						  <td><a href="http://www.camdemy.com/media/19262">Clear input box</a></td>
						</tr>
						<tr>
						  <td>Hotkey Tab</td>
						  <td><a href="http://www.camdemy.com/media/19263">Forth word auto-complete</a></td>
						</tr>
						<tr>
						  <td>Hotkey Enter</td>
						  <td><a href="http://www.camdemy.com/media/19264">Jump into the input box</a></td>
						</tr>
						<tr>
						  <td>Hotkey Ctrl-Up/Ctrl-Down</td>
						  <td><a href="http://www.camdemy.com/media/19265">Recall command history</a>
						  Up/Down key (w/o Ctrl) pops up the command history if inputbox is empty. 
						  Use Ctrl-M or Shift-Enter when you want a 'Carriage Return' in inputbox.
						  </td>
						</tr>
						<tr>
						  <td>Hotkey Alt-Up/Alt-Down</td>
						  <td><a href="http://www.camdemy.com/media/19266">List command history</a></td>
						</tr>
						<tr>
						  <td>Hotkey Crtl+/Ctrl-</td>
						  <td><a href="http://www.camdemy.com/media/19267">Zoom in/ Zoom out</a></td>
						</tr>
						<tr>
						  <td>Hotkey Ctrl-Break</td>
						  <td><a href="http://www.camdemy.com/media/19268">Stop all parallel running tasks</a></td>
						</tr>
						<tr>
						  <td>Hotkey BackSpace</td>
						  <td><a href="http://www.camdemy.com/media/19269">Erase the outputbox</a>
						   bottom-up, Alt-BackSpace top-down. But they don't erase elements.
						   Ctrl-BackSpace to erase elements. Add Shift key makes it faster.
						  </td>
						</tr>
						<tr>
						  <td>help [*|pattern [-t|-T|-n|-N]]</td>
						  <td>You are reading me. 'help' is also an useful command, 
						  "help *" lists all words' help. "help help -N" to see options.
						  <a href="http://www.camdemy.com/media/19270">Video: Help is helpful</a>.
						  </td>
						</tr>
						<tr>
						  <td>jsc</td>
						  <td><a href="http://www.camdemy.com/media/19271">JavaScript Console</a></td>
						</tr>
						<tr>
						  <td>More information</td>
						  <td>
						  1. <a href="http://www.camdemy.com/folder/8691">Video presentation web site</a> <br> 
						  2. <a href="https://github.com/hcchengithub/jeforth.3we/wiki">jeforth.3we GitHub Wiki.</a>
						  </td>
						</tr>
						</table>
						
					</o> drop
				then ;
				last :: comment=tick('(help)').comment
				/// A pattern of '*' means all words.
				/// Example: 
				///   help *     shows all words


<js>
	vm.cmdhistory = {
		max:   100, // maximum length of the command history
		index: -1,
		array: [],
		push:
			function (cmd){
				cmd = cmd.replace(/(^( |\t)*)|(( |\t)*$)/mg,''); // remove 頭尾 whitespaces. .trim() 舊 JScript v5.6 未 support
				if(cmd.search(/\S/)==-1) return; // skip blank lines
				this.array.push(cmd);
				for(var i=this.array.length-2; i>=0; i--)
					if(cmd==this.array[i]) this.array.splice(i,1); // remove duplicated
				if (this.array.length > this.max ) this.array.shift(); // overflow
				this.index = this.array.length; // point to last one, new one.
			},
		up:
			function(){
				var cmd="", indexwas = this.index;
				this.index = Math.max(0, this.index-1);
				if (this.array.length > 0 && this.index >= 0 && this.index < this.array.length){
					cmd = this.array[this.index];
				}
				if (indexwas == this.index) {
					if (tick('beep')) execute('beep');
					cmd += "  \\ the end";
				}
				return(cmd);
			},
		down:
			function(){
				var cmd="", indexwas = this.index;
				this.index = Math.min(this.array.length-1, this.index+1);
				if(this.array.length > 0 && this.index >= 0 && this.index < this.array.length){
					cmd = this.array[this.index];
				}
				if (indexwas == this.index) {
					if (tick('beep')) execute('beep');
					cmd += "  \\ the end";
				}
				return(cmd);
			},
	};

	$("#inputbox")[0].onkeydown = function(e){
		e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
		if(tick('{Tab}')){if(keycode!=9)tick('{Tab}').index=0} // 按過別的 key 就重來
		switch(keycode) {
			case   8: /* Back space */ if(tick('{backSpace}' )){execute('{backSpace}' );return(pop());} break; // disable the [switch previous page] function
			case   9: /* Tab  */ if(tick('{Tab}' )){execute('{Tab}' );return(pop());} break;
			case  38: /* Up   */ if(tick('{up}'  )){execute('{up}'  );return(pop());} break;
			case  40: /* Down */ if(tick('{down}')){execute('{down}');return(pop());} break;
			case 13:
				if (!event.shiftKey) // 想換行用 Shift-Enter 避免把命令發出去
				if (!tick("{F2}").EditMode || event.ctrlKey) { // 在 EditMode 用 Ctrl-Enter 發出命令
					var cmd = inputbox.value; // w/o the '\n' character ($10).
					inputbox.value = ""; // 少了這行，如果壓下 Enter 不放，就會變成重複執行。
					vm.cmdhistory.push(cmd);
					if (tick("{F2}").EditMode) {execute('{F2}');pop()} // 自動恢復
					vm.forthConsoleHandler(cmd);
					return(false);
				}
				return(true); // In EditMode
		}
		return (true); // pass down to following handlers
	}

	document.onkeydown = function (e) {
		e = (e) ? e : event; var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
		switch(keycode) {
			case  27: /* Esc */ if(tick('{esc}')){execute('{esc}');return(pop());} break;
			case 109: /* -   */ if(tick('{-}'  )){execute('{-}'  );return(pop());} break;
			case 107: /* +   */ if(tick('{+}'  )){execute('{+}'  );return(pop());} break;
			case 112: /* F1  */ if(tick('{F1}' )){execute('{F1}' );return(pop());} break;
			case 113: /* F2  */ if(tick('{F2}' )){execute('{F2}' );return(pop());} break;
			case 114: /* F3  */ if(tick('{F3}' )){execute('{F3}' );return(pop());} break;
			case 115: /* F4  */ if(tick('{F4}' )){execute('{F4}' );return(pop());} break;
			case 116: /* F5  */ if(tick('{F5}' )){execute('{F5}' );return(pop());} break;
			case 117: /* F6  */ if(tick('{F6}' )){execute('{F6}' );return(pop());} break;
			case 118: /* F7  */ if(tick('{F7}' )){execute('{F7}' );return(pop());} break;
			case 119: /* F8  */ if(tick('{F8}' )){execute('{F8}' );return(pop());} break;
			case 120: /* F9  */ if(tick('{F9}' )){execute('{F9}' );return(pop());} break;
			case 121: /* F10 */ if(tick('{F10}')){execute('{F10}');return(pop());} break;
			case 122: /* F11 */ if(tick('{F11}')){execute('{F11}');return(pop());} break;
			case 123: /* F12 */ if(tick('{F12}')){execute('{F12}');return(pop());} break;
			case   3: /* ctrl-break */ if(tick('{ctrl-break}')){execute('{ctrl-break}');return(pop());} break;
		}
		return (true); // pass down to following handlers
	}
</js>

previous definitions
