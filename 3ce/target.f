
	\ quit.f for jeforth.3ce
	\
	\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
	\ applications. quit.f is the good place to define propritary features of each application.
	\  

	\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	js: tick('<selftest>').buffer="" \ recycle the memory

	\ 發現透過 rawgit.com 可以直接執行發佈在 GitHub 上的 jeforth.3htm
	\ 為了加快速度,以下都用絕對位址。避免讓 readTextFileAuto 順著 path
	\ 慢慢嘗試錯誤。

	include 3htm/f/jsc.f		    \ JavaScript debug console in 3htm/f
	include f/voc.f					\ voc.f is basic of forth language
	include 3htm/f/html5.f			\ html5.f is basic of jeforth.3htm

	js: if($(".console3we").length)$(".console3we").remove() \ remove existing forth console
	
	char body <e> 
		<div class=console3we>
		<style>
			.console3we {
				color:black;
				word-wrap:break-word;
				border: 1px ridge;
				background:#F0F0F0;
				padding:20px;
			}
			.console3we div {
				font: 20px "courier new";
			}
			.console3we textarea {
				width:100%;
				font: 20px "courier new";
				padding:4px;
				border: 0px solid;
				background:#BBBBBB;
			}
		</style>
		<div id=header>
			<div style="font-family:verdana;">
				<b><div class=appname style="letter-spacing:16px;color:#555555;">appname</div></b>
				<div style="color:#40B3DF;">
				Revision <span id=rev style="background-color:#B4009E;color:#ffffff;">rev</span><br>
				Source code http://github.com/hcchengithub/jeforth.3we<br>
				Program path <span id=location>location</span><br>
				</div>
			</div>
		</div>
		<div id="outputbox"></div>
		<textarea id="inputbox" cols=100 rows=1></textarea>
		<span id=endofinputbox></span>
		</div>
	</e> drop				
	
	js> vm.type            value original.type       // ( -- function ) type to host
	js> document.onkeydown value original.onkeydown  // ( -- function ) original
	null value target.type         // ( -- function ) type to outputbox
	null value target.onkeydown    // ( -- function ) Fire inputbox command

	<js>
		$('#rev').html(vm.version); // also .commandLine, .applicationName, ...
		$('#location').html(window.location.toString()); // it's built-in in DOM
		$('.appname').html(vm.appname); // 一次填好所有 appname
		
		// vm.type() is the master typing or printing function.
		// The type() called in code ... end-code is defined in the kernel jeforth.js.
		// target_type(s) types to the target page outputbox, instead of to the host page 
		// that may be the popup page or a 3ce extension page.
		// vm.type = target_type;
		function target_type(s) { 
			try {
				var ss = s + ''; // Print-able test
			} catch(err) {
				ss = Object.prototype.toString.apply(s);
			}
			if(vm.screenbuffer!=null) vm.screenbuffer += ss; // 填 null 就可以關掉。
			if(vm.selftest_visible) $('#outputbox').append(vm.plain(ss)); 
		}
		vm.g["target.type"] = target_type;

		// onkeydown,onkeypress,onkeyup
		// event.shiftKey event.ctrlKey event.altKey event.metaKey
		// KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html
		// document.onkeydown = target_onkeydown;
		function target_onkeydown(e) {
			// Initial version defined in 3ce/quit.f
			e = (e) ? e : event; var keyCode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
			switch(keyCode) {
				case 13: /* Enter */
					var cmd = inputbox.value; // w/o the '\n' character ($10). 
					inputbox.value = ""; // 少了這行，如果壓下 Enter 不放，就會變成重複執行。
					vm.forthConsoleHandler(cmd);
					return(false); 
			}
			return (true); // pass down to following handlers 
		}
		vm.g["target.onkeydown"] = target_onkeydown;
	</js>

	: display->host ( -- ) \ Target page forth console display output to host page.
		cr ." Target page display switch to 3ce extension pages." cr
		original.type js: vm.type=pop() ;
	: display->local ( -- ) \ Target page forth console display output to local outputbox.
		cr ." Target page display switch to local outputbox." cr
		target.type js: vm.type=pop() ;
	last execute \ Switch jeforth console to target page's local outputbox/inputbox.
	target.onkeydown js: document.onkeydown=pop() \ May conflict with target page's original settings.

	: cr ( -- ) \ 到下一列繼續輸出 *** 20111224 sam
		js: type("\n") 1 nap js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus() ;
		/// redefined in quit.f, 1 nap 使輸出流暢。
		/// Focus the display around the inputbox.
	
	include 3htm/f/element.f		\ HTML element manipulation
	include 3htm/f/platform.f		
	include f/mytools.f		
	include 3htm/f/editor.f

	\ ------------ End of target.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus()

