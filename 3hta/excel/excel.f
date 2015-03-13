\ GB2312
\ excel.f  Microsoft Office Excel automation by jeforth.3hta
\ VBA Language Reference @ http://msdn.microsoft.com/en-us/library/bb190882(v=office.11).aspx
\ Microsoft Excel Visual Basic Reference @ http://msdn.microsoft.com/en-us/library/aa272254(v=office.11).aspx

include wsh.f

s" excel.f"			source-code-header

char Excel.Application ActiveXObject constant excel.app 
					// ( -- excel.application ) Get Excel.Application COM object.
					/// See "Application Object (Excel)","Application Members (Excel)"
					///     http : //msdn.microsoft.com/en-us/library/office/ff194565(v=office.15).aspx
					///     http : //msdn.microsoft.com/en-us/library/office/ff198091(v=office.15).aspx
					///     http : //msdn.microsoft.com/en-us/library/microsoft.office.interop.excel.application_properties(v=office.15).aspx

excel.app [if]
					<selftest>
						***** excel.app is like a constant it gets you the app object ........
						( ------------ Start to do anything --------------- )
						excel.app js> pop().Application.Application.Application.Application.name \ How many .Application ? It doesn't matter. 
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> ["Microsoft Excel"] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'excel.app'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

: excel.visible 	( -- ) \ Make the excel.app visible
					excel.app js> pop().visible=true drop ;

