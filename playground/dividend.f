\ 
\ jeforth.3ce Ū���u�O�W�Ȧ�v���u���v������v�ä����v�A�p�G���s���N�o�X alert�C
\ ���� localStorage �J�s���q�C��A�ҥH�������]�٬O�O�oŪ��L�����q�C
\
\ �n��ʥ��ǳƪ�����
\ 1. open the data page 
\    > js: window.open("http://fund.bot.com.tw/z/ze/zeb/zeba.djhtm")
\ 2. open 3ce page
\ 3. Assign tabid
\    > list-tabs \ get tabid
\      228 ���v������-�̪Ѹ�
\    > 228 tabid! \ setup tabid 

    : Refresh_the_target_page ( -- ) \ Refresh the tabid target page.
        tabid js: chrome.tabs.reload(pop())
        500 nap tabid tabs.get :> status!="complete" if
            1500 nap \ Do my best to allow the title to become available
            ." Still loading " tabid tabs.get :> title . space
            0 begin
                tabid tabs.get :> status=="complete" if 1+ then
                dup 5 > if ( TOS ���� until ) else \ 5 complete to make sure it's very ready.
                    char . . 300 nap false
                then
            until ."  done! " cr
        then ;
        /// Improve this if the target page is unstable then we need to timeout and retry.

    : find-next-company ( i -- i' ) \ Find next �w�������v���骺���q in �x�Ȱ��v������ return index or zero.
        s" var last_index = " swap + [compile] </ce> \ setup variable for the target page
        <ce>
        var next_index = 0;
        var array_td = document.getElementsByTagName("td");
        for (var i=last_index+1; i<array_td.length; i++){
            if (array_td[i].id == "oAddCheckbox") { // �O�W�Ȧ檺���v������~���o�� id 
                next_index = i;
                break;
            }
        };
        next_index;
        </ceV> :> [0] ;

    : company-name ( i -- name ) \ Convert index of <td> to company name
        <ce> var array_td = document.getElementsByTagName("td"); </ce>
        char array_td[ swap + char ].innerText + 
        [compile] </ceV> :> [0] ;

    : get-company-hash ( -- hash count ) \ Get the company names of �x�Ȱ��v������C
        <ce> var array_td = document.getElementsByTagName("td");</ce>
        {} ( hash ) 0 ( count ) 0 ( index ) begin 
            find-next-company dup ( hash count idx' idx' ) 
        while 
            ( hash count idx' ) swap 1+ swap ( hash count++ idx' )
            dup company-name ( hash count++ idx' name )
            js: tos(3)[pop()]=true ( hash count++ idx' )
        repeat   ( hash count++ 0 ) drop ;

    : save-company-hash ( hash -- ) \ Save company hash to local storage key 'company-hash'.
        js> JSON.stringify(pop()) ( json )
        js: localStorage["company-hash"]=pop() ;
        /// localStorage["company-hash"] is JSON

    : restore-company-hash ( -- hash ) \ Read company hash from local storage key 'company-hash'.
        js> localStorage["company-hash"] 
        js> tos()==undefined if null else js> JSON.parse(pop()) then ;
        /// localStorage["company-hash"] is JSON

    : isSameHash ( h1 h2 -- boolean ) \ Compare two hash table
        <js> 
        var flag = true;
        for (var i in tos(1)){ // ���Y�U��@��
            if (tos()[i]!==true) flag = false;
            break;
        }; 
        for (var i in tos()){ // ���Y�U��@��
            if (tos(1)[i]!==true) flag = false;
            break;
        }; execute("2drop"); flag </jsV> ;

    : check_updated ( -- ) \ Check if �x�Ȱ��v������ is updated
        restore-company-hash ( hash0 ) obj>keys :> length if \ Init check
            now t.dateTime . ."  localStorage company hash = " restore-company-hash dup (see)
            get-company-hash drop dup -rot isSameHash if ( company-hash )
                drop ." , no update since the last check." cr
            else  ( company-hash )
                s" , something new updated. Check it out!" 
                dup . cr js: alert(pop())
                dup (see) save-company-hash
            then
        else 
            \ initialize
            get-company-hash drop save-company-hash
        then ;

\ Check every hour

    run: begin Refresh_the_target_page check_updated 1000 60 * 60 * nap again

<comment>
	
	\ Obloleted words
	
    : count_oAddCheckbox ( -- n ) \ Get the company count of �x�Ȱ��v������C
        0 ( count ) 0 ( index ) begin 
            find-next-company dup ( count idx' idx' ) 
        while 
            ( count idx' ) swap 1+ swap 
        repeat  ( count 0 ) drop ;
        /// Item count does not mean much, because the table cuts items 
        /// before yesterday.

    : check_oAddCheckbox_count ( -- ) \ Check if �x�Ȱ��v������ is updated <== obsoleted
        js> localStorage.oAddCheckbox_count ( init check ) if
            now t.dateTime . ."  localStorage.oAddCheckbox_count = " js> localStorage.oAddCheckbox_count .
            count_oAddCheckbox js> localStorage.oAddCheckbox_count int = if
                ." , no update since the last check." cr
            else
                s" , something new updated. Check it out!" 
                dup . cr js: alert(pop())
                count_oAddCheckbox js: localStorage.oAddCheckbox_count=pop()
            then
        else 
            \ initialize
            count_oAddCheckbox
            js: localStorage.oAddCheckbox_count=tos()
            js> localStorage.oAddCheckbox_count!=pop() if
                s" Error! Your browser does not support HTML5 localStorage." 
                dup . cr "msg"abort
            then
        then ;

</comment>
