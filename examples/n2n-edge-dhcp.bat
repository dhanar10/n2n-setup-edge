@echo off

set N2N_SUPERNODE=supernode.ntop.org:7777
set N2N_COMMUNITY=mynetwork
set N2N_KEY=12345678
set N2N_GATEWAY=192.168.31.1

net session >nul 2>&1

if %errorLevel% neq 0 (
    echo Please run as administrator
	echo.
	
	pause
	
	exit 1
)

for /f "tokens=*" %%i in ('powershell -command "(Get-NetAdapter | ? InterfaceDescription -like 'TAP*').Name"') do set IF_NAME="%%i"
rem for /f "tokens=*" %%i in ('powershell -command "(Get-NetAdapter | ? InterfaceDescription -like 'TAP*').ifIndex"') do set IF_INDEX="%%i"

rem route delete 10.100.0.0
rem route -p add 10.100.0.0 MASK 255.255.0.0 %N2N_GATEWAY% METRIC 1 IF %IF_INDEX%

route -4 print
echo.

"C:\n2n\edge.exe" -d %IF_NAME% -l %N2N_SUPERNODE% -c %N2N_COMMUNITY% -k %N2N_KEY% -r -a dhcp:0.0.0.0 -E

pause
