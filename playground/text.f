
see Ynote,

(<text>) is almost same as <text> but it consumes the 
next </text> in TIB and returns <text> + "</text>"

so if <text> hits <text> in TIB then it returns 
string1 +  "<text>" + (<text>) + <text> 
leaves the next </text> in TIB


				[ last literal ] ( ���o word <text> ���� )
				js: tos().nestLevel+=1 
                    
					over ( <text> string1 <text> )
					execute \ recurse nested level ( <text> string1 string2 )
					\ �� nested �����[�i�ӡA���ɦ^�Q�Y���� <text> token
					\ �p�G TIB �����A�N�n�ɦ^ </text>
						js> ntib<tib.length if ( <text> string1 string2 )
							s" </text> " +
						then
						( <text> string1 string2 ) + ( <text> string1 )
					swap ( string1 <text> )
					js: tos().nestLevel-=1 \ �w�� <text> �N�h�X�����W
					execute \ �ѤU�Ӫ����� ( string1 string2 )
					+ ( string )
					char </text> execute \ future word call by name

                    execute \ future word call by name
					( D: [string] ; R: <text> ) 
					js> rtos().nestLevel 
					( D: [string] level ; R: <text> ) 
					1- 0 max r> :: nestLevel=pop() ( [string] )

null value '<text> // ( -- <text> ) The <text> Word object, for indirect call.
                    
: (<text>)		( <text> -- "text"+"</text>" ) \ Auxiliary <text>, handles nested portion
                '<text> execute ( string ) \ ���� TIB �D </text> �Y���
				BL word char </text> = ( string is</text>? )
				if \ ��~���W�F </text> ( string )
					s" </text> " + ( string1' )
				then ;
                /// (<text>) is almost same as <text> but it consumes the 
                /// next </text> in TIB and returns <text> + "</text>"

: <text>		( <text> -- "text" ) \ Get multiple-line string, can be nested.
				char </text>|<text> word ( string1 )
				\ ���� delimiter ���U�ӫD <text> �Y </text> �n���N�O���
				BL word dup char <text> = ( string1 deli is<text>? )
				if \ ��~���W�F <text> ( string1 deli )
					drop s" <text> " + ( string1' )
                    (<text>) ( string1' string2 ) + 
                    [ last literal ] execute ( string1'' string3 ) + ( string )
				else \ ��~���W�F </text> �Φ��  ( string1 deli )
					char </text> swap over = ( string1 "</text>" is</text>? ) 
                    if js: ntib-=pop().length ( string1 )
                    else drop then  ( string1 )
				then ; immediate last to '<text>
                /// If <text> hits <text> in TIB then it returns 
                /// string1 +  "<text>" + (<text>) + <text> 
                /// leaves the next </text> in TIB
                /// Colon definition ���U�@�e�ᤣ ballance �|�y�� colon definition
                /// ���p�w�������Ӱ��d�b compiling state �̵� closing </text> ���{�H�C
				
: </text> 		( "text" -- ... ) \ Delimiter of <text>
				compiling if literal then ; immediate
				/// Usage: <text> word of multiple lines </text>

dropall 11 22 33
: tt <text> aa <text> bb </text> cc </text> 77 ;
[ q ]
[ .s ]


�ڦ��N�� <comment> supports nesting �F, �ۤv���ѤF�C���O�Ψ� ' <comment> :: level
�٬O���z�Q�C�H�W <text> </text> �w�g�i�H��� recursion �N���� nesting supports
��ӿ�k��g�ݬݡC

: <comment>		( <comemnt> -- ) \ Can be nested
				[ last literal ] :: level+=1 char <comment>|</comment> word drop 
				; immediate last :: level=0

: </comment>	( -- ) \ Can be nested
				['] <comment> js> tos().level>1 swap ( -- flag obj )
				js: tos().level=Math.max(0,pop().level-2) \ �@�ߴ�@�A�A�w��@�����U���[�^��
				( -- flag ) if [compile] <comment> then ; immediate 

\ If <comment> hits <comment> in TIB then it drops string1 
\ and does <comment> and does again <comment>

: <comment>		( <comemnt> -- ) \ Can be nested
				char <comment>|</comment> word drop ( empty )
				BL word char <comment> = ( is<comment>? )
				if \ ��~���W�F <comment> ( empty )
					[ last literal ] dup execute execute
				then ; immediate
				
: </comment>	; // ( -- ) \ Delimiter of <comment>

				
				