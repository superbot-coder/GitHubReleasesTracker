unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, sSkinManager, Vcl.ComCtrls,
  sListView, System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls, acPNG,
  Vcl.ExtCtrls, acImage, Vcl.Imaging.pngimage, System.IniFiles, sMemo;

type
  TProjectListRec = Record
    ProjectUrl     : string; // Project URL
    ProjectDir     : string; // Project Directory
    ApiProjectUrl  : string; // Api Project URL
    ApiReleasesUrl : string; // Api Project Releases URL
    ProjectName    : string; // Project name
    FullProjectName: string;
    AvatarFile     : string;
    AvatarUrl      : string;
    Filters        : string;
    DatePublish    : string;
    LastVersion    : string;
    LastChecked    : TDateTime;
    RuleDownload   : UInt8;
    RuleNotis      : UInt8;
    NeedSubDir     : Boolean;
  End;

type TLoadConfigsType = (loadAllConfig, loadProjList); 

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
    PopupMenu: TPopupMenu;
    PM_DeletProject: TMenuItem;
    mmInfo: TsMemo;
    procedure MM_AddReleasesClick(Sender: TObject);
    function AddItems: Integer;
    procedure FormCreate(Sender: TObject);
    //https://stackoverflow.com/questions/8589096/convert-png-jpg-gif-to-ico
    function LoadAvatarToImageList(AvatarFile: String): integer;
    procedure Button1Click(Sender: TObject);
    procedure LoadConfigAndProjectList(LoadConfigType: TLoadConfigsType);
    procedure PopupMenuPopup(Sender: TObject);
    procedure PM_DeletProjectClick(Sender: TObject);
    procedure RemoveProjectFromProjectList(FullProjectName: String);
    procedure ProjectListUpdateVisible;
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
  LoadConfigAndProjectList(loadAllConfig);
  ProjectListUpdateVisible;
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

procedure TFrmMain.LoadConfigAndProjectList(LoadConfigType: TLoadConfigsType);
var
  INI: TIniFile;
  ST: TStrings;
  Section, SubSection: string;
  x, i: Integer;
begin

  if Not FileExists(FileConfig, false) then Exit;

  ST  := TStringList.Create;
  INI := TIniFile.Create(FileConfig);

  // Загрузка секции настройки программы
  if LoadConfigType <> loadProjList then 
  begin 
    // .... 
  end;

  // Загрузка списка проектов PROJECT_LIST
  Section := 'PROJECT_LIST';
  sLVProj.Clear;
  try
    INI.ReadSubSections(Section, ST, false);
    arProjectList := Nil;
    SetLength(arProjectList, ST.Count);
    for i := 0 to ST.Count -1 do
    begin
      SubSection := Section + '\' + ST.Strings[i];
      with arProjectList[i] do
      begin
        ProjectUrl      := INI.ReadString(SubSection, 'ProjectUrl', '');
        ProjectDir      := INI.ReadString(SubSection, 'ProjectDir','');
        ApiProjectUrl   := INI.ReadString(SubSection, 'ApiProjectUrl','');
        ApiReleasesUrl  := INI.ReadString(SubSection, 'ApiReleasesUrl','');
        ProjectName     := INI.ReadString(SubSection, 'ProjectName','');
        FullProjectName := INI.ReadString(SubSection, 'FullProjectName', '');
        AvatarFile      := INI.ReadString(SubSection, 'AvatarFile','');
        AvatarUrl       := INI.ReadString(SubSection, 'AvatarUrl','');
        Filters         := INI.ReadString(SubSection, 'Filters','');
        DatePublish     := INI.ReadString(SubSection, 'DatePublish','');
        LastVersion     := INI.ReadString(SubSection, 'LastVersion','');
        LastChecked     := INI.ReadDateTime(SubSection, 'LastChecked', 0);
        RuleDownload    := INI.ReadInteger(SubSection, 'RuleDownload', 0);
        RuleNotis       := INI.ReadInteger(SubSection, 'RuleNotis', 0);
        NeedSubDir      := INI.ReadBool(SubSection, 'NeedSubDir', true);
      end;
    end;
  finally
    ST.Free;
    INI.Free;
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
    Caption                      := arProjectList[i].FullProjectName;
    SubItems[lv_proj_version]    := arProjectList[i].LastVersion;
    SubItems[lv_date_publish]    := arProjectList[i].DatePublish;
    SubItems[lv_date_last_check] := DateTimeToStr(arProjectList[i].LastChecked);
    SubItems[lv_project_url]     := arProjectList[i].ProjectUrl;
  end;

end;

procedure TFrmMain.PM_DeletProjectClick(Sender: TObject);
Var 
  DelProjName: string;
  INI: TIniFile;
begin
  DelProjName := sLVProj.Selected.Caption;

  RemoveProjectFromProjectList(sLVProj.Selected.Caption);
  ProjectListUpdateVisible;

  INI := TIniFile.Create(FileConfig);
  try
    INI.EraseSection('PROJECT_LIST\' + DelProjName);
  finally
    INI.Free;
  end;

end;

procedure TFrmMain.PopupMenuPopup(Sender: TObject);
begin
  if (sLVProj.Items.Count = 0) or (sLVProj.SelCount = 0) then 
    PM_DeletProject.Visible := false
  else 
    PM_DeletProject.Visible := true;  
end;

procedure TFrmMain.ProjectListUpdateVisible;
var
  i, x, len: Word;
begin
  sLVProj.Items.Clear;
  len := Length(arProjectList);
  if len = 0 then Exit;

  sLVProj.Items.BeginUpdate;
  for i := 0 to Len-1 do
  begin
    x := AddItems;
    with sLVProj.Items[x] do
    begin
      Caption                      := arProjectList[i].FullProjectName;
      SubItems[lv_proj_version]    := arProjectList[i].LastVersion;
      SubItems[lv_date_publish]    := arProjectList[i].DatePublish;
      SubItems[lv_date_last_check] := DateTimeToStr(arProjectList[i].LastChecked);
      SubItems[lv_project_url]     := arProjectList[i].ProjectUrl;
    end;
  end;
  sLVProj.Items.EndUpdate;
end;

procedure TFrmMain.RemoveProjectFromProjectList(FullProjectName: String);
var
  i, ix, len: Word;
begin
  len := Length(arProjectList);
  for i := 0 to Len - 1 do
  begin
    if arProjectList[i].FullProjectName = FullProjectName then
    begin
       if i = len-1 then
       begin
         mmInfo.Lines.Add('i = len-1');
         setLength(arProjectList, len-1);
         Exit;
       end;
       for ix := i + 1 to len-1 do arProjectList[ix-1] := arProjectList[ix];
       setLength(arProjectList, len-1);
       Exit;
    end;
  end;
end;

end.
