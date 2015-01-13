\ Big5

\
\ studying << ���zJavaScript >> 
\

\ Page 1
\ 	5 basic types : undefined null boolean number string
\   1 object type
	
	undefined undefined = tib. \ ==> true (boolean)
	undefined undefined === tib. \ ==> true (boolean)
	undefined js> stack[1000] === tib. \ ==> true (boolean)

	see undefined
	\				name : undefined (string)
	\				help : undefined    ( -- undefined ) Get an 'unsigned'. (string)
	\				vid : forth (string)
	\				wid : 41 (number)
	\			creater : code (array)
	\			testCase : [object Object] (array)
	\				xt :
	\	function(){ /* undefined */
	\		push(undefined)
	\	}

  	: example.page-2  ( -- ) 
		inline
		var life = {}; 
		for(life.age = 1; life.age <= 3; life.age++) { // for loop can be used on JavaScript console directly
			switch (life.age) { 
				case 1: 
					life.body = "�Z�ӭM\n";   
					life.say = function (){systemtype( this.age + this.body)}; // 'this' is 'life' in the function
					life.say2 = function (){systemtype( life.age + life.body)}; // 'this' is 'life' in the function
					if(debug)javascriptConsole(111,this,life); // now 'this' is the jeforth 'global'!!, === is true, really. 'life' is the correct thing.
					break; 
				case 2: 
					life.tail = "����"; 
					life.gill = "�|\n"; 
					life.body = "���B"; 
					life.say = function (){systemtype( this.age + this.body + "-" + this.tail + "," + this.gill)}; 
					life.say2 = function (){systemtype( life.age + life.body + "-" + life.tail + "," + life.gill)}; 
					if(debug)javascriptConsole(111,this,life);
					break; 
				case 3: 
					delete life.tail; 
					delete life.gill; 
					life.legs = "�|���L"; 
					life.lung = "��\n"; 
					life.body = "�C��"; 
					life.say = function (){systemtype( this.age + this.body + "-" + this.legs + "," + this.lung)}; 
					life.say2 = function (){systemtype( life.age + life.body + "-" + life.legs + "," + life.lung)}; 
					if(debug)javascriptConsole(111,this,life);
					break; 
			}; 
			life.say(); 
			life.say2();  // say2() works the same as say(). But say2() can only works on the 'life'.
		}; 
		end-inline
	; last execute
	/// 1�Z�ӭM
	/// 1�Z�ӭM
	/// 2���B-����,�|
	/// 2���B-����,�|
	/// 3�C��-�|���L,��
	/// 3�C��-�|���L,��
	/// OK
	/// JavaScript Object is dynamically changable

	: arguments.length  ( -- expected-number actual-number ) \ JavaScript knows expected and actual argument number of a function
		<js>
			function test(a,b,c){ /* Expected number of arguments is 3 */
				systemtype("Expected number of arguments is " + test.length+"\n"); 
				systemtype("Actual number of arguments is " + arguments.length+"\n"); 
			}
			test(1,2,3,4,5,6,7,8); /* Actual number of arguments is 8 */ 
		</js>
		drop
	; last execute
	/// Expected number of arguments is 3
	/// Actual number of arguments is 8
	/// I didn't know function has the .length intrinsic property.
	/// Other intrinsic properties of a function are .arguments .caller .constructor .prototype
	/// Also intrinsic methods are toString() valueOf() and call()
	///

\  page 5 ~ page 6

	: function_&_its_member ( -- ) \ 
		<js>
			var era = "���"; /* this era will be used, because the member .era does not exist */
			var poem = "��X�~�[�K�A�븨���s�e�F�k��\�]��A�w�ۤT�d�~�C"; /* this 'poem' will not be used because .poem is a member */
			function Sing() 
			{ 
				with (arguments.callee){ /* specify priority when looking for a thing */
					systemtype(author + "�G " + poem + "\n" + era + "\n"); 
				}
			}; 
			Sing.author = "����"; 
			Sing.poem = "�~�a���a��A�y�v�ө��m�F�@�W�����D�A�ѲP�h���k�C"; 
			Sing();
		</js>
		drop
	; last execute
	/// function test(){ return this.value }
    /// �o�� this.value ���O test() �� property �ӬO global ���A���� global.value�C
	/// �]�� test() �O global ���@�� method.
    /// ���� test.value = 123; test(); ���G�٬O undefined! ��G�H test() �̩� access �� this.value 
	/// ���O test.value �ӬO global.value (���ɬO undefined)
	/// 
	/// Unlike other languages, JavaScript's 'this' has a different meaning. Therefore, if want to 
	/// refer to properties of the function or object, properties are like static variables of the function
	/// of object, use with(arguments.callee){...} block. Use (function_name.property_name = init_value) to
	/// initialize the static variables. Also use arguments.callee.static_variable_name=init_value directly.

	: static_variables ( -- ) \ 
		<js>
			function try_static () {
				arguments.callee.author = "����"; 
				arguments.callee.poem = "�~�a���a��A�y�v�ө��m�F�@�W�����D�A�ѲP�h���k�C"; 
				systemtype(arguments.callee.author + "�G " + arguments.callee.poem + "\n"); 
			}
			try_static();
			systemtype("Access static variable from out side : " + try_static.author + "  " + try_static.poem + "\n");

			var myobj = new try_static;
			myobj.author = "H.C. Chen";
			myobj.poem = "�ѥS�A�A�w�gíí�a��W�F���~�C";
			javascriptConsole(111,myobj,try_static);
		</js>
		drop
	; last execute


