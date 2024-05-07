!include MUI2.nsh ; Include the Modern UI 2 header file

; Define the name and attributes of the installer
Name "Fika Port Forwarder"
OutFile "FikaPF.exe"

; Set default installation directory to current directory
InstallDir "$EXEDIR"

; Welcome page
!define MUI_WELCOMEPAGE_TEXT "Welcome to DOKDORs Fika Port Forwarder. This will automatically add firewwll rules needed to host and play Fika."

; Interface for the welcome page
!insertmacro MUI_PAGE_WELCOME

; Button to go to the next page
!insertmacro MUI_PAGE_INSTFILES

; Define the language for the installer
!insertmacro MUI_LANGUAGE "English"

Section SPTcheck
    ; Check if AKI.server.exe is present in the same directory
    IfFileExists "AKI.server.exe" AKIFound NoAKIServerFound
    MessageBox MB_ICONINFORMATION|MB_OK "AKI.server.exe found."
NoAKIServerFound:
    MessageBox MB_ICONSTOP|MB_OK "AKI.server.exe not found. You must install SPT first or put this installer in the same directory as AKI.server.exe."
    Abort ; Quit installer if AKI.server.exe not found
AKIFound:
SectionEnd

Section EFTcheck
    ; Check if EscapeFromTarkov.exe is present in the same directory
    IfFileExists "EscapeFromTarkov.exe" EFTFound NoEFTFound
    MessageBox MB_ICONINFORMATION|MB_OK "EscapeFromTarkov.exe found."
NoEFTFound:
    MessageBox MB_ICONSTOP|MB_OK "EscapeFromTarkov.exe not found. Put this installer in the same directory as EscapeFromTarkov.exe."
    Abort ; Quit installer if EscapeFromTarkov.exe not found
EFTFound:
SectionEnd

Section FIREWALL
		; Remove all old rules for ports 6969 and 25565. look for and remove any rules related to EFT and AKI frok the current directory. 
		DetailPrint "Remove old firewall rules..."
		nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 6969 | Remove-NetFirewallRule'
		nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallPortFilter | Where-Object -Property LocalPort -EQ 25565 | Remove-NetFirewallRule'
		nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\AKI.server.exe" | Remove-NetFirewallRule'
		nsExec::Exec 'powershell -ExecutionPolicy Bypass -WindowStyle Hidden Get-NetFirewallApplicationFilter -Program "$EXEDIR\EscapeFromTarkov.exe" | Remove-NetFirewallRule'
    ; Add firewall rules for TCP 6969, UDP 25565, EFT and AKI. 
	DetailPrint "Adding firewall rules..."
    nsExec::Exec 'netsh advfirewall firewall add rule name="TCP 6969 IN" dir=in action=allow protocol=TCP localport=6969 enable=yes profile=public,private' SILENT
    nsExec::Exec 'netsh advfirewall firewall add rule name="TCP 6969 OUT" dir=out action=allow protocol=TCP localport=6969 enable=yes profile=public,private'
    nsExec::Exec 'netsh advfirewall firewall add rule name="UDP 25565 IN" dir=in action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
    nsExec::Exec 'netsh advfirewall firewall add rule name="UDP 25565 OUT" dir=out action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
		nsExec::Exec 'netsh advfirewall firewall add rule name="Tarkov IN" dir=in action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
		nsExec::Exec 'netsh advfirewall firewall add rule name="Tarkov OUT" dir=out action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
		nsExec::Exec 'netsh advfirewall firewall add rule name="AKI.SERVER IN" dir=in action=allow program="$EXEDIR\AKI.server.exe" enable=yes profile=public,private'
		nsExec::Exec 'netsh advfirewall firewall add rule name="AKI.SERVER OUT" dir=out action=allow program="$EXEDIR\AKI.server.exe" enable=yes profile=public,private'
SectionEnd