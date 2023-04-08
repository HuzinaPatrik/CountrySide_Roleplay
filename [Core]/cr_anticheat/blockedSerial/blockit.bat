@echo off
if "%1"=="list" (
netsh advfirewall firewall show rule Blockit | findstr RemoteIP
exit/b
)

:: Deleting existing block on ips
netsh advfirewall firewall delete rule name="Blockit"

:: Block new ips (while reading them from blockit.txt)
for /f %%i in (blockit.txt) do (
netsh advfirewall firewall add rule name="Blockit" protocol=any dir=in action=block remoteip=%%i
netsh advfirewall firewall add rule name="Blockit" protocol=any dir=out action=block remoteip=%%i
)

:: call this batch again with list to show the blocked IPs
call %0 list