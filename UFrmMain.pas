unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, sSkinManager, Vcl.ComCtrls,
  sListView, System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls, acPNG,
  Vcl.ExtCtrls, acImage, Vcl.Imaging.pngimage;

type
  TProjectListRec = Record
    ProjectUrl     : string; // Project URL
    ProjectDir     : string; // Project Directory
    ApiProjectUrl  : string; // Api Project URL
    ApiReleasesUrl : string; // Api Project Releases URL
    ProjectName    : string; // Project name
    AvatarFile     : string; //
    AvatarUrl      : string; //
    Filters        : string; //
    DatePublish    : string; //
    LastVersion    : string; //
    LastChecked    : TDateTime; //
    RuleDownload   : UInt8;
    RuleNotis      : UInt8;
    NeedSubDir     : Boolean;
  End;

type
  TFrmMain = class(TForm)
    MainMenu: TMainMenu;
    U1: TMenuItem;
    MM_AddReleases: TMenuItem;
    sSkinManager: TsSkinManager;
    sLVProj: TsListView;
    ImageListProj: TImageList;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    Button1: TButton;
    procedure MM_AddReleasesClick(Sender: TObject);
    function AddItems: Integer;
    procedure FormCreate(Sender: TObject);

    //https://stackoverflow.com/questions/8589096/convert-png-jpg-gif-to-ico
    function LoadAvatarToImageList(AvatarFile: String): integer;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain    : TFrmMain;
  CurrDir    : String;
  CurrPath   : String;
  TEMP       : String;
  ConfigDir  : String;
  FileConfig : string;
  GLProjectsPath : String;
  arProjectList  : array of TProjectListRec;

Const
  CAPTION_MB = 'GitHub Releases Tracker';
  lv_proj_version     = 0;
  lv_date_publish     = 1;
  lv_date_last_check  = 2;
  lv_project_url      = 3;
  // ALL_PROJECT_DIR = 'GitHubReleasesTracker';

implementation

{$R *.dfm}

Uses UFrmAddProject, UFrmSettings;

function TFrmMain.AddItems: Integer;
begin
  with sLVProj.Items.Add do
  begin
    Caption := ''; IntToStr(Index + 1);
    Result  := Index;
    ImageIndex := 0;
    SubItems.Add('');
    SubItems.Add('');
    SubItems.Add('');
    SubItems.Add('');
  end;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
var x: integer;
begin
  x := AddItems;
  sLVProj.Items[x].ImageIndex := 2;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Caption  := CAPTION_MB;
  CurrDir  := ExtractFileDir(Application.ExeName);
  CurrPath := CurrDir + PathDelim;
  TEMP     := GetEnvironmentVariable('TEMP');
  GLProjectsPath := GetEnvironmentVariable('USERPROFILE');
  GLProjectsPath := GLProjectsPath + '\Downloads\GitHubReleasesTracker\';
  ConfigDir      := GetEnvironmentVariable('APPDATA') + '\GitHubReleasesTracker';
  FileConfig     := ConfigDir + '\Config.ini';
end;

function TFrmMain.LoadAvatarToImageList(AvatarFile: String): integer;
var
  Img   : TImage;
  BmImg : TBitmap;
  Bmp   : TBitmap;
begin
  Img   := TImage.Create(Owner);
  BmImg := TBitmap.Create;
  Bmp   := TBitmap.Create;
  try
    Img.Picture.LoadFromFile(AvatarFile);
    Img.Width  := 32;
    Img.Height := 32;
    Img.Stretch := True;

    //BmImg.PixelFormat     := pf32bit;
    //BmImg.Transparent     := true;

    BmImg.Assign(Img.Picture.Graphic);

    Bmp.PixelFormat      := pf32bit;
    Bmp.Transparent      := true;
    Bmp.TransparentColor := clBlack;

    Bmp.SetSize(32, 32);

    SetStretchBltMode(Bmp.Canvas.Handle, HALFTONE);
    StretchBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
              BmImg.Canvas.Handle, 0, 0, BmImg.Width, BmImg.Height, SRCCOPY);

    Result := ImageListProj.AddMasked(Bmp, clNone);

  finally
    Img.Free;
    BmImg.Free;
    Bmp.Free;
  end;
end;

procedure TFrmMain.MM_AddReleasesClick(Sender: TObject);
var
  i, x: Integer;
begin
  FrmAddProject.FrmShowInit;
  if Not FrmAddProject.Applay then Exit;

  i := Length(arProjectList)-1;
  x := AddItems;
  with sLVProj.Items[x] do
  begin
    Caption := arProjectList[i].ProjectName;
    SubItems[lv_proj_version]    := arProjectList[i].LastVersion;
    SubItems[lv_date_publish]    := arProjectList[i].DatePublish;
    SubItems[lv_date_last_check] := DateTimeToStr(arProjectList[i].LastChecked);
    SubItems[lv_project_url]     := arProjectList[i].ProjectUrl;
  end;

end;

end.
