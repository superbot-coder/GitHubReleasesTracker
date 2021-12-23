unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, sSkinManager, Vcl.ComCtrls,
  sListView, System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope;

type
  TProjectListRec = Record
    ProjLink     : string;
    ApiProjLink  : string; // Ali Project Releases Link
    ProjName     : string;
    Filters      : string;
    DatePublish  : string;
    LastVersion  : string;
    RuleDownload : UInt8;
    RuleNotis    : UInt8;
    SubDir       : Boolean;
  End;

type
  TFrmMain = class(TForm)
    MainMenu: TMainMenu;
    U1: TMenuItem;
    MM_AddReleases: TMenuItem;
    sSkinManager: TsSkinManager;
    sLVProj: TsListView;
    ImgListProj: TImageList;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    procedure MM_AddReleasesClick(Sender: TObject);
    function AddItems: Integer;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;
  CurrDir: String;
  CurrPath: String;
  GLProjectsPath: String;
  arProjectList: array of TProjectListRec;
  TEMP: String;

Const
  CAPTION_MB = 'GitHub Releases Tracker';
  c_lv_proj_name  = 0;
  c_lv_version    = 1;
  c_lv_dt_relises = 2;
  c_lv_last_check = 3;
  // ALL_PROJECT_DIR = 'GitHubReleasesTracker';

implementation

{$R *.dfm}

Uses UFrmAddProject;

function TFrmMain.AddItems: Integer;
begin
  with sLVProj.Items.Add do
  begin
    Caption := IntToStr(Index + 1);
    Result  := Index;
    ImageIndex := -1;
    SubItems.Add('');
    SubItems.Add('');
    SubItems.Add('');
    SubItems.Add('');
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  CurrDir  := ExtractFileDir(Application.ExeName);
  CurrPath := CurrDir + PathDelim;
  TEMP     := GetEnvironmentVariable('TEMP');
  GLProjectsPath := GetEnvironmentVariable('USERPROFILE');
  GLProjectsPath := GLProjectsPath + '\Downloads\GitHubReleasesTracker\';
end;

procedure TFrmMain.MM_AddReleasesClick(Sender: TObject);
var
  x, i: SmallInt;
begin
  FrmAddProject.FrmShowInit;
  if Not FrmAddProject.Applay then Exit;

  i := Length(arProjectList)-1;
  x := AddItems;
  with sLVProj.Items[x] do
  begin
    SubItems[c_lv_proj_name]  := arProjectList[i].ProjName;
    SubItems[c_lv_version]    := 'не известно';
    SubItems[c_lv_dt_relises] := 'не известно';
    SubItems[c_lv_last_check] := 'не известно';
  end;

end;

end.