\ page 7

	: WhoAmI ( -- ) 
		<js>
			function WhoAmI() { 
				systemtype("I'm " + this.name + " of " + typeof(this) + "\n"); 
			};
			WhoAmI();
			var BillGates = {name: "Bill Gates"}; 
			BillGates.WhoAmI = WhoAmI;
			BillGates.WhoAmI();
		</js>
		drop
	; last execute
	/// I'm undefined of object
	/// I'm Bill Gates of object

	: WhoAmI ( -- ) 
		inline
			function WhoAmI() { 
				systemtype("I'm " + this.name + " of " + typeof(this) + "\n"); 
			};
			WhoAmI();  // 'this' is global, it does not have the .name property thus I'm undefined ....

			var BillGates = {name: "Bill Gates"}; 
			BillGates.WhoAmI = WhoAmI;  
			BillGates.WhoAmI(); // 'this' is now BillGates
			
			var SteveJobs = {name: "Steve Jobs"}; 
			SteveJobs.WhoAmI = WhoAmI;
			SteveJobs.WhoAmI();  // 'this' is now SteveJobs

			WhoAmI.call(BillGates); // 'this' is now BillGates
			WhoAmI.call(SteveJobs); // 'this' is now SteveJobs
			
			BillGates.WhoAmI.call(SteveJobs); // 'this' is now SteveJobs
			SteveJobs.WhoAmI.call(BillGates); // 'this' is now BillGates
			
			WhoAmI.WhoAmI = WhoAmI; 
			WhoAmI.name = "WhoAmI"; 
			WhoAmI.WhoAmI();   // 'this' is now WhoAmI
			
			({name: "nobody", WhoAmI: WhoAmI}).WhoAmI(); // 'this' is now anonymous
 
		end-inline
	; last execute
	/// sI'm undefined of object
	/// sI'm Bill Gates of object
	/// sI'm Steve Jobs of object
	/// sI'm Bill Gates of object
	/// sI'm Steve Jobs of object
	/// sI'm Steve Jobs of object
	/// sI'm Bill Gates of object
	/// sI'm WhoAmI of function
	/// sI'm nobody of object

\ page 12 Prototype
	
	: prototype-and-sub-class ( -- ) \ 
		inline
			function Person(name) // base class constructor 
			{ 
				this.name = name; 
			}; 

			Person.prototype.SayHello = function () // add mathod to base class' prototype
			{ 
				systemtype("Hello, I'm " + this.name +"\n"); 
			}; 

			function Employee(name, salary) // constructor of sub class
			{ 
				Person.call(this, name); // invoke base class constructor
				this.salary = salary; 
			}; 

			Employee.prototype = new Person();  
				// This is very interesting. Note! object.prototype is an object! or base-class.

				// Create a base class object, Person(), which is to be, Employee(), sub-class' 
				// prototype. SteveJobs can't SayHello() without this prototype.

				// Person(name) has an argument which is absent here. That
				// doesn't matter. Because during the run time of the constructor 
				// Employee(), Person.call(this, name) will initialize the Employee.name property.
				// We want Employee.SayHello which is the real purpose.

			Employee.prototype.ShowMeTheMoney = function () // add method to sub-class constructor's prototype
			{ 
				systemtype(this.name + " $" + this.salary + "\n"); 
			}; 

			var BillGates = new Person("Bill Gates"); // create base class Person BillGates object
			var SteveJobs = new Employee("Steve Jobs", 1234); // create sub-class Employee SteveJobs object
			BillGates.SayHello(); // invoke prototype method via object directly  
			SteveJobs.SayHello(); // Note! invoke bass-class prototype method via sub-class object
			SteveJobs.ShowMeTheMoney(); // invoke sub-class prototype via sub-class object
			systemtype(BillGates.SayHello == SteveJobs.SayHello); // true, prototype method is shared
		end-inline
	; last execute
	/// Hello, I'm Bill Gates
	/// Hello, I'm Steve Jobs
	/// Steve Jobs $1234
	