: excel.invisible 	( -- ) \ Make the excel.app invisible
					excel.app js> pop().visible=false drop ;
					
					<selftest>
						*** excel.visible excel.invisible ... 
						excel.invisible
						excel.app js> pop().visible false = \ true
						excel.visible
						excel.app js> pop().visible \ true true
						and ==>judge  [if] <js> [
							'excel.visible',
							'excel.invisible'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

: new.xls           ( -- WorkBook ) \ Create a new excel workbook file object
                    excel.app js> pop().Workbooks.Add ;
					/// Excel workbook proterties: name, parent, path, fullname, .. etc.
                    /// mathods: close(), save(), saveas() .. etc.
					
					<selftest>
						***** new.xls gets workbook file object ....
						( ------------ Start to do anything --------------- )
						new.xls constant WORKBOOK // ( -- obj ) excel workbook
						WORKBOOK js> typeof(pop().name) \ something like ��퓲�1 or Workbook1
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> ['string'] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'new.xls'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

code excel.save     ( workbook -- ) \ Save workbook object to excel file
                    push(pop().save());
                    end-code

: excel.save-as		( "path-name" worksheet|workbook -- boolean ) \ Save to excel file with the given path-name
					excel.app js> tos().DisplayAlerts \ save ( "path-name" workbook excel.app DisplayAlerts )
					js: tos(1).DisplayAlerts=false  ( "path-name" workbook excel.app DisplayAlerts )
                    js> pop(2).SaveAs(pop(2),-4143) \ /* xlWorkbookNormal office 97&2003 compatible */ ( excel.app DisplayAlerts result)
					js: pop(2).DisplayAlerts=pop(1) \ restore
                    ;
					/// always save-as Office 97&2003 compatible format
					
					<selftest>
						***** excel.save-as saves workbook to file ....
						( ------------ Start to do anything --------------- )
						char . full-path char _selftest_.xls + constant 'selftest.xls' // ( -- pathname )
						'selftest.xls' WORKBOOK excel.save-as \ true
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'excel.save-as'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

code open.xls       ( "pathname" -- workbook ) \ Open excel file get workbook object
                    fortheval("excel.app");
                    push(pop().Workbooks.open(pop()));
                    end-code

code excel.close	( workbook -- flag ) \ close the excel file without saving.
                    push(pop().close(false));
                    end-code
					
					<selftest>
						***** excel.close closes the workbook ....
						( ------------ Start to do anything --------------- )
						WORKBOOK excel.close \ true
						'selftest.xls' open.xls constant WORKBOOK // ( -- obj ) excel workbook re-opened
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'excel.close','open.xls','excel.save'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

: excel.close-all	( -- ) \ Close all excel file without saving.
					excel.app dup js> pop().workbooks.count
					( excel.app count ) <js>
						for (var i=0; i<tos(); i++) tos(1).workbooks(1).close(false);
					</js>
					2drop ;

code get-sheet      ( sheet#|"sheet" workbook -- sheet ) \ Get Excel worksheet object where sheet# is either sheet number or name
                    push(pop().worksheets(pop())) // accept both sheet# or sheet name
                    end-code

					<selftest>
						***** get-sheet gets worksheet object ....
						( ------------ Start to do anything --------------- )
							1 WORKBOOK get-sheet constant SHEET // ( -- sheet ) playground worksheet object
										   SHEET js> typeof(pop().name)
							2 WORKBOOK get-sheet js> typeof(pop().name)
							3 WORKBOOK get-sheet js> typeof(pop().name)
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> ['string','string','string'] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'get-sheet'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

code get-range      ( "a1:b2" worksheet -- range ) \ get a range
                    push(pop().range(pop()));
                    end-code

					<selftest>
						***** get-sheet gets worksheet object ....
						( ------------ Start to do anything --------------- )
							char a1:c3 SHEET get-range constant RANGE // ( -- range ) a range in worksheet
							RANGE js> pop().count
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> [9] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'get-range'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

code get-cell       ( column row sheet -- cell ) \ Get cell object
                    push(pop().Cells(pop(),pop()))
                    end-code
					<selftest>
						***** get-cell gets cell object ....
						( ------------ Start to do anything --------------- )
							1 1 SHEET get-cell constant CELL // ( -- cell ) excel cell A1 object
							CELL js> pop().count
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> [1] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'get-cell'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

code cell@          ( column row range -- value ) \ read a cell
                    push(pop()(pop(),pop()).value)
                    end-code

code cell!          ( value column row ragne -- ) \ write a cell
                    pop()(pop(),pop()).value = pop()
                    end-code

					<selftest>
						***** cell@ cell! ....
						( ------------ Start to do anything --------------- )
						11 1 1 RANGE cell! 21 2 1 RANGE cell! 31 3 1 RANGE cell!
						12 1 2 RANGE cell! 22 2 2 RANGE cell! 32 3 2 RANGE cell!
						13 1 3 RANGE cell! 23 2 3 RANGE cell! 33 3 3 RANGE cell!
						CELL js> pop().value
						2 3 RANGE cell@
						WORKBOOK excel.close
						( ------------ done, start checking ---------------- )
						js> stack.slice(0) <js> [11,23,true] </jsV> isSameArray >r dropall r>
						-->judge [if] <js> [
							'cell!',
							'cell@'
						] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					</selftest>

code bottom         ( Column -- row# ) \ Get the bottom row# of the column
                    push(pop().rows(65535).end(-4162).row) // xlUp = -4162
                    end-code
                    /// It's too stupid that takes a lot of time if going along down to row#65535
                    /// example: sheet char pop().range("B:B") js bottom tib. \ ==> 160 (number)

: column#>letter 	1- char A (ASCII) + ASCII>char ; // ( col# -- letter ) Get column letter, only support A~Z.
: letter>column# 	(ASCII) char A (ASCII) - 1+ ; // ( letter -- col# ) Get column number, only support 1~26.
code init-hash      ( sheet "columnKey" "columnValue"-- Hash ) \ get hash table from key-value columns
                    var columnValue = pop(), columnKey = pop(), sheet = pop();
                    var key = sheet.range(columnKey  +":"+columnKey);
                    var val = sheet.range(columnValue+":"+columnValue);
                    push(key); fortheval("bottom"); var bottom = pop();
                    for (var i=1, hash={}; i<=bottom; i++) {
                        if (key(i).value == undefined ) continue;
                        hash[key(i).value] = val(i).value;
                    }
                    push(hash);
                    end-code
                    /// example: MySheet char B char D init-hash (see)

code hash>column	( Hash Sheet "colKey" "colValue" top-row# -- ) \ Fill out the colValue by look up hash with colKey
                    var top=pop(), colValue=pop(), colKey=pop(), sheet=pop(), hash=pop();
                    var key = sheet.range(colKey  +":"+colKey);
                    var val = sheet.range(colValue+":"+colValue);
                    push(key); fortheval("bottom"); var bottom = pop();
                    for (var i=top; i<=bottom; i++) {
                        if (key(i).value == undefined ) continue;
                        val(i).value = hash[key(i).value];
                    }
                    end-code
                    /// Hash was from the source sheet through 'init-hash'.
                    /// hash sheet char B char G top-row# hash>column

code workbook>sheets
					( workbook -- array ) \ Get array of all sheet names in a workbook
					var target = pop(), count = target.sheets.count, aa = [];
					for(var i=1; i<=count; i++) aa.push(target.sheets(i).name);
					push(aa);
					end-code

code list-workbooks ( -- count ) \ List all opened workbooks under excel.app
					execute("excel.app");
					var excelapp = pop(),
						count = 0;
					push(count = excelapp.workbooks.count); push(excelapp.name);
					fortheval(". .(  has ) . .(  opened workbooks at this moment.) cr");
					for (var i=1; i<=excelapp.workbooks.count; i++){
						push(excelapp.workbooks(i).name); push(excelapp.workbooks(i).path); push(i);
						fortheval("3 .r space . char \\ . . cr");
					}
					push(count);
					end-code
					/// run list-workbooks any time to see recent excel.app's workbooks.
[then] \ excel.app [if]

<comment>
\ ================ How to open an Excel file ============================================
\
\ Key points of automation Excel file accessing ,
\ 1. Excel's working directory is user\document, not the DOS box working directory.
\ 2. The path string delimiter \ must be \\ or it will be failed sometimes.
\ 3. GetObject("file1.xls"), GetObject("file2.xls"), and double click file3.xls are all using the
\    same "Excel.Application" handler. Excel must be in memory before using GetObject("file1.xls").
\
\ Open excel file �ЃɷN��ʽ��
\
\   1�� s' new ActiveXObject("Excel.application")' js constant excel.app // ( -- excel.app ) Get excel application object
\       fortheval("excel.app"); push(pop().Workbooks.open("x:\\cooked.xls");
\
\   2�� js> GetObject("","Excel.application") constant excel.app // �Ǳ�Ҫ��ֻ��ȡ�� excel.app �Լ��_�� excel.exe ���ڡ�
\       js> GetObject("x:\\raw.xls") constant raw.xls
\       js> GetObject("x:\\cooked.xls") constant cooked.xls
\
\ ǰ�ߵ� excel.app �������X������ "Excel.application" instances�����} open ͬһ���n���Ć��}��
\ �y��Q��Internet ���кܶ����چ����������ô𰸡����Ҫ�ѳ����е� "Excel.application" instances
\ ��̎���ѽ��y�^�^�ˡ�����Ҫ�����߲źã����} open �r excel �Լ����������ֹ����� automation
\ �� excel file ���õ� Excel.Application �c double click open excel file ��ͬһ handler. �C����
\ ��,
\
\    raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls
\    Now open a.xls manually by double click it, and check again workbooks.count,
\    raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
\    raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string)
\
\ GetObject() ��ȱ�c�ǣ��� Excel ������ memory �e�r���� error "JScript error : Automation ��������
\ �ܴ�������". ��������Ҫ�Ȱ� excel run ������һ�rҲ�]�l�F�@�����}����� Excel.app handler ��ʹ��
\ excel.app js> pop().quit() ֮�ᶼ߀������ memory �e����� GetObject() connect �^����]�Д��_���k��
\ ��������һֱ���棬������ Task Manager �����P���������ص��� excel.app js> pop().quit() ֮���� double
\ click open �� excel file �ƺ���׃��ȥ����һ�� excel.application instance���@���Ɂy�ˡ��ʲ�Ҫʹ��
\ excel.app js> pop().quit(), 픶��� workbook.close �ͺá�
\
\ ====================== path delimiter is always a problem ===============================
\
\ path delimiter ��߀���� ����Ҫҕ�o�l������ Excel 2010 �� save-as Ҫ���� Microsoft �� \ ���Ҳ�����
\ \\ Ҳ������ /�� Excel 2003 ���Խ����� / �� \\���� GetObject() Ҫ���� \\ ���Ҳ����� \���@���ǻ�y��
\ ����ֻ�Üʂ� >path/ >path\ >path\\ ���m�����N��r��
\
\ workbook.save-as accepts only only \ as its path delimiter.
\
\     s" C:\Users\8304018\Documents\Dropbox\learnings\Forth\jeforth\JScript\cooked-raw.xls" constant cooked-file
\     cooked-file raw.xls save-as tib.
\
\         OK s" C:\Users\8304018\Documents\Dropbox\learnings\Forth\jeforth\JScript\cooked-raw.xls" constant cooked-file
\         reDef cooked-file OK cooked-file raw.xls save-as tib.
\         cooked-file raw.xls save-as tib. \ ==> true (boolean)
\         OK
\
\ workbook.save-as does not accept / as its path delimiter, there's a little problem.
\
\     s" C:/Users/8304018/Documents/Dropbox/learnings/Forth/jeforth/JScript/cooked-raw.xls" constant cooked-file
\     cooked-file raw.xls save-as tib.
\
\         ------------------- P A N I C ! -------------------------
\         JScript error on word save-as next IP is 0 : Microsoft Excel �o����ȡ�n�� 'C:\//Users/8304018/Docume
\         nts/Dropbox/learnings/Forth/jeforth/JScript/5EEE0F10'������ԭ������:
\
\         ? �n�������Q��·�������ڡ�
\         ? ������ʽ����ʹ�Ùn����
\         ? ���Lԇ����Ļ�퓲����Q�cĿǰ�_���Ļ�퓲����Q��ͬ��
\         TIB:cooked-file raw.xls save-as tib.
\
\         Abort at TIB position 27
\         -------  [Yes] go on  [No] js console [Cancel] Terminate  -------
\         cooked-file raw.xls save-as tib. \ ==> Wistron resolved Price (string)
\
\ workbook.save-as does not accept \\ as its path delimiter.
\
\     s" C:\\Users\\8304018\\Documents\\Dropbox\\learnings\\Forth\\jeforth\\JScript\\cooked-raw.xls" constant cooked-file
\     cooked-file raw.xls save-as tib.
\
\         ------------------- P A N I C ! -------------------------
\         JScript error on word save-as next IP is 0 : �n���o����ȡ��Ո�_�����Ў׼����Ƿ����_:
\
\         ? �_����ָ���ęn���A�Ƿ���ڡ�
\         ? �_���n���A����Ψ�x��
\         ? �_���n�����Q������������Ԫ:  <  >  ?  [  ]  :  |  ��  *��
\         ? �_���n����·�����Q�����^ 218 ��λԪ�M��
\         TIB:cooked-file raw.xls save-as tib.
\
\         Abort at TIB position 27
\         -------  [Yes] go on  [No] js console [Cancel] Terminate  -------
\         cooked-file raw.xls save-as tib. \ ==> Component level (string)
\
\         OK cooked-file cr . cr
\         C:\\Users\\8304018\\Documents\\Dropbox\\learnings\\Forth\\jeforth\\JScript\\cooked-raw.xls
\         OK
\
\ ================== Access excel worksheet programmatically =====================
\
\ Excel automation �e����Ҫ�� object �� Range. ���� Cells, Rows, Columns �ȶ�����ԓ Range �ĸ��N
\ sub-range���� sub-range ֻ��һ��r, �� range.count == 1 �r, �ɮ��� scalar ʹ�ã��mȻ��
\ �Ԟ� Range object. ���� TARGET �ǂ� worksheet ������ã�
\
\     TARGET char pop().range("AB2")          js tib. ==> 11 (object)
\     TARGET char pop().range("AB2").cells    js tib. ==> 11 (object)
\     TARGET char pop().range("AB2").columns  js tib. ==> 11 (object)
\     TARGET char pop().range("AB2").rows     js tib. ==> 11 (object)
\
\ ��� Item �� Range ����� default property ��˿��Ծo������ Range() �� sub-range ����ָ�� (index), (
\ row,column) �ȡ� ���� cells(index) cells(row,column) columns(index) rows(index) �ȣ��䌍�� cells.
\ item(index) cells.item(row,column) �ȵȵĺ��������� index, row, column �� excel ���� 1 based (����
\ 0 based, �@�� forth �� for...next ���档). Range().Item() �ւ��� Range����Ȼ����� item() ������
\ rows, columns �� range����ʹ��һ��Ҳ��Ȼ�� range object.
\
\     TARGET char pop().range("AB2")(2)           js tib. ==> 21 (object)
\     TARGET char pop().range("AB2").cells(2)     js tib. ==> 21 (object)
\     TARGET char pop().range("AB2").columns(2)   js tib. ==> 12 (object)
\     TARGET char pop().range("AB2").rows(2)      js tib. ==> 21 (object)
\
\
\ ����ǰ������һ�ӵĖ|��������һ��͸�^ value property ȡ��ͬһ��ֵ�������R�ϕ��ᵽ��
\
\     TARGET char pop().range("AC3")                js tib. ==> 22 (object)
\     TARGET char pop().range("AC3")(1)             js tib. ==> 22 (object)
\     TARGET char pop().range("AC3").item(1)        js tib. ==> 22 (object)
\     TARGET char pop().range("AC3").item(1).value  js tib. ==> 22 (number)
\
\ ������ Range ��ֻһ������� (range.count != 1)�� Range object ����]�п�ֱ�ӿ����Ė|���ˡ�
\
\     TARGET char pop().range("AC3:AD4")            js tib. ==>  (object)
\
\ index row column �ȣ��o Item() �� input arguments ���� Range().count �����ƣ��@�Ӳź��á�
\
\     TARGET char pop().range("AC3:AD4")(0)         js tib. ==> 21 (object)
\     TARGET char pop().range("AC3:AD4").cells(0)   js tib. ==> 21 (object)
\
\     TARGET char pop().range("AC3:AD4")(1)         js tib. ==> 22 (object)
\     TARGET char pop().range("AC3:AD4").cells(1)   js tib. ==> 22 (object)
\
\     TARGET char pop().range("AC3:AD4")(-1)        js tib. ==> 12 (object)
\     TARGET char pop().range("AC3:AD4").cells(-1)  js tib. ==> 12 (object)
\
\ expression.value ���ػ��O��ָ��������ֵ�����x���� Variant (VBScript) �Y���͑B�� ���ָ���� Range ���
\ �ǿյģ��t���A�Oֵ������ Empty ֵ (VBScript IsEmpty, JavaScript �t�� null)����� Range �������������
\ ��񣬄t�����ص�һ�� VBArray ��ֵ��� (ʹ�� VBScript IsArray �����əz�y�� JScript �t�� unknown type)��
\ ���� value ���صĲ�һ����һ��ֵ��������Ҏ���� range.count �Д����⣬���� type �� unknown �r�ɔඨ����
\ �� VBArray��JScript can access VBArray through these methods :dimensions(), getItem(i), lbound(),
\ ubound(), and toArray(), where toArray() makes it a JavaScript array.
\
\   TARGET char pop().range("AB2:AC4").value.toArray() js tib. ==> 11,21,31,12,22,32 (array)
\
\ �@���е�Ч��
\
\   TARGET char pop().range("AC3:AD4").value.toArray() js tib.       ==> 22,32,, (array)
\   TARGET char pop().range("AC3:AD4").cells.value.toArray() js tib. ==> 22,32,, (array)
\
\ �� range.count �z���Ƿ�һ��
\
\   TARGET char pop().range("AC3:AD4").cells(-1).count js tib. ==> 1 (number)
\   TARGET char pop().range("AC3:AD4").count js tib.           ==> 4 (number)
\
\ ��һ��r�� value �� scalar ���]�� toArray() ���ã�
\
\   TARGET char pop().range("AC3:AD4").cells(-1).value.toArray() js tib.
\
\     ------------------- P A N I C ! -------------------------
\     JScript error : �����֧Ԯ�ˌ��Ի򷽷�
\     TIB:TARGET char pop().range("AC3:AD4").cells(-1).value.toArray() js tib.
\     Abort at TIB position 63
\     -------  [Yes] go on  [No] js console [Cancel] Terminate  -------
\
\ Excel Constant Definitions For VBScript And JScript (entire list in my evernote)
\   xlDown         =-4121 ( xlDown         )
\   xlToLeft       =-4159 ( xlToLeft       )
\   xlToRight      =-4161 ( xlToRight      )
\   xlUp           =-4162 ( xlUp           )
\   xlShiftDown    =-4121 ( xlShiftDown    )
\   xlShiftToRight =-4161 ( xlShiftToRight )
\   xlShiftToLeft  =-4159 ( xlShiftToLeft  )
\   xlShiftUp      =-4162 ( xlShiftUp      )
\   xlExcel9795    =0x2b  ( 43 xlExcel9795 )      see workbook.fileformat , Office 2012 : �o��ȡ��e Workbook �� SaveAs ����
\   xlWorkbookNormal =-4143 ( xlWorkbookNormal )  see workbook.fileformat
\
\ -------------- Background Color of a range -----------------------------
\
\ js>obj2.interior.colorindex=6 // Yellow background
\ Returned value of the statement is : 6  (number)
\
\ colorjs>obj2.interior.colorindex=-4142  // No color background
\ Returned value of the statement is : -4142  (number)
\
\ colorjs>obj2.cells(2,1).interior.colorindex=-4142
\ Returned value of the statement is : -4142  (number)
\

