unit UFrmSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.FileCtrl,
  Vcl.Samples.Spin, System.IniFiles, Vcl.Themes, System.StrUtils, BrightDarkSideStyles;

type
  TFrmSettings = class(TForm)
    BtnApplay: TButton;
    SpdBtnOpenDir: TSpeedButton;
    LblNewReleaseLive: TLabel;
    SpEditHours: TSpinEdit;
    LblHoursLimit: TLabel;
    edDefaultProjectDir: TEdit;
    StTextDefReleasesDir: TStaticText;
    cbxVclStyles: TComboBox;
    LblSelectStyle: TLabel;
    BtnClose: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure SpdBtnOpenDirClick(Sender: TObject);
    procedure BtnApplayClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure cbxVclStylesSelect(Sender: TObject);
    procedure SaveSettings;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShowInit;
  private
    { Private declarations }
    FBackUpStyle: string;
  public
    Applay: Boolean;
    { Public declarations }
  end;

var
  FrmSettings: TFrmSettings;
  //FBackUpStyle: string;
  cnt: integer;

implementation

USES UFrmMain;

{$R *.dfm}

procedure TFrmSettings.BtnApplayClick(Sender: TObject);
begin
  Applay := true;
  SaveSettings;
  Close;
end;

procedure TFrmSettings.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSettings.cbxVclStylesSelect(Sender: TObject);
begin
  TStyleManager.SetStyle(cbxVclStyles.Items[cbxVclStyles.ItemIndex]);
  if AnsiMatchStr(cbxVclStyles.Items[cbxVclStyles.ItemIndex], arDarkStyles) then
    GLStyleIcon := 2 else GLStyleIcon := 0;
  FrmMain.ReposListUpdateVisible;
end;

procedure TFrmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (FBackUpStyle <> TStyleManager.ActiveStyle.Name) and (Not Applay) then
  begin
    cbxVclStyles.ItemIndex := cbxVclStyles.Items.IndexOf(FBackUpStyle);
    TStyleManager.SetStyle(FBackUpStyle);
    if AnsiMatchStr(FBackUpStyle, arDarkStyles) then GLStyleIcon := 2 else GLStyleIcon := 0;
    FrmMain.ReposListUpdateVisible;
  end;
end;

procedure TFrmSettings.FormCreate(Sender: TObject);
var
  StyleName: string;
  x: UInt16;
begin
  EdDefaultProjectDir.Text := GLProjectsDir;
  for StyleName in TStyleManager.StyleNames do cbxVclStyles.Items.Add(StyleName);
  cbxVclStyles.ItemIndex := cbxVclStyles.Items.IndexOf(GLStyleName);
end;

procedure TFrmSettings.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 27 then Close;
end;

procedure TFrmSettings.FormShowInit;
begin
  Applay := false;
  FBackUpStyle := TStyleManager.ActiveStyle.Name;
  ShowModal;
end;

procedure TFrmSettings.SaveSettings;
var
  INI: TIniFile;
  Section: String;
begin
  if Not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  INI := TIniFile.Create(FileConfig);
  Section := 'SETTINGS';
  try
    INI.WriteString(Section, 'DefaultProjectDir', edDefaultProjectDir.Text);
    INI.WriteString(Section, 'StyleName', cbxVclStyles.Items[cbxVclStyles.ItemIndex]);
    INI.WriteInteger(Section, 'NewReleasesLive', SpEditHours.Value);
  finally
    INI.Free;
  end;
end;

procedure TFrmSettings.SpdBtnOpenDirClick(Sender: TObject);
var
  SelDir: String;
begin
  SelectDirectory('Выберите каталог', '', SelDir);
  EdDefaultProjectDir.Text := SelDir;
end;

end.
