\s
\	playCSS.f CSS ���絧�O
\

\ [x] �d�쪩�� baseStyle innerHTML
	js> styleBase ce! ce@ dup se :> innerHTML . \ ==> �J�ӬݤU�C���G�A�o�ǳ]�w�X���X�z�C
	[object HTMLStyleElement] id='styleBase'; innerHTML= body { font-family: courier new; font-size: 20p...
		0 : [object Text]  body { font-family: courier new; font-size: 20px; padding:20px; word-wrap:break-word;...

		body {
				color:black; /* font color */
				font-family: courier new;  /* �X�z�A�o�Ӧr��̰� */
				font-size: 20px; /* �X�z */
				padding:20px; /* �X�z�A�����|�P�d��, border ���r���Z�� */ 
				word-wrap:break-word; /* �X�z�Awrap-around �ɱĭ^�� word ���_��A�ӫD charactor */ 
				border: 1px ridge; /* �s��A�u���@���u */
				background:#F0F0F0; /* �Ǧ�I�� */
		}
		textarea {
				width:100%; /* �W�� body �S�����]�w */
				border: 0px solid;  /* ���� body �즳���]�w */
				background:#BBBBBB; /* ���� body �즳���]�w */
		}
	OK

[x] [CSS ���O] �p��b�@�� <tag> �̥ΤW�h�� class �H��K CSS ����? ����إD�D�A
	[x] �D�D�@�O <style> tag �X�{���ɶ���m�P�ؼ� node ���������Y�C 
		���סG�h�� style tag �Y�ϬO�H�a�� child �]���O global�A�i���N�����Y�@
			  �ӡA�ĪG�û��O��Ӫ��p���A�B overlap �����᭱�\�e���C
		
		\ ���� element �A�� global style ���ġC�d��]�A children, �p element class=cc �̡C
		<o> <div id=t1><span id=ii>My id is ii. { <span class=cc>My class is cc.</span> } </span></div></o> constant t1 // ( -- element ) <div> t1
		<text> #ii{color: blue;border: 2px solid red;}</text> js> styleBase :: innerHTML=pop()

		\ restart > ���� element > �M��[�W�s�� style �h�� id=ii, ----> ���ġI
		<o> <div id=t1><span id=ii>My id is ii. { <span class=cc>My class is cc.</span> } </span></div></o> constant t1 // ( -- element ) <div> t1
		<o> <style id=s1 type="text/css">#ii{border:1px solid red;background:#2020E0;}</style></o> drop
		
		\ �A�� ---> �٬O���ġC
		<o> <style id=s1 type="text/css">#ii{border:1px solid red;background:#a0a0a0;}</style></o> drop	
		
		\ �ݬ� outputbox �� ce tree�A���G�h�Ӥ��۽Ĭ� style �]�w�A���̤@�ӥͮġH�]��^
		OK eleDisplay ce! ce
		[object HTMLDivElement] id='outputbox'; innerHTML=<div id="t1"><span id="ii">My id is ii. { <span cl...
		0 : [object HTMLDivElement] id='t1'; innerHTML=<span id="ii">My id is ii. { <span class="cc">My class is...
		1 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#2020E0;}...
		2 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#a0a0a0;}...
		3 : [object Text]  OK ...
		4 : [object Text] eleDisplay ce! ce...
		5 : [object HTMLBRElement] 

		\ Create div id=t1 �� outputbox �H�~���a��]�� htmlplayground.f �䤤�S���ӵ� style�^�ݷ|��ˡC�]�Ӽ˨��v�T�^
		include htmlplayground.f 
		<p> <div id=t1><span id=ii>My id is ii. { <span class=cc>My class is cc.</span> } </span></div></p> constant t2 // ( -- element ) <div> t2 in playground
		\ ���G���G�Ӽ˦��ġI --> cls �ݬ� --> �G�M playground �̪� t2 ���W���h styleBase �H�~�� styles�C
		\ �ҩ� style s1 �o�˪��]�w���M�O global ���C�ڲq�e���Y������@�����ӷ|��_�W�@�Ӫ��ĪG�A�]��^
		OK ce
		[object HTMLDivElement] id='outputbox'; innerHTML=<div id="t1"><span id="ii">My id is ii. { <span cl...
			0 : [object HTMLDivElement] id='t1'; innerHTML=<span id="ii">My id is ii. { <span class="cc">My class is...
			1 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#2020E0;}...
			2 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#a0a0a0;}...
			3 : [object Text]  OK ...
			4 : [object Text] ce...
			5 : [object HTMLBRElement] 
		OK ce 2
		[object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#a0a0a0;}...
			0 : [object Text] #ii{border:1px solid red;background:#a0a0a0;}...
		OK ce@ removeElement
		\ �G�M�I�I
		
		\ ���̦��h�h���c�Aborder �� inherit �O�H�k��C��s�ݬݡA
		\ �G�N�ˤ@�Ӫ��A�̭��� style �� global ���P�A�C�� row �]���P�C
		\ �o�ӥu���̥~�馳 border �]�� border ���| inherit, �� color,font-size �o�|�۰� inherit�C
		\ jeforth.3we �����X�A�| include �F��G���A�X�� global style, �ɶq�� local ���t�X�h�� class�C
		\ �H�U�S���Ψ� multiple class �N���\�F�C
		<o> Before the table. 
			<style>
				.tablea td { border:5px solid blue;color: blue;font-size: 36px;}
			</style>
			<table class=tablea>
			<tr><td>11</td><td>12</td></tr>
			<tr><td>21</td><td>22</td></tr>
			</table> 
			<table>
			<tr><td>11</td><td>12</td></tr>
			<tr><td>21</td><td>22</td></tr>
			</table> 
		After the table</o> drop
		\ �H�W <tr> �b border �W����t���򨤦�A�i��O�� <tr> �� <td> ���G�C
		\ �Y�� <td> �� <tr> �h�q�Q�N�O�H <tr> ���ǡC����p�U�A�]���I�S���o�ء^
		<o> Before the table. 
			<style>
				.tableb tr { border:5px solid blue;color: green;font-size: 36px;}
			</style>
			<table class=tableb>
			<td><tr>11</tr><tr>12</tr></td>
			<td><tr>21</tr><tr>22</tr></td>
			</table> 
			<table>
			<td><tr>11</tr><tr>12</tr></td>
			<td><tr>21</tr><tr>22</tr></td>
			</table> 
		After the table</o> drop

	[x] �D�D�G�O CSS ���g�k, see "Multiple Class / ID and Class Selectors" http://css-tricks.com/multiple-class-id-selectors/
		class attribute ���ӴN�i�H multiple, see ---> http://www.w3schools.com/tags/att_global_class.asp
		class="class1 class2 class3" ��C

	[ ] �e���Q�ר� 'element element' selector �ܰ����A�i�H localize �]�w�A���I�� input �n���N����
		�F�]��A�u�O��ӳQ��F�^�Cinput �n�����O global ���H�D�]�A'element element' selector �� input ���ġC
		���O input �X�{�b table class=alarm �̭������� input �N�|�~�� .alarm �� style�C<table class=alarm> 
		�u�O���o�� table �M�� .alarm �� style, table �̭��u�� table �ۤv���F�� (th, tr, td ��) �M�Ψ�A�{�b
		�^�Y�ݡA���T�O�o�ӷN��C�Y�n���� table �̪� input �M�� .alarm �� style, ���T��F�� .alarm input {}
		�~��A�]�N�O���A�� .alarm {} �B <table class=alarm> �P table �̪� input �L���C
		
	[ ]	CSS �� Specificity Rules�Ahttp://css-tricks.com/specifics-on-css-specificity/
		style �̧ǮM�W��Z�A���G�e�{���̧ǳQ���檺���G�A�V�᭱���ͮġC�o�O��P��
		Specificity ���F��Ө��C�_�h�A���S�w�� higher specificity �ͮġA���ץX�{���ǡC
		�ҥH���ǬO���X�z���v�T�O�A���C��S�w�� Specificity�C
		
	[ ]	�o�O�ӥ� 'element ~ element' selector ���Ҥl�C�i��ܦ��ΡC     hcchen5600 2015/02/12 14:41:36 
		<!DOCTYPE html>
		<html>
		<head>
		<style> 
		.project1 ~ ul {
			background: #ff0000;
		}
		.project2 ~ ul, .project2 ~ input {
			background: #00ff00;
		}
		/* .project2 ~ input {
			background: #00ff00;
		} */
		</style>
		</head>
		<body>

		<div>A div element.</div>
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		</ul>
		<input type=text />
		<hr class=project1>
		The first paragraph.
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		  <li><input type=text /></li>
		</ul>
		<input type=text />

		<hr class=project2>
		<h2>Another list</h2>
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		</ul>
		<input type=text />

		<hr class=project1>
		<h2>The third paragraph ���p�w���A�]�� style �w�g����L�F�A���G�O�̫����쪺 project2</h2>
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		  <li><input type=text /></li>
		</ul>
		<input type=text />

		</body>
		</html>

\ -----------------------------------------------------------------------------------------------------------

	CSS �s�� <span> �p�G���S���] color:green �h�Ĥ@�� <span> �]�F����A�H�U�����ܦ�, say, ���C
	�@��ı�o�_�ǡA�Q�Q�o�ӳ]�p�]���D�z�A�_�h�o�������h�g style attribute ���O�ܲ¡H
	
		<div id=almReset><span id=reset_button style="color:black">RESET<span><br><span id=clear_button style="color:gray">CLEAR</span></div>
		OK js> start_button :: setAttribute('style','color:black')
		OK js> start_button :: setAttribute('style','color:gray')
		OK js> start_button :: setAttribute('style','color:black')