\ -------------- �������Y�� excel ����ϲ��T��λ ----------------------------------------------------

' wksrdcode [if]
	cr .( ====== �������Y�� excel ����ϲ��T��λ by jeforth.js, H.C. Chen ==== ) cr
	char . full-path char target.xls path+name constant target-file target-file tib.
	char . full-path char WKSRDCODE.xls path+name constant WKSRDCODE-file WKSRDCODE-file tib.
	target-file open.xls constant target.xls target.xls char pop().name js tib.
	WKSRDCODE-file open.xls constant WKSRDCODE.xls WKSRDCODE.xls char pop().name js tib.
	char CODE WKSRDCODE.xls get-sheet constant CODE CODE char pop().name js tib.
	1 target.xls get-sheet constant TARGET TARGET char pop().name js tib.
	CODE char B char D init-hash constant hash hash member-count tib.
	.( �������Y�ϱ���ϲ��T��λ . . . ) hash TARGET char B char G 1 hash-translate .( Job done!! ) cr
	target.xls save tib.
	\ target.xls close tib.
	\ WKSRDCODE.xls close tib.
	excel.app js> pop().Workbooks.Close tib. \ ==> true (boolean), close all workbooks
	bye
[then]

\ -------------- ������_�T -------------------------------------------------------------------------

