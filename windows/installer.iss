; DoctorsHero Core - Inno Setup Script
; This script creates a professional Windows installer with auto-update support

#define MyAppName "DoctorsHero Core"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "DoctorsHero"
#define MyAppURL "https://doctorshero.com"
#define MyAppExeName "DoctorsHero_Core.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
AppId={{8F9A7B6C-5D4E-3F2A-1B0C-9E8D7C6B5A4F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\LICENSE
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
OutputDir=..\build\windows\installer
OutputBaseFilename=DoctorsHero_Core_Setup_v{#MyAppVersion}
SetupIconFile=runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Modern UI colors matching your app theme
WizardImageFile=installer_banner.bmp
WizardSmallImageFile=installer_icon.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "..\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  UpdateCheckPage: TOutputMsgMemoWizardPage;
  IsUpgrade: Boolean;

function InitializeSetup(): Boolean;
var
  OldVersion: String;
  UninstallString: String;
  ResultCode: Integer;
begin
  Result := True;
  IsUpgrade := False;
  
  // Check if the application is already installed
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1', 'UninstallString', UninstallString) then
  begin
    IsUpgrade := True;
    
    // Get the installed version
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1', 'DisplayVersion', OldVersion) then
    begin
      // Show upgrade message
      if MsgBox('DoctorsHero Core version ' + OldVersion + ' is already installed.' + #13#13 + 
                'Do you want to upgrade to version {#MyAppVersion}?', 
                mbConfirmation, MB_YESNO) = IDYES then
      begin
        Result := True;
      end
      else
      begin
        Result := False;
      end;
    end;
  end;
end;

procedure InitializeWizard();
begin
  if IsUpgrade then
  begin
    // Create a custom page for upgrade information
    UpdateCheckPage := CreateOutputMsgMemoPage(wpWelcome,
      'Upgrade Detected', 
      'DoctorsHero Core will be upgraded',
      'Setup has detected an existing installation of DoctorsHero Core. ' +
      'Your settings and data will be preserved during the upgrade.' + #13#13 +
      'Click Next to continue with the upgrade.',
      '');
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Skip the "Select Destination Location" page if upgrading
  if IsUpgrade and (PageID = wpSelectDir) then
    Result := True
  else
    Result := False;
end;
