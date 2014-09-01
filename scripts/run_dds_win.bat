@ECHO OFF
echo "set env vars..."
call c:\DDS\setenv
echo "change directory..."
cd %DDS_ROOT%\DevGuideExamples\DCPS\Messenger.minimal
echo "set gateway..."
REM set gateway
netsh int ip set address "Local Area Connection 2" static address=196.128.0.2 mask=255.255.255.0 gateway=196.128.0.1 gwmetric=2
REM get host ip
REM for /f "tokens=2 delimit=:" %a in ('ipconfig ^| findstr /C:"Autoconfiguration IPv4"') do set 196.128.0.2=%a
REM wait a moment to let windows set gateway
timeout /t 10 > nul

del c:\vagrant\scripts\repo.log
del c:\vagrant\scripts\repo.ior
echo "run repo..."
%DDS_ROOT%\bin\DCPSInfoRepo -ORBDebugLevel 10 -DCPSDebugLevel 10  -ORBListenEndpoints iiop://"196.128.0.2:15000"