' mylab [if]
  char . full-path char target.xls path+name constant target-file // ( -- string ) full path name
  target-file open.xls constant target.xls // ( -- obj ) workbook
  target.xls s" pop().fullname" js tib.
  1 target.xls get-sheet constant TARGET // ( -- obj ) worksheet
  TARGET char tos().name js tib.

  char . full-path char WKSRDCODE.xls path+name constant WKSRDCODE-file  // ( -- string ) full path name string
  WKSRDCODE-file open.xls constant WKSRDCODE.xls // ( -- obj ) workbook
  WKSRDCODE.xls s" pop().fullname" js tib.
  char CODE WKSRDCODE.xls get-sheet constant CODE // ( -- obj ) worksheet
  CODE char pop().name js tib.

  excel.app s" pop().Workbooks.count" js tib.
  excel.app s" pop().Workbooks(1).fullname" js tib.
  excel.app s" pop().Workbooks(2).fullname" js tib.
  char tos().range("AB2:AC4").Cells.item(1,1).cells.item(1).value=11 js tib.
  char tos().range("AB2:AC4").Cells.item(1,2).cells.item(1).value=12 js tib.
  char tos().range("AB2:AC4").Cells.item(2,1).cells.item(1).value=21 js tib.
  char tos().range("AB2:AC4").Cells.item(2,2).cells.item(1).value=22 js tib.
  char tos().range("AB2:AC4").Cells.item(3,1).cells.item(1).value=31 js tib.
  char tos().range("AB2:AC4").Cells.item(3,2).cells.item(1).value=32 js tib.
  char tos().range("AB2:AC4").item(1) js tib.
  char tos().range("AB2:AC4").item(2) js tib.
  char tos().range("AB2:AC4").item(3) js tib.
  char tos().range("AB2:AC4").item(4) js tib.
  char tos().range("AB2:AC4").item(5) js tib.
  char tos().range("AB2:AC4").item(6) js tib.
  char tos().range("AB2:AC4").item(1,1) js tib.
  char tos().range("AB2:AC4").item(1,2) js tib.
  char tos().range("AB2:AC4").item(2,1) js tib.
  char tos().range("AB2:AC4").item(2,2) js tib.
  char tos().range("AB2:AC4").item(3,1) js tib.
  char tos().range("AB2:AC4").item(3,2) js tib.
  char tos().range("AB2:AC4")(1,1) js tib.
  char tos().range("AB2:AC4")(1,2) js tib.
  char tos().range("AB2:AC4")(2,1) js tib.
  char tos().range("AB2:AC4")(2,2) js tib.
  char tos().range("AB2:AC4")(3,1) js tib.
  char tos().range("AB2:AC4")(3,2) js tib.
  char tos().range("AB2:AC4")(1) js tib.
  char tos().range("AB2:AC4")(2) js tib.
  char tos().range("AB2:AC4")(3) js tib.
  char tos().range("AB2:AC4")(4) js tib.
  char tos().range("AB2:AC4")(5) js tib.
  char tos().range("AB2:AC4")(6) js tib.
