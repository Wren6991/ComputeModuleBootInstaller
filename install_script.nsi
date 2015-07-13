!include "x64.nsh"

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "Compute Module Boot Flasher"
  OutFile "ComputeModuleBoot.exe"

  ;Default installation folder
  InstallDir "$PROGRAMFILES\Compute Module Boot"

  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\Compute Module Boot" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------

;Interface Settings

  ShowInstDetails show
  !define MUI_FINISHPAGE_NOAUTOCLOSE
  !define MUI_ABORTWARNING
  !define MUI_ICON "Raspberry_Pi_Logo.ico"
  !define MUI_UNICON "Raspberry_Pi_Logo.ico"

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
;Installer Sections

Section "Compute Module Boot" SecCmBoot

  SetOutPath "$INSTDIR"

  File /r drivers

  DetailPrint "Installing BCM270x driver..."

  ${If} ${RunningX64}
    ExecWait '"$INSTDIR\drivers\dpinst64.exe" /c /sa /sw /PATH "$INSTDIR\drivers"' $0
  ${Else}
    ExecWait '"$INSTDIR\drivers\dpinst32.exe" /c /sa /sw /PATH "$INSTDIR\drivers"' $0
  ${EndIf}

  DetailPrint "Driver install returned $0"


  File buildroot.elf
  File cyggcc_s-1.dll
  File cygusb-1.0.dll
  File cygwin1.dll
  File msd.elf
  File rpiboot.exe
  File usbbootcode.bin

  CreateDirectory $SMPROGRAMS\ComputeModuleBoot
  CreateShortcut "$SMPROGRAMS\ComputeModuleBoot\RPi Boot.lnk" "$INSTDIR\rpiboot.exe"
  CreateShortcut "$SMPROGRAMS\ComputeModuleBoot\Uninstall RPi Boot.lnk" "$INSTDIR\Uninstall.exe"

  ;Store installation folder
  WriteRegStr HKCU "Software\Compute Module Boot" "" $INSTDIR

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecDummy ${LANG_ENGLISH} "Install drivers for flashing Compute Module."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCmBoot} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"

  DetailPrint "Removing driver..."
 
  ${If} ${RunningX64}
    ExecWait '"$INSTDIR\drivers\dpinst64.exe" /c /sa /sw /U "$INSTDIR\drivers\bcm270x.inf"' $0
  ${Else}
    ExecWait '"$INSTDIR\drivers\dpinst32.exe" /c /sa /sw /U "$INSTDIR\drivers\bcm270x.inf"' $0
  ${EndIf}


  RmDir /r /REBOOTOK $INSTDIR\drivers

  Delete $INSTDIR\Uninstall.exe
  Delete $INSTDIR\buildroot.elf
  Delete $INSTDIR\cyggcc_s-1.dll
  Delete $INSTDIR\cygusb-1.0.dll
  Delete $INSTDIR\cygwin1.dll
  Delete $INSTDIR\msd.elf
  Delete $INSTDIR\rpiboot.exe
  Delete $INSTDIR\usbbootcode.bin

  RmDir /REBOOTOK $INSTDIR

  RmDir /r "$SMPROGRAMS\ComputeModuleBoot"

  DeleteRegKey /ifempty HKCU "Software\Compute Module Boot"

SectionEnd
