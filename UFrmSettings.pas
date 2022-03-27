unit UFrmSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.FileCtrl,
  Vcl.Samples.Spin, System.IniFiles, Vcl.Themes;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSettings: TFrmSettings;
  SaveBackStyle: string;

implementation

USES UFrmMain;

{$R *.dfm}

procedure TFrmSettings.BtnApplayClick(Sender: TObject);
begin
  SaveSettings;
  Close;
end;

procedure TFrmSettings.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSettings.cbxVclStylesSelect(Sender: TObject);
begin
  SaveBackStyle := TStyleManager.ActiveStyle.Name;
  TStyleManager.SetStyle(cbxVclStyles.Items[cbxVclStyles.ItemIndex]);
end;

procedure TFrmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if SaveBackStyle <> TStyleManager.ActiveStyle.Name then
  begin
    cbxVclStyles.ItemIndex := cbxVclStyles.Items.IndexOf(SaveBackStyle);
    TStyleManager.SetStyle(SaveBackStyle);
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
  //cbxVclStyles.Text := GLStyleName; //'Amethyst Kamri';
end;

procedure TFrmSettings.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 27 then Close;
end;

procedure TFrmSettings.SaveSettings;
var
  INI: TIniFile;
  Section: String;
begin
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