[then]

  ------------------ ���� try Range().name property  --------------------

    TARGET s' pop().range("ab2:ac3")' js constant ab2:ac3

    ab2:ac3 char pop().name          js tib. \ ==> "JScript error : ȱ�� ';'"
    \ �e�`ӍϢ����ͳ������ʡ�������Lԇȥ print �����ڵ� property �͕����_���f�� undefined.

    ab2:ac3 char pop().count         js tib. \ ==> 4 (number)
    ab2:ac3 char pop().name="ab2ac3" js tib. \ ==> ab2ac3 (string)
    ab2:ac3 char pop().name          js tib. \ ==> =����!$AB$2:$AC$3 (object) ע�⣡.name �ǂ� object.
    js>tos().range("rangeb2c3").name  ==> =����!$B$2:$C$3  (object)  ע�⣡.name �ǂ� object.
    js>tos().range("rangeb2c3").name.name ==> rangeb2c3  (string) , .name.name �������o�� name
    js>tos().range("rangeb2c3").name.value ==> =����!$B$2:$C$3  (string) �@�� value ���� .name �� default �܌��á�
    js>tos().range("rangeb2c3").count ==> 4  (number)
    js>tos().range("rangeb2c3").value.toArray() ==> 77,88,99,21,12,22  (array)

    js>b2c3.value ==> Oooops! �͑B������ , here .value is a VBArray. systemtype() ���J�� VBArray��
    js>var b2c3 = stack[0].range("b2:c3") \ ==> undefined, �Еr��Ҫ�� jsc �Ļظ���b2c3 �ǂ� Range() object, jsc ���J�á�
    js>var xx = b2c3 ==>  undefined. ���}�� b2c3 �xֵ�c var xx �r jsc Ҳ�ǻظ� undefined. �@�����Բ��������
    js>xx = b2c3     ==>  Oooops! ���Ͳ�ƥ�� , ��� js>systemtype(b2c3) ==> Oooops! ���Ͳ�ƥ��
    js>xx.count      ==> 4  (number)  ���ģ� Ч���]���}
    js>var yy; yy = xx = b2c3 ==> Oooops! ���Ͳ�ƥ�� , ������һ��
    js>var yy = xx = b2c3     ==> undefined. , ������һ��, ���� systemtype() �ĽY�������@�ӡ�
    js>yy.address           ==> $B$2:$C$3  (string)  ��Ҋ�䌍Ч���]�e��

--------------------------------------------------------------------------------------------------------

    mysheet s' tos().Range("A5:E10").printout' js . cr            ==> �a�� filename.jnt Journal file
    mysheet s' tos().Range("A5:E10").printpreview' js . cr        ==> Hang up !!
    TARGET s' tos().Range("A5:E10").Address' js . cr              ==> $A$5:$E$10

--------------------------------------------------------------------------------------------------------
    target.xls close
    WKSRDCODE.xls close

-------  find the target range's upper-left corner ---------------------------------------

    hcchen5600 2013/03/26 14:35:44  find the target range's upper-left corner

    To find a cell, use Excel built in find() method. Don't use for-loop and compare, as shown below,
    that wastes too much time.

    Sheet  Range or Cells   Ragne operations      Result and comments
    ------ ---------------- ----------------      -------------
    TARGET char tos().cells.count js tib. ==> 16777216 (number) ��"cells" �� Sheet() �D�� Range() �Ǳ�횵ġ�
    TARGET char tos().cells.find('�S̎') js tib. ==> �S̎ (object)
    TARGET char tos().cells.find('�S̎').address js tib. ==> $A$5 (string)
    TARGET char tos().cells.find('�T����̖') js tib. ==> �T����̖ (object)
    TARGET char tos().cells.find('�T����̖').address js tib. ==> $C$5 (string)
    TARGET char tos().cells.find('K0711').address js tib. ==> $C$21 (string) , find first
    TARGET char tos().cells.find('K0711').find('K0711').address js tib. ==> $C$257 (string) , find next
    TARGET char tos().cells.find('K0711').address js tib. ==> $C$21 (string) , ���^�_ʼ���� find
    TARGET char tos().cells.find('K0711').find('K0711').address js tib. ==> $C$257 (string) �����}�Y��

    code find-upper-left-ok ( sheet key -- range T|F ) \ Find the target position if it exists
        var key = pop();
        var sheet = pop();
        for (var i=1; i<=10000; i++) {
            var flag = (sheet.range("A1").item(i).value == key);
            if (flag) break;
        }
        if (flag) {
            push(sheet.range("A1").item(i));
            push(i);
        } else {
            push(false);
        }
        end-code
        /// tos(1).row tos(1).column is the found position
    TARGET s" �S̎" find-upper-left-ok .s
    s" tos(1).row   " js . cr
    s" tos(1).column" js . cr

    code find-upper-left ( sheet key -- range T|F ) \ Find the target position if it exists
        var key = pop();
        var sheet = pop();
        for (var c=1; c<=26; c++) {
            for (var r=1; r<=20; r++) {
                var flag = (sheet.range("A1").item(r,c).value == key);
                if (flag) break;
            }
            if (flag) break;
        }
        if (flag) {
            push(sheet.range("A1").item(r,c));
            push(true);
        } else {
            push(false);
        }
        end-code
        /// tos(1).row tos(1).column is the found position

    TARGET s" �S̎" find-upper-left .s
    s" tos(1).row   " js . cr
    s" tos(1).column" js . cr


\ -----------------  10 ways to reference Excel workbooks and sheets using VBA  -------------------------
\ evernote:///view/2472143/s22/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/

\ ActiveWorkbook : takes place without additional information, such as the workbook��s name, path, and so on.
excel.app js> pop().name tib. \ ==> Microsoft Excel (string)
excel.app js> pop().ActiveWorkbook.path tib. \ ==> X: (string)
excel.app js> pop().ActiveWorkbook.name tib. \ ==> WKSRDCODE.xls (string)
excel.app js> pop().ActiveWorkbook.close tib. \ ==> true (boolean) , a dialog box asks do you want to save before close.

\ Close all workbooks
excel.app js> pop().Workbooks.Close tib. \ ==> true (boolean) close all workbooks

\ ActiveSheet, sheet.name, and sheet._codename
excel.app js> pop().ActiveSheet.name tib. \ ==> CODE (string)
excel.app js> pop().ActiveSheet._CodeName="WKSRDCODE" tib. \ ==> Microsoft Excel (object) JScript error : ȱ�� ';'
excel.app js> pop().ActiveSheet._CodeName tib. \ ==>  (string) sheet._CodeName ֻ��͸�^ VBA IDE �Mȥ�� property.
excel.app js> pop().ActiveSheet._CodeName tib. \ ==> WKSRDCODE (string) �ĳɹ���
excel.app js> pop().ActiveSheet._codename tib. \ ==> Sheet2 (string)
excel.app js> pop().ActiveSheet.name tib. \ ==> CODE backup (string)
excel.app js> pop().sheets(1).name tib. \ ==> CODE (string)
excel.app js> pop().sheets(1)._codename tib. \ ==> WKSRDCODE (string)

\ ----------------------------------- Play with formula --------------------------------------
CODE js> pop().range("I156").formula tib. \ ==>  (string)  It was empty, a NULL.
CODE js> pop().range("I156").formula=11223344 tib. \ ==> 11223344 (number)
CODE js> pop().range("I156").formula="abcde" tib. \ ==> abcde (string)
CODE js> pop().range("I156").formula='=CONCATENATE(B156,"==",C156)' tib. \ ==> =CONCATENATE(B156,"==",C156) (string)
CODE js> pop().range("I156").formula tib. \ ==> =G156 (string)

\ ----------------------------------- Play with copy paste ------------------------------------
\ �˹����� Sheet1 �� A1:D4 �����Ĺ�ʽ�}�u�� Sheet2 �� E5:H8 ������С�
\ Worksheets("Sheet1").Range("A1:D4").Copy destination:=Worksheets("Sheet2").Range("E5") ==> destination:= �� JavaScript ��֪��α��_

CODE js> pop().range("G160").copy(destination:pop().range("I160")) tib. ==>JScript error : ȱ�� ')' destination:= �� JavaScript ��֪��α��_
CODE js> pop().range("G160").copy           tib. \ ==> true (boolean) �Ȱі|��ץ�M clipboard
CODE js> pop().range("A166").select         tib. \ ==> true (boolean) �� range �����x��
CODE js> pop().range("I160:C168").select    tib. \ ==> true (boolean) �� range �����x��
CODE js> pop().range("I160").paste          tib. \ ==> undefined (undefined) �@�ӌ�������ֱ���� sheet.paste ���_��
CODE js> pop().paste                        tib. \ ==> true (boolean) �� sheet �������_ paste ���

--------------------------------------------------

hcchen5600 2013/03/26 17:57:24  How to get an hash table from excel worksheet?

TARGET s" pop().Areas.count" js . cr
TARGET s" pop().Columns(1).Value" js . cr

Range("B2:C3").Columns(1).Value = 0

 OK TARGET char pop().columns(1)(1)(1) js tib.
TARGET char pop().columns(1)(1)(1) js tib. ==>  (object)
 OK TARGET char pop().columns(1)(1)(1)(1) js tib.
TARGET char pop().columns(1)(1)(1)(1) js tib. ==>  (object)
 OK TARGET char pop().columns(1)(1)(1)(1).address js tib.
TARGET char pop().columns(1)(1)(1)(1).address js tib. ==> $A:$A (string)
 OK TARGET char pop().columns(1).cells(1).address js tib.
TARGET char pop().columns(1).cells(1).address js tib. ==> $A$1 (string)
 OK TARGET char pop().columns(1).cells(1) js tib.
TARGET char pop().columns(1).cells(1) js tib. ==> origin (object)
 OK .s
empty  OK TARGET char pop().range("AA9:AC11).columns(1).address js tib.

------------------- P A N I C ! -------------------------
JScript error : δ�������ַ�������
TIB:TARGET char pop().range("AA9:AC11).columns(1).address js tib.
Abort at TIB position 56
-------  [Yes] go on  [No] js console [Cancel] Terminate  -------
TARGET char pop().range("AA9:AC11).columns(1).address js tib. ==>  (object)
 OK TARGET char pop().range("AA9:AC11").columns(1).address js tib.
TARGET char pop().range("AA9:AC11").columns(1).address js tib. ==> $AA$9:$AA$11 (string)
 OK TARGET char pop().range("AA9:AC11").columns(1).count js tib.
TARGET char pop().range("AA9:AC11").columns(1).count js tib. ==> 1 (number)
 OK TARGET char pop().range("AA9:AC11").cells.count js tib.
TARGET char pop().range("AA9:AC11").cells.count js tib. ==> 9 (number)
 OK TARGET char pop().range("AA9:AC11").columns.count js tib.
TARGET char pop().range("AA9:AC11").columns.count js tib. ==> 3 (number)
 OK TARGET char pop().range("AA9:AC11").columns.count js tib.

 OK   TARGET char tos().name js . cr                        ==> ����
 OK TARGET s' pop().Areas.count' js . cr                ==> JScript error : 'pop().Areas.count' Ϊ null ���Ƕ���
 OK TARGET s' pop().Areas' js .s                        ==> 0:  undefined (undefined) , Ҫ�� Range ���� Areas
 OK TARGET s' pop().Range("A1").Areas' js .s            ==> 0:  (object) , Ҫ�� Range ���� Areas
 OK TARGET s' pop().Range("A1").Areas.count' js .s  ==> 0:  1 (number)
 OK TARGET s' pop().Range("A1").Columns(1)' js .s       ==> 5:  undefined (object) , A1 is undefined so far.
 OK TARGET s' pop().Range("A1").item(1)' js .s      ==> 2:  undefined (object) , A1
 OK s' tos().item(1).value = 123' js .s                     ==> stack �e�Ė|�����@ʾ A1 ֵ֮���l����Ȥ�ĬF��
      0:        123 (object)
      1:        123 (object)
      2:        123 (object)
      3:        123 (number)
 OK drop drop drop .s
      0:        123 (object)
 OK s' tos(0).cells(2,1).value = 321' js .s
      0:        123 (object)
      1:        321 (number)
 OK dropall
 OK TARGET s' pop().Cells(1,1)' js . cr             ==> 123
 OK TARGET s' pop().Cells(2,1)' js . cr             ==> 321

 OK TARGET s' pop().Range("A1").Columns(1)' js .s           ==> 1: 123 (object)
 OK TARGET s' pop().Range("A1").Columns(2)' js .s           ==> 2: undefined (object) , ��߅һ��
 OK TARGET s' pop().Range("A1").Columns(1).item(1)' js .s   ==> 3: 123 (object)
 OK TARGET s' pop().Range("A1").Columns(1).item(2)' js .s   ==> 4: undefined (object) , ��߅һ��
 OK TARGET s' pop().Range("A1").Columns(1).item(2,1)' js .s ==> 5: JScript error : ȱ�� ';'
 OK TARGET s' pop().Range("A1").Columns(1).item(2).row' js .s ==> 6:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(1).item(2).column' js .s ==> 7:        2 (number)
 OK TARGET s' pop().Range("A1").Columns(0).item(2).column' js .s ==> JScript error : ȱ�� ';'
 OK TARGET s' pop().Range("A1").Columns(1).item(1).column' js .s ==> 8:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(1).item(1).row' js .s    ==> 9:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(1).item(2).row' js .s    => 10:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(1).item(2).column' js .s ==>11:        2 (number)
 OK TARGET s' pop().Range("A1").Columns(1).column' js .s           ==>12:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(1).row' js .s              ==>13:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(2).row' js .s              ==>14:        1 (number)
 OK TARGET s' pop().Range("A1").Columns(2).column' js .s           ==>15:        2 (number)
 OK dropall
 OK TARGET s' pop().Range("A1:B2").Columns(2).row' js .s       ==> 3:        1 (number)
 OK TARGET s' pop().Range("A1:B2").Columns(2).column' js .s  ==> 2:        2 (number)
 OK TARGET s' pop().Range("A1:B2").Columns(2).count' js .s   ==> 6:        1 (number)
 OK TARGET s' pop().Range("A1:B2").Columns(2).value' js .s   ==> 4:         (unknown) �Ж|��������֪��ɶ�|��
 ==> ���ػ��O��ָ��������ֵ�����x���� Variant �Y���͑B��expression.Value(RangeValueDataType)
     xlRangeValueDefault   ���ָ���� Range ����ǿյģ��t���A�Oֵ������ Empty ֵ (���� IsEmpty �����z�y�@�N��r)����
     �� Range ���������������񣬄t�����ص�һ����ֵ��� (ʹ�� IsArray �����əz�y���@�N��r)�����x/���� Variant �Y���͑B��
 ==> ���� value ���صĲ�һ����һ��ֵ������ type �� unknown �r��������������ǂ� VBArray ֮�ʡ�

 OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js .s ==> 0:         (object) Item ���Ԃ��� Range ���

 OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s           ==> 1:         (object) ����һ�� Range ��������������ָ�������еęڡ�Ψ�x��
 OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js .s ==> 7:         (object)
 OK TARGET s' pop().Range("A1:B2").Columns(2).item(4)' js .s ==> 8:         (object)
 OK TARGET s' pop().Range("A1:B2").Columns(2).item(2)' js .s ==> 4:         (object)
 OK TARGET s' pop().Range("A1:B2").item(2)' js .s              ==> 5:        undefined (object)
 OK TARGET s' pop().Range("A1:B2").item(4)' js .s              ==> 6:        22 (object)
 OK TARGET s' pop().Range("A1:B2").rows(2)' js .s              ==> 9:         (object)
 OK TARGET s' pop().Range("A1:B2").rows(2).columns(1)' js .s ==> 0:        321 (object)
 OK TARGET s' pop().Range("A1:B2").rows(2).columns(2)' js .s ==> 1:        22 (object)
 OK TARGET s' pop().Range("A1:B2").columns(2).rows(2)' js .s ==> 2:        22 (object)
 OK TARGET s' pop().Range("A1:B2").Columns(2).item(2).column' js .s => 5:        3 (number)
 OK TARGET s' pop().Range("A1").columns(2).rows(2)' js .s      ==> 3:        22 (object)
 OK
OK dropall
OK TARGET s' pop().Range("A1:B2").cells(1,1) = 11' js . cr
1
OK TARGET s' pop().Range("A1:B2").cells(1,2) = 12' js . cr
2
OK TARGET s' pop().Range("A1:B2").cells(2,1) = 21' js . cr
1
OK TARGET s' pop().Range("A1:B2").cells(2,2)' js . cr
2
OK ARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr

------------------ P A N I C ! -------------------------
rror! ARGET unknown.
IB:ARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr
bort at TIB position 5
------  [Yes] go on  [No] js console [Cancel] Terminate  -------

------------------ P A N I C ! -------------------------
Script error : 'pop()' Ϊ null ���Ƕ���
IB:ARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr
bort at TIB position 58
------  [Yes] go on  [No] js console [Cancel] Terminate  -------
ndefined
OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr

------------------ P A N I C ! -------------------------
Script error on word . next IP is 0 : ���Ͳ�ƥ��
IB:TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js . cr

bort at TIB position 61
------  [Yes] go on  [No] js console [Cancel] Terminate  -------

OK TARGET s' pop().Range("A1:B2").Columns(2)' js . cr

------------------ P A N I C ! -------------------------
Script error on word . next IP is 0 : ���Ͳ�ƥ��
IB:TARGET s' pop().Range("A1:B2").Columns(2)' js . cr

bort at TIB position 53
------  [Yes] go on  [No] js console [Cancel] Terminate  -------

OK TARGET s' pop().Range("A1:B2").Columns(1)' js . cr

------------------ P A N I C ! -------------------------
Script error on word . next IP is 0 : ���Ͳ�ƥ��
IB:TARGET s' pop().Range("A1:B2").Columns(1)' js . cr

bort at TIB position 53
------  [Yes] go on  [No] js console [Cancel] Terminate  -------

OK TARGET s' pop().Range("A1:B2").Columns(1)' js .s
     0:         (object)
OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s
     0:         (object)
     1:         (object)
OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s dropall
     0:         (object)
     1:         (object)
     2:         (object)
OK TARGET s' pop().Range("A1:B2").Columns(2)' js .s dropall
     0:         (object)
OK TARGET s' pop().Range("A1:B2").Columns(2).item(1)' js .s dropall
     0:         (object)
OK

hcchen5600 2013/03/27 19:09:31
 OK TARGET char tos().columns(1).value="col1" js . cr .s    ==> �������ж���һ��ֵ
      0:         (object)
      1:        "col1" (string)
 OK TARGET char pop().columns(1).value js . cr .s           ==> JScript error : �͑B������
 OK TARGET char pop().columns(1).value js .s                ==> 0: (unknown) , ���ǂ�ʲ�N��Type unknown.

 OK TARGET char pop().cells(10000,1).value js .s drop   ==> 0:        "col1" (string)
 OK TARGET char pop().cells(65536,1).value js .s drop   ==> 0:        "col1" (string)
 OK TARGET char pop().cells(65537,1).value js .s drop   ==> JScript error : ���Ҫ�� ';'

 OK TARGET char pop().columns(1).count js . cr .s       ==> 1 , ���f columns(1) ���Д��� 1
 OK TARGET char pop().columns.count js . cr .s          ==> 256 , ���f�@�� worksheet ���Д��� 256

 OK TARGET s' pop().Range("B2:C3").Columns(2).value' js .s   ==> 4:         (unknown) VBArray
 ==> ���ػ��O��ָ��������ֵ�����x���� Variant �Y���͑B��expression.Value(RangeValueDataType)
     xlRangeValueDefault   ���ָ���� Range ����ǿյģ��t���A�Oֵ������ Empty ֵ (���� IsEmpty �����z�y�@�N��r)����
     �� Range ���������������񣬄t�����ص�һ����ֵ��� (ʹ�� IsArray �����əz�y���@�N��r)�����x/���� Variant �Y���͑B��
 ==> ���� value ���صĲ�һ����һ��ֵ������ type �� unknown �r��������������ǂ� VBArray ֮�ʡ�Yes!!!
 OK TARGET s' pop().Range("B2:C3").Columns(2).value' js VBArray char pop().toArray() js . ==> 12,22 OK

 OK TARGET s' pop().Range("B2:C3").value' js VBArray s' pop().toArray()' js . ==> 11,21,12,22 OK
 OK TARGET s' VBArray(pop().range("B2:C3").value).toArray()' js . ==> 11,21,12,22 OK

\s --------------------- older study ---------------------------------------------------------------
\ s" pop().worksheets(pop()).select()" js drop <=== �Y���� Class Worksheet �� Select ����ʧ�����Ҳ������ automation ����r�� select() �]�����x��
\ s" pop().ActiveSheet" js <== ��Ȼ select() �]�����x��Active Ҳ������
\ hcchen5600 2013/03/26 11:03:00 ���m�l�F��
\ Visual Basic for Applications
\ Worksheets("Sheet1").Activate
\   'Can't select unless the sheet is active
\ Selection.Offset(3, 1).Range("A1").Select  <====

\ function runA()
\ {
\    var i=1,j=1,a=0;
\   for(i=1;i<4;i++)
\     { a=0;
\       for(j=1;j<5;j++)
\       {
\        a=a+oSheetA.Cells(i,j).value
\       }
\      oSheetB.Cells(i,4).value=a;
\     }
\ }        oSheetA

function runB()
{
    var j=0;
    for(j=1;j<4;j++)
      {
       oSheetB.Cells(j,1).value =  year;
       oSheetB.Cells(j,2).value =  month;
      }
}

\s
\ function Main()
\ {
\   runA();
\   runB();
\   oSheetB.SaveAs(Outpath+"B.xls");
\   oWB.Close(savechanges=false);
\   oWA.Close(savechanges=false);
\   WScript.Echo ("My work has finished!");
\ }

Main();
\s

code tib.  ( thing -- ) \ pring TIB(0, ntib) and the thing
    systemtype(tib.slice(0, ntib) + " ==> " + stack.pop() + "\n");
    end-code

-----------------------------------------------------------------------------------------------

code row.sum ( count col row sheet|cell|range -- sum ) \ Demo, get sum of an excel row
    fortheval("cell"); // ( count cell )
    var origine = pop().cells(1,1);
    var count = pop();
    var sum = 0;
    for (var col=1; col <= count; col++) {
        sum += origine(1,col);
    }
    push(sum);
    end-code

code colume.sum ( count col row sheet|cell|range -- sum ) \ Demo, get sum of an excel colume
    fortheval("cell"); // ( count cell )
    var origine = pop().cells(1,1);
    var count = pop();
    var sum = 0;
    for (var row=1; row <= count; row++) {
        sum += origine(row,1);
    }
    push(sum);
    end-code



function CreateNamesArray(){var saNames = [1,2,3,4,5,6,7,8,9];return saNames;}


function CreateNamesArray()
{  // Create an array to set multiple values at once.
  var saNames = [1,2,3,4,5,6,7,8,9];
  // saNames(0, 0) = "John"
  // saNames(0, 1) = "Smith"
  // saNames(1, 0) = "Tom"
  // saNames(1, 1) = "Brown"
  // saNames(2, 0) = "Sue"
  // saNames(2, 1) = "Thomas"
  // saNames(3, 0) = "Jane"
  // saNames(3, 1) = "Jones"
  // saNames(4, 0) = "Adam"
  // saNames(4, 1) = "Johnson"
  return saNames;
}

: GetIPAddress ( -- ) \ Get (all) IP Addresses
                s" where IPEnabled = true" objEnumWin32_NetworkAdapterConfiguration >r
                begin
                    r@ s' pop().atEnd()' js if r> drop exit then
                    r@ s' pop().item().IPAddress' js
                    r@ s' pop().moveNext()' js drop \ This is the way to iterate all network cards which may be multiple in this computer.
                again ;


TARGET char pop().Range("AB2:AB4") js constant r1
TARGET char pop().Range("AE2:AE4") js constant r2
r2 r1 TARGET char pop().Union(pop(),pop()) js tib.



WKSRDCODE.xls char pop().name           js tib. ==> WKSRDCODE.xls (string)
WKSRDCODE.xls char pop().sheets(1).name     js tib. ==> CODE (string)

CODE char pop().name js tib.
CODE char pop().columns(2).count js tib.
CODE char pop().range("B:B").count js tib.

code bottom         ( Column -- row# ) \ Get the bottom row# of the column
                    push(pop().rows(65535).end(-4162).row) // xlUp = -4162
                    end-code
                    /// It's too stupid that takes a lot of time if going along down to row#65535

CODE char pop().range("B:B") js bottom tib. \ ==> 160 (number)

code init-hash      ( sheet "columnKey" "columnValue"-- Hash ) \ get hash table from excel sheet
                    var columnValue = pop(), columnKey = pop(), sheet = pop();
                    var key = sheet.range(columnKey  +":"+columnKey);
                    push(key); fortheval("bottom"); var bottom = pop();
                    var val = sheet.range(columnValue+":"+columnValue);
                    var hash = {};
                    for (var i=1; i<=bottom; i++) {
                        if (debug)javascriptConsole(111,i,key,val,bottom);
                        if (key(i).value == undefined ) continue;
                        hash[key(i).value] = val(i).value;
                    }
                    push(hash);
                    end-code

CODE char B char D init-hash (see)

for (var i=0; i<key.count; i++) { if (key(i).value == undefined ) continue; hash[key(i).value] = val(i).value; }

var xlDown                        =-4121      ;// from enum XlDirection
var xlToLeft                      =-4159      ;// from enum XlDirection
var xlToRight                     =-4161      ;// from enum XlDirection
var xlUp                          =-4162      ;// from enum XlDirection
const xlShiftDown                 =-4121      ' from enum XlInsertShiftDirection
const xlShiftToRight              =-4161      ' from enum XlInsertShiftDirection
var xlShiftToLeft                 =-4159      ;// from enum XlDeleteShiftDirection
var xlShiftUp                     =-4162      ;// from enum XlDeleteShiftDirection

sheet.range("b:b").rows(65536).end(-4162).address



\ -----------------  10 ways to reference Excel workbooks and sheets using VBA  -------------------------
\ evernote:///view/2472143/s22/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/a9dbdd6e-d71c-4b5b-b607-9a75afb9a065/

\ ActiveWorkbook : takes place without additional information, such as the workbook��s name, path, and so on.
excel.app js> pop().name tib. \ ==> Microsoft Excel (string)
excel.app js> pop().ActiveWorkbook.path tib. \ ==> X: (string)
excel.app js> pop().ActiveWorkbook.name tib. \ ==> WKSRDCODE.xls (string)
excel.app js> pop().ActiveWorkbook.close tib. \ ==> true (boolean) , a dialog box asks do you want to save before close.

\ Close all workbooks
excel.app js> pop().Workbooks.Close tib. \ ==> true (boolean) close all workbooks

\ ActiveSheet, sheet.name, and sheet._codename
excel.app js> pop().ActiveSheet.name tib. \ ==> CODE (string)
excel.app js> pop().ActiveSheet._CodeName="WKSRDCODE" tib. \ ==> Microsoft Excel (object) JScript error : ȱ�� ';'
excel.app js> pop().ActiveSheet._CodeName tib. \ ==>  (string) sheet._CodeName ֻ��͸�^ VBA IDE �Mȥ�� property.
excel.app js> pop().ActiveSheet._CodeName tib. \ ==> WKSRDCODE (string) �ĳɹ���
excel.app js> pop().ActiveSheet._codename tib. \ ==> Sheet2 (string)
excel.app js> pop().ActiveSheet.name tib. \ ==> CODE backup (string)
excel.app js> pop().sheets(1).name tib. \ ==> CODE (string)
excel.app js> pop().sheets(1)._codename tib. \ ==> WKSRDCODE (string)

\ ----------------------------------- Play with formula --------------------------------------
CODE js> pop().range("I156").formula tib. \ ==>  (string)  It was empty, a NULL.
CODE js> pop().range("I156").formula=11223344 tib. \ ==> 11223344 (number)
CODE js> pop().range("I156").formula="abcde" tib. \ ==> abcde (string)
CODE js> pop().range("I156").formula='=CONCATENATE(B156,"==",C156)' tib. \ ==> =CONCATENATE(B156,"==",C156) (string)
CODE js> pop().range("I156").formula tib. \ ==> =G156 (string)

\ ----------------------------------- Play with copy paste ------------------------------------
\ �˹����� Sheet1 �� A1:D4 �����Ĺ�ʽ�}�u�� Sheet2 �� E5:H8 ������С�
\ Worksheets("Sheet1").Range("A1:D4").Copy destination:=Worksheets("Sheet2").Range("E5") ==> destination:= �� JavaScript ��֪��α��_

CODE js> pop().range("G160").copy(destination:pop().range("I160")) tib. ==>JScript error : ȱ�� ')' destination:= �� JavaScript ��֪��α��_
CODE js> pop().range("G160").copy           tib. \ ==> true (boolean) �Ȱі|��ץ�M clipboard
CODE js> pop().range("A166").select         tib. \ ==> true (boolean) �� range �����x��
CODE js> pop().range("I160:C168").select    tib. \ ==> true (boolean) �� range �����x��
CODE js> pop().range("I160").paste          tib. \ ==> undefined (undefined) �@�ӌ�������ֱ���� sheet.paste ���_��
CODE js> pop().paste                        tib. \ ==> true (boolean) �� sheet �������_ paste ���


 char .\cooked raw.xls save-as tib.
 raw.xls js> pop().name tib.
 raw.xls close tib.

 OK js> GetObject("","Excel.application") constant xls <======================= bingo!
 OK xls js> pop().name
 OK .
Microsoft Excel OK xls js> pop().worksheets.count tib.
xls js> pop().worksheets.count tib. \ ==> 1 (number)
 OK xls js> pop().worksheets(1).name tib.
xls js> pop().worksheets(1).name tib. \ ==> 90OK0JB5105340W (string)
 OK xls js> pop().workbooks.count
 OK .
1 OK xls js> pop().workbooks(1).name tib.
xls js> pop().workbooks(1).name tib. \ ==> cooked.xls (string)   constant xls <======================= bingo! was opened by GetObject

strange , open cooked.xls a.xls both ok, but not raw.xls why ?????
js> GetObject("x:/raw.xls") constant raw.xls tib. <==== "x:\raw.xls" does not work, must be "x:/raw.xls". But this is also strange.
ahhhhh! after js> GetObject("","Excel.application") constant xls , excel pops an error box says raw.xls not found, that's the problem!!!

 OK raw.xls js> pop().name tib. \ ==> undefined (undefined)  or may be it has opened alreay, excel sometimes doesn't popup error box!!
raw.xls js> pop().name tib. \ ==> raw.xls (string)
 OK raw.xls js> pop().application tib.
raw.xls js> pop().application tib. \ ==> Microsoft Excel (object)
 OK
====> log out first and see . . . .


--------------------- Study issues of opeing raw.xls ---------------------------------------
Key points are,
1. Excel's working directory is user\document, not the DOS box working directory.
2. The path string delimiter \ must be \\ because JavaScript is like C language they treats \ as
   an excape character in a string.
3. GetObject("file1.xls"), GetObject("file2.xls"), and double click file3.xls are all using the
   same "Excel.Application" handler.

   raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls
   Now open a.xls manually by double click it, and check again workbooks.count,
   raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
   raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string)

So, I don't need to afraid of re-opening an excel file now. Simply use GetObject() correctly.



    js> GetObject("raw.xls") constant raw.xls tib. ==========> Excel error box popup, says "�Ҳ��� 'raw.xls'��Ո�z��n���Ƿ���ƴ�e�����Ǚn��λ���Ƿ����_��", should be x:/raw.xls I guess.
    ------------------- P A N I C ! -------------------------
    JScript error :
    TIB:js> GetObject("raw.xls") constant raw.xls tib.
    Abort at TIB position 24
    -------  [Yes] go on  [No] js console [Cancel] Terminate  -------

 OK js> GetObject(".\\raw.xls") constant raw.xls tib.
 reDef raw.xlsjs> GetObject(".\\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
 OK raw.xls js> pop().path tib.
raw.xls js> pop().path tib. \ ==> D:\hcchen (string)
 OK


���� excel in task manager, if exists, then do it again and again, results are same. Simply x:/raw.xls is needed.

Retry with "x:\raw.xls" ......

   js> GetObject("x:\raw.xls") constant raw.xls tib.  \ ==> undefined (undefined)
   ------------------- P A N I C ! -------------------------
   JScript error :
   TIB:js> GetObject("x:\raw.xls") constant raw.xls tib.
   Abort at TIB position 27
   -------  [Yes] go on  [No] js console [Cancel] Terminate  -------

The result is like a garbage file pathname like x:dssdfsdfdsf and there's no Excel file not found popup error message as above.
So, "raw.xls" itself is strange. Because a.xls seems ok .... Nope, same as garbage filename. So now try "x:/raw.xls" . . . .

   js> GetObject("x:/raw.xls") constant raw.xls tib. \ ==> undefined (undefined)

Seems ok? Yes. I am sure "x:\filename.xls" works fine with Workbooks.open(). So \ or / depends on
Workbooks.open() or GetObject(). The fore one is excel and the rear one is JavaScript? No no no!!
The \ must be \\ instead, that simple. Also, the "raw.xls" implies using the default directory which
is user\document not the DOS box's working directory.

   js> GetObject("raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
   raw.xls js> pop().path tib. \ ==> D:\hcchen (string)

 OK js> GetObject("x:\\raw.xls") constant raw.xls tib.
 reDef raw.xlsjs> GetObject("x:\\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)

   raw.xls js> pop().name tib. \ ==> raw.xls (string)  Bingo!!

Now let's see the excel.app's .application.workbooks.count

   raw.xls js> pop().application.workbooks.count tib. \ ==> 1 (number)  Good, it's raw.xls

Now open a.xls manually by double click it, and check again workbooks.count,

   raw.xls js> pop().application.workbooks.count tib. \ ==> 2 (number)  Shoooo!!! Bin Bin Bingo!!!!
   raw.xls js> pop().application.workbooks(2).name tib. \ ==> A.XLS (string) Great, so automation uses the same excel.app.

So, I don't need to afraid of re-opening an excel file now. Simply use GetObject() correctly.




js> GetObject("x:\raw.xls") constant raw.xls tib.

------------------- P A N I C ! -------------------------
JScript error :
TIB:js> GetObject("x:\raw.xls") constant raw.xls tib.
Abort at TIB position 27
-------  [Yes] go on  [No] js console [Cancel] Terminate  -------
 reDef raw.xlsjs> GetObject("x:\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
 OK
 OK
 OK
 OK
 OK
 OK js> GetObject("x:/raw.xls") constant raw.xls tib.
 reDef raw.xlsjs> GetObject("x:/raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
 OK raw.xls js> pop().name tib.
raw.xls js> pop().name tib. \ ==> raw.xls (string)
 OK raw.xls js> pop().application tib.
raw.xls js> pop().application tib. \ ==> Microsoft Excel (object)
 OK

 OK js> GetObject(".\\raw.xls") constant raw.xls tib.
 reDef raw.xlsjs> GetObject(".\\raw.xls") constant raw.xls tib. \ ==> undefined (undefined)
 OK raw.xls js> pop().path tib.
raw.xls js> pop().path tib. \ ==> D:\hcchen (string)
 OK

------------------------ path name of excel file open save save-as is a problem  -------------------------


------------------- P A N I C ! -------------------------
JScript error on word save-as next IP is 0 : Microsoft Excel �o����ȡ�n�� 'C:\//Users/8304018/Docume
nts/Dropbox/learnings/Forth/jeforth/JScript/5EEE0F10'������ԭ������:

? �n�������Q��·�������ڡ�
? ������ʽ����ʹ�Ùn����
? ���Lԇ����Ļ�퓲����Q�cĿǰ�_���Ļ�퓲����Q��ͬ��
TIB:cooked-file raw.xls save-as tib.

Abort at TIB position 27
-------  [Yes] go on  [No] js console [Cancel] Terminate  -------
cooked-file raw.xls save-as tib. \ ==> Wistron resolved Price (string)
 OK
 OK

s" C:/Users/8304018/Documents/Dropbox/learnings/Forth/jeforth/JScript/cooked-raw.xls" constant cooked-file
s" C:\Users\8304018\Documents\Dropbox\learnings\Forth\jeforth\JScript\cooked-raw.xls" constant cooked-file
s" C:\\Users\\8304018\\Documents\\Dropbox\\learnings\\Forth\\jeforth\\JScript\\cooked-raw.xls" constant cooked-file


To prepare :
a. Unzip the AK1839r1.zip to a folder, say "c:\myjob\resolveasusbom".
b. Copy wistron.xls which is the cross reference table excel file to the above folder.
c. Done! You don't need to do this again until wistron.xls has a newer version.

To Cook :
1. Open the Asus BOM excel file which is to be resolved. Make it the *only* excel file or the program refuse working.
2. Press Win+r, type in c:\myjob\resolveasusbom\cook.bat and <enter> key to start cooking.
   If you see error message like "JScript error : Automation �ŷ���ʽ�o���a�����" you forgot to open
   the Asus BOM excel file first.
3. If everything fine, a new excel file with the name frefix 'cooked-' to your Asus BOM excel file
   will be created at the same folder as the raw.

Questions :
A. There are many components that have no quantity in the Asus' raw file. I assume 1 for them.
B. There are many components that have no price in the Wistron's reference file. I copy Asus' price instead.

----------------------- Usage guides --------------------------------------------------------------------------

\ Specify the number of Sheets In New Workbook. Default is 3, change it to 1.
excel.app js> pop().SheetsInNewWorkbook tib. \ ==> 3 (number)
excel.app js> pop().SheetsInNewWorkbook=1 tib. \ ==> 1 (number
excel.app js> pop().SheetsInNewWorkbook tib. \ ==> 1 (number)


\ �� boyce.xls �� sheet(1) copy �� emc.xls �� sheet(1) ֮ǰ
emc.xls boyce.xls js> pop().sheets(1).copy(pop().sheets(1))
emc.xls boyce.xls js> pop().sheets(1).copy(pop().sheets(1))
</comment>





