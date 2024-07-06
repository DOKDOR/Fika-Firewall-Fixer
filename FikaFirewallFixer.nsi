!include MUI2.nsh ; Include the Modern UI 2 header file

; Define the name and attributes of the installer
Name "Fika Firewall Fixer"
OutFile "FikaFirewallFixer.exe"


; Set default installation directory to current directory
InstallDir "$EXEDIR"

; Welcome page text
!define MUI_WELCOMEPAGE_TEXT "Welcome to DOKDOR's Fika Firewall Fixer for SPT 3.9.0. This will automatically remove any old broken rules, and add all the firewall rules needed to host and play Fika."

; Interface for the welcome page
!insertmacro MUI_PAGE_WELCOME

; Button to go to the next page
!insertmacro MUI_PAGE_INSTFILES

; Define the language for the installer
!insertmacro MUI_LANGUAGE "English"

Section SPTServercheck
    ; Check if SPT.Server.exe is present in the same directory
    IfFileExists "SPT.Server.exe" SPTServerFound NoSPTServerFound
NoSPTServerFound:
    MessageBox MB_ICONSTOP|MB_OK "SPT.Server.exe not found. You must install SPT first, or put this installer in the same directory as SPT.Server.exe (Should be your SPT install directory.)"
    Abort ; Quit installer if SPT.Server.exe not found
SPTServerFound:
SectionEnd

Section SPTLauncherCheck
    ; Check if SPT.Launcher.exe is present in the same directory
    IfFileExists "SPT.Launcher.exe" SPTLauncherFound NoSPTLauncherFound
NoSPTLauncherFound:
    MessageBox MB_ICONSTOP|MB_OK "SPT.Launcher.exe not found. You must install SPT first, or put this installer in the same directory as SPT.Launcher.exe (Should be your SPT install directory.)"
    Abort ; Quit installer if SPT.Launcher.exe not found
SPTLauncherFound:
SectionEnd

Section EFTcheck
    ; Check if EscapeFromTarkov.exe is present in the same directory
    IfFileExists "EscapeFromTarkov.exe" EFTFound NoEFTFound
NoEFTFound:
    MessageBox MB_ICONSTOP|MB_OK "EscapeFromTarkov.exe not found. Put this installer in the same directory as EscapeFromTarkov.exe (Should be your SPT install directory.)"
    Abort ; Quit installer if EscapeFromTarkov.exe not found
EFTFound:
SectionEnd

Section FIREWALL
	; Remove all old rules for ports 6969 and 25565. Look for and remove any rules related to EFT and SPT (including old AKI files!) from the current directory. 
	DetailPrint "Remove old firewall rules..."
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 6969 | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 25565 | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\SPT.Server.exe" | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\EscapeFromTarkov.exe" | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\SPT.Launcher.exe" | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\Aki.Server.exe" | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\Aki.Launcher.exe" | Remove-NetFirewallRule'
    ; Add firewall rules for TCP 6969, UDP 25565, EFT and SPT. 
	DetailPrint "Adding firewall rules..."
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA TCP 6969 IN" dir=in action=allow protocol=TCP localport=6969 enable=yes profile=public,private' SILENT
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA TCP 6969 OUT" dir=out action=allow protocol=TCP localport=6969 enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA UDP 25565 IN" dir=in action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA UDP 25565 OUT" dir=out action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA Tarkov IN" dir=in action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA Tarkov OUT" dir=out action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA SPT.SERVER IN" dir=in action=allow program="$EXEDIR\SPT.Server.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA SPT.SERVER OUT" dir=out action=allow program="$EXEDIR\SPT.Server.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA SPT.LAUNCHER IN" dir=in action=allow program="$EXEDIR\SPT.Launcher.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA SPT.LAUNCHER OUT" dir=out action=allow program="$EXEDIR\SPT.Launcher.exe" enable=yes profile=public,private'
SectionEnd