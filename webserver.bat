
@echo We need a WEB server to run jeforth.3htm from local or remote, http://localhost:8888 
@echo �쥻�O node.js �� webserver.js �令 jeforth ����n�B?
@echo jeforth.3nd �� cd dir �� dos command �ҥH cd �J�i�H�d�� working
@echo directory (�κ� root directory) �S�i�H���N���ܥ��C�g! �g! �g!

node   jeforth.3nd.js include webserver.f

@rem Python is a good Web server oneliner, but something wrong with iframe so I drop it.
@rem if a%COMPUTERNAME%==aWKS-38EN3476    python -m SimpleHTTPServer 8888
@rem if a%COMPUTERNAME%==aWKS-38EN3477    python -m SimpleHTTPServer 8888
@rem if a%COMPUTERNAME%==aDESKTOP-Q94AC8A python -m http.server 8888

