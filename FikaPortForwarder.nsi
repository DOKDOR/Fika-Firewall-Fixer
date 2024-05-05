!include MUI2.nsh ; Include the Modern UI 2 header file

; Define the name and attributes of the installer
Name "Fika Port Forwarder"
OutFile "FikaPF.exe"

; Set default installation directory to current directory
InstallDir "$EXEDIR"

; Welcome page
!define MUI_WELCOMEPAGE_TEXT "Welcome to DOKDORs Fika Port Forwarder"

; Interface for the welcome page
!insertmacro MUI_PAGE_WELCOME

; Button to go to the next page
!insertmacro MUI_PAGE_INSTFILES

; Interface for the components selection page
!insertmacro MUI_PAGE_COMPONENTS

; Define the language for the installer
!insertmacro MUI_LANGUAGE "English"

Var AKIServerFound

Section SPTcheck
    ; Check if AKI.server.exe is present in the same directory
    IfFileExists "AKI.server.exe" 0 NoAKIServerFound
    MessageBox MB_ICONINFORMATION|MB_OK "AKI.server.exe found."
NoAKIServerFound:
    StrCpy $AKIServerFound 0
    MessageBox MB_ICONSTOP|MB_OK "AKI.server.exe not found. You must install SPT first or put this installer in the same directory as AKI.server.exe."
    Abort ; Quit installer if AKI.server.exe not found
SectionEnd

Section EFTcheck
    ; Check if EscapeFromTarkov.exe is present in the same directory
    IfFileExists "EscapeFromTarkov.exe" 0 NoEFTFound
    MessageBox MB_ICONINFORMATION|MB_OK "EscapeFromTarkov.exe found."
NoEFTFound:
    MessageBox MB_ICONSTOP|MB_OK "EscapeFromTarkov.exe not found. Put this installer in the same directory as EscapeFromTarkov.exe."
    Abort ; Quit installer if EscapeFromTarkov.exe not found
SectionEnd

Section FIREWALL
    ; Add firewall rules for TCP 6969, UDP 25565, EFT and AKI. 
    DetailPrint "Adding firewall rules..."
    ExecWait 'netsh advfirewall firewall add rule name="TCP 6969 IN" dir=in action=allow protocol=TCP localport=6969 enable=yes profile=public,private'
    ExecWait 'netsh advfirewall firewall add rule name="TCP 6969 OUT" dir=out action=allow protocol=TCP localport=6969 enable=yes profile=public,private'
    ExecWait 'netsh advfirewall firewall add rule name="UDP 25565 IN" dir=in action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
    ExecWait 'netsh advfirewall firewall add rule name="UDP 25565 OUT" dir=out action=allow protocol=UDP localport=25565 enable=yes profile=public,private'
		ExecWait 'netsh advfirewall firewall add rule name="Tarkov IN" dir=in action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
		ExecWait 'netsh advfirewall firewall add rule name="Tarkov OUT" dir=out action=allow program="$EXEDIR\EscapeFromTarkov.exe" enable=yes profile=public,private'
		ExecWait 'netsh advfirewall firewall add rule name="AKI.SERVER IN" dir=in action=allow program="$EXEDIR\AKI.server.exe" enable=yes profile=public,private'
		ExecWait 'netsh advfirewall firewall add rule name="AKI.SERVER OUT" dir=out action=allow program="$EXEDIR\AKI.server.exe" enable=yes profile=public,private'
SectionEnd