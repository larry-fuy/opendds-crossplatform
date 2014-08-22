@ECHO OFF
echo "set env vars..."
call c:\DDS\setenv
set repo_ip=172.18.0.2
set repo_port=10000

echo "change directory..."
cd %DDS_ROOT%\DevGuideExamples\DCPS\Messenger.minimal

REM powershell.exe -noexit c:\vagrant\scripts\test.ps1
del c:\vagrant\scripts\repo.log
echo "run repo"
REM %DDS_ROOT%\bin\DCPSInfoRepo -DCPSDebugLevel 10 -ORBLogFile c:\vagrant\scripts\repo.log  -ORBListenEndpoints iiop://"%repo_ip%:%repo_port%"
%DDS_ROOT%\bin\DCPSInfoRepo -ORBDebugLevel 10 -DCPSDebugLevel 10  -ORBListenEndpoints iiop://%repo_ip%:%repo_port%