\ closure
\ evernote:///view/2472143/s22/a6f5d481-6664-4c81-a337-7e0b4709422b/a6f5d481-6664-4c81-a337-7e0b4709422b/

	: create_counter ( start -- counter ) \ Create a counter function which returns a increamental value
		inline var c=pop();push(function(){push(c++)}) end-inline \ Leave a function on TOS. The function access the 
		create , does> r> @ execute                               \ dynamic variable c that makes c none-volatile during 
	;															  \ alive of the function.
	/// Demo how to make a dynamic variable none-volatile, which is like a static variable.
	100 create_counter counter
	counter tib.
	counter tib.
	counter tib.
	counter tib.
		
	
\s 


var aaa = [1,2,3,4];
function tos() { arguments.callee.value=aaa[aaa.length-1] }


\s
	//�y�k���S�G 
	var object = // �w�q�p�g�� object �����A �Τ_��{�̰�¦����k�� 
	{ 
		isA: function (aType) // �@�ӧP�_���P�������H�ι�H�P���������Y����¦��k 
		{ 
			var self = this; 
			while (self) {  // self=self.Type can make self != true because the ending is undefined, I guess so.
				if (self == aType) // The 'a' in 'aType' means Argument.
					return true; 
				self = self.Type; // parent's type
			}; 
			return false; 
		} 
	}; 

	function Class (aBaseClass, aClassDefine) // �Ы� class �� function�A�Τ_�n�� class ���~�����Y 
	{ 
		function class_() //�Ы� class ���{�� function �� 
		{ 
			this.Type = aBaseClass; // �ڭ̵��C�@�� class ���w�@�� Type �ݩʡA�ޥΨ��~�Ӫ� class
			for (var member in aClassDefine) 
				this.[member] = aClassDefine[member]; // �ƻs class �������w�q���e�Ыت� class 
		}; 
		class_.prototype = aBaseClass; 
		return new class_(); // Now, members in aBaseClass will be overwritten by members in aClassDefine if the name is same.
	}; 
	
	
	function New(aClass, aParams) // �Ы� object ����ơA�Τ_���N class �� object �Ы� 
	{ 
		function new_() // �Ы� object ���{�� function �� 
		{ 
			this.Type = aClass; // �ڭ̤]���C�@�� object ���w�@�� Type �ݩʡA�ڦ��i�H�X�ݨ� object ���ݪ� class
			if (aClass.Create) 
				aClass.Create.call(this, aParams); // �ڭ̬��w�Ҧ� class �� constructor ���s Create�A�o�M DELPHI ����ۦ� 
		}; 
		new_.prototype = aClass; 
		return new new_(); 
	}; 

	//�y�k���S�����ήĪG�G 
	var Person = Class(object, // �l�ͦ� object �� class
		{ 
			Create: function (name, age) 
				{ 
					this.name = name; 
					this.age = age; 
				}, 
			SayHello: function() 
				{ 
					alert("Hello, I'm " + this.name + ", " + this.age + " years old."); 
				} 
		}
	); 
	
	var Employee = Class(Person, // �l�ͦ� Person class�A�O���O�M�@�� Object Oriented �y���ܬۦ��H 
		{ 
			Create: function (name, age, salary) 
				{ 
					Person.Create.call(this, name, age); // �ե� base class �� constructor
					this.salary = salary; 
				}, 
			ShowMeTheMoney: function () 
				{ 
					alert(this.name + " $" + this.salary); 
				} 
		}
	); 
	
	var BillGates = New(Person, ["Bill Gates", 53]); 
	var SteveJobs = New(Employee, ["Steve Jobs", 53, 1234]); 
	BillGates.SayHello(); 
	SteveJobs.SayHello(); 
	SteveJobs.ShowMeTheMoney(); 
	
	var LittleBill = New(BillGates.Type, ["Little Bill", 6]); // �ھ� BillGate �� class �Ы� LittleBill 
	LittleBill.SayHello(); 
	
	alert(BillGates.isA(Person)); //true 
	alert(BillGates.isA(Employee)); //false 
	alert(SteveJobs.isA(Person)); //true 
	alert(SteveJobs.isA(Employee)); //true 
	alert(Person.isA(Employee)); //false 
	alert(Employee.isA(Person)); //true 



