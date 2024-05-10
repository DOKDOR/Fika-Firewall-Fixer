!include MUI2.nsh ; Include the Modern UI 2 header file

; Define the name and attributes of the installer
Name "Fika Firewall Fixer"
OutFile "FikaFirewallFixer.exe"


; Set default installation directory to current directory
InstallDir "$EXEDIR"

; Welcome page text
!define MUI_WELCOMEPAGE_TEXT "Welcome to DOKDOR's Fika Firewall Fixer. This will automatically remove any old broken rules, and add all the firewall rules needed to host and play Fika."

; Interface for the welcome page
!insertmacro MUI_PAGE_WELCOME

; Button to go to the next page
!insertmacro MUI_PAGE_INSTFILES

; Define the language for the installer
!insertmacro MUI_LANGUAGE "English"

Section SPTServercheck
    ; Check if AKI.server.exe is present in the same directory
    IfFileExists "AKI.server.exe" AKIServerFound NoAKIServerFound
NoAKIServerFound:
    MessageBox MB_ICONSTOP|MB_OK "AKI.server.exe not found. You must install SPT first, or put this installer in the same directory as AKI.server.exe (Should be your SPT install directory.)"
    Abort ; Quit installer if AKI.server.exe not found
AKIServerFound:
SectionEnd

Section SPTLauncherCheck
    ; Check if AKI.launcher.exe is present in the same directory
    IfFileExists "AKI.launcher.exe" AKILauncherFound NoAKILauncherFound
NoAKILauncherFound:
    MessageBox MB_ICONSTOP|MB_OK "AKI.launcher.exe not found. You must install SPT first, or put this installer in the same directory as AKI.luncher.exe (Should be your SPT install directory.)"
    Abort ; Quit installer if AKI.launcher.exe not found
AKILauncherFound:
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
	; Remove all old rules for ports 6969 and 25565. Look for and remove any rules related to EFT and AKI from the current directory. 
	DetailPrint "Remove old firewall rules..."
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 6969 | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 25565 | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\AKI.server.exe" | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\EscapeFromTarkov.exe" | Remove-NetFirewallRule'
	nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\AKI.launcher.exe" | Remove-NetFirewallRule'
    ; Add firewall rules for TCP 6969, UDP 25565, EFT and AKI. 
	DetailPrint "Adding firewall rules..."
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA TCP 6969 IN" dir=in action=allow protocol=TCP localport=6969 enable=yes profile=public,private' SILENT
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA TCP 6969 OUT" dir=out action=allow protocol=TCP localport=6969 enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA UDP 25565 IN" dir=in action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA UDP 25565 OUT" dir=out action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA Tarkov IN" dir=in action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA Tarkov OUT" dir=out action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA AKI.SERVER IN" dir=in action=allow program="$EXEDIR\AKI.server.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA AKI.SERVER OUT" dir=out action=allow program="$EXEDIR\AKI.server.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA AKI.LAUNCHER IN" dir=in action=allow program="$EXEDIR\AKI.launcher.exe" enable=yes profile=public,private'
	nsExec::Exec 'netsh advfirewall firewall add rule name="FIKA AKI.LAUNCHER OUT" dir=out action=allow program="$EXEDIR\AKI.launcher.exe" enable=yes profile=public,private'
SectionEnd