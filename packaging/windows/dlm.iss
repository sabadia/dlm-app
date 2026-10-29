; Inno Setup script for DLM. Built by tools/package_windows.ps1, which passes
; AppVersion, SourceDir (the Flutter release folder with bin\dlm.exe inside),
; OutputDir and RootDir.
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppName "DLM"
#define AppExe "dlm_app.exe"

[Setup]
AppId={{6B5D6C0A-3F1C-4B2E-9E54-0D1C7A2F5A11}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=sabadia
AppPublisherURL=https://github.com/sabadia/dlm-app
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\{#AppExe}
OutputDir={#OutputDir}
OutputBaseFilename=DLM_{#AppVersion}_windows_x64_setup
SetupIconFile={#RootDir}\apps\dlm_app\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; A per-user install by default, no administrator needed; the user can switch.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
CloseApplications=yes
RestartApplications=no
WizardStyle=modern
LicenseFile={#RootDir}\LICENSE

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
Name: "handlers"; Description: "Open magnet:, ed2k:, dlm: links and .torrent files with DLM"
Name: "startup"; Description: "Start DLM when I sign in"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Registry]
; The same registrations whether per user (HKCU) or for everyone (HKLM): Inno
; maps HKA to the right one.
Root: HKA; Subkey: "Software\Classes\magnet"; ValueType: string; ValueData: "URL:Magnet Link"; Tasks: handlers; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\magnet"; ValueName: "URL Protocol"; ValueType: string; ValueData: ""; Tasks: handlers
Root: HKA; Subkey: "Software\Classes\magnet\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: handlers
Root: HKA; Subkey: "Software\Classes\ed2k"; ValueType: string; ValueData: "URL:ed2k Link"; Tasks: handlers; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\ed2k"; ValueName: "URL Protocol"; ValueType: string; ValueData: ""; Tasks: handlers
Root: HKA; Subkey: "Software\Classes\ed2k\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: handlers
Root: HKA; Subkey: "Software\Classes\dlm"; ValueType: string; ValueData: "URL:DLM Link"; Tasks: handlers; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\dlm"; ValueName: "URL Protocol"; ValueType: string; ValueData: ""; Tasks: handlers
Root: HKA; Subkey: "Software\Classes\dlm\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: handlers
Root: HKA; Subkey: "Software\Classes\.torrent"; ValueType: string; ValueData: "DLM.torrent"; Tasks: handlers; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\DLM.torrent"; ValueType: string; ValueData: "BitTorrent file"; Tasks: handlers; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\DLM.torrent\shell\open\command"; ValueType: string; ValueData: """{app}\{#AppExe}"" ""%1"""; Tasks: handlers
; Start at sign-in. The app's own switch (Preferences) writes the same value, so
; the two stay in step.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueName: "dlm"; ValueType: string; ValueData: """{app}\{#AppExe}"" --minimised"; Tasks: startup; Flags: uninsdeletevalue

[Run]
Filename: "{app}\{#AppExe}"; Description: "Start DLM"; Flags: nowait postinstall skipifsilent
