[Setup]
AppId={{APP_ID}}
AppVersion={{APP_VERSION}}
AppName={{DISPLAY_NAME}}
AppPublisher={{PUBLISHER_NAME}}
AppPublisherURL={{PUBLISHER_URL}}
AppSupportURL={{PUBLISHER_URL}}
AppUpdatesURL={{PUBLISHER_URL}}
DefaultDirName={{INSTALL_DIR_NAME}}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=Spheroscopic_{#SetupSetting("AppVersion")}_win-x86-64
Compression=lzma
SolidCompression=yes
SetupIconFile="..\..\assets\img\Logo-128.ico"
WizardStyle=modern
PrivilegesRequired={{PRIVILEGES_REQUIRED}}
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{{SOURCE_DIR}}\{{EXECUTABLE_NAME}}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{{SOURCE_DIR}}\desktop_drop_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\file_selector_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\flutter_acrylic_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\screen_retriever_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\sentry_flutter_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\system_theme_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\assets\win_dlls\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\assets\win_dlls\msvcp140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\assets\win_dlls\msvcp140_2.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\assets\win_dlls\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\assets\win_dlls\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{SOURCE_DIR}}\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"
Name: "{autodesktop}\{{DISPLAY_NAME}}"; Filename: "{app}\{{EXECUTABLE_NAME}}"; Tasks: desktopicon

[Run]
Filename: "{app}\{{EXECUTABLE_NAME}}"; Description: "{cm:LaunchProgram,{{DISPLAY_NAME}}}"; Flags: nowait postinstall skipifsilent

