unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, sSkinManager, Vcl.ComCtrls,
  sListView, System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls, acPNG,
  Vcl.ExtCtrls, acImage, Vcl.Imaging.pngimage, System.IniFiles, sMemo,
  RESTContentTypeStr, System.JSON, System.IOUtils, sButton, System.StrUtils;

type TSortType = (stASC, stDESC);
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
    PopupMenu: TPopupMenu;
    PM_DeletProject: TMenuItem;
    mmInfo: TsMemo;
    TimerTracker: TTimer;
    PM_OneProjectTracking: TMenuItem;
    sBtnTest: TsButton;
    procedure MM_AddReleasesClick(Sender: TObject);
    function AddItems: Integer;
    procedure FormCreate(Sender: TObject);
    procedure LoadConfigAndProjectList(LoadConfigType: TLoadConfigsType);
    procedure PopupMenuPopup(Sender: TObject);
    procedure PM_DeletProjectClick(Sender: TObject);
    procedure RemoveProjectFromProjectList(FullProjectName: String);
    procedure ProjectListUpdateVisible;
    procedure AddLog(StrMsg: String);
    procedure sLVProjColumnClick(Sender: TObject; Column: TListColumn);
    function GetWayToSortet(ColumnIndex: UInt8): TSortType;
    function GetProjectIndex(ProjectName: string): UInt16;
    procedure TimerTrackerTimer(Sender: TObject);
    procedure ProjectTracking;
    procedure OneProjectTracking(ProjectIndex: UInt16);
    procedure PM_OneProjectTrackingClick(Sender: TObject);
    procedure sBtnTestClick(Sender: TObject);
    function ConvertGitHubDataToDataTime(GitDateTime: String): String;

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

Var
  ArSortColumnsPos: array[0..4] of TSortType;
  LastColumnSorted: Byte;

function CustomSortProc(Item1, Item2: TListItem; ParamSort: integer): integer; stdcall;
var
  dt1, dt2: TDateTime;
begin
  if ParamSort = 0 then
    Result := AnsiCompareText(Item1.Caption, Item2.caption)
  else
  begin
    if (ParamSort = 2) or (ParamSort = 3) then
    begin
      try
        dt1 := StrToDateTime(Item1.SubItems[ParamSort-1]);
        dt2 := StrToDateTime(Item2.SubItems[ParamSort-1]);
        if dt1 < dt2 then Result := -1;
        if dt1 > dt2 then Result :=  1;
        if dt1 = dt2 then Result :=  0;
      except
        // no message... ;
      end;
    end
    else
      Result := AnsiCompareText(Item1.SubItems[ParamSort-1], Item2.SubItems[ParamSort-1]);
  end;
  if ArSortColumnsPos[ParamSort] = stDESC then Result := Result * -1;
end;


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

procedure TFrmMain.AddLog(StrMsg: String);
begin
  mmInfo.Lines.Add(DateTimeToStr(Date + Time)  + ' ' + StrMsg);
end;

function TFrmMain.ConvertGitHubDataToDataTime(GitDateTime: String): String;
var
  s_date, s_time: string;
  i, pos, len: ShortInt;
  ST: TStrings;
begin
  len := length(GitDateTime);
  pos := AnsiPos('T', GitDateTime);
  if pos = -1 then Exit;
  ST := TStringList.Create;
  try
    s_date := Copy(GitDateTime, 1, pos-1);
    ST.Text := StringReplace(s_date, '-', #13, [rfReplaceAll]);
    s_date := '';
    for i:=0 to ST.Count - 1 do
    begin
      if i = 0 then
        s_date := ST.Strings[i] + s_date
      else
        s_date := ST.Strings[i] + '.' + s_date;
    end;
  finally
    ST.Free;
  end;
  s_time := Copy(GitDateTime, pos + 1, (len-pos)-1 );
  Result := s_date + ' ' + s_time;
  { try
    Result := StrToDateTime(s_date + ' ' + s_time);
  except
    // not message...
  end; }
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var b: UInt8;
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
  for b := 0 to Length(ArSortColumnsPos) -1 do ArSortColumnsPos[b] := stASC;
end;

function TFrmMain.GetProjectIndex(ProjectName: string): UInt16;
begin
  Result := 0;
end;

function TFrmMain.GetWayToSortet(ColumnIndex: UInt8): TSortType;
var r: Integer;
begin
  with sLVProj do
  begin
    if ColumnIndex = 0 then
      r := AnsiCompareText(Items[0].Caption, Items[1].Caption)
    else
      r := AnsiCompareText(Items[0].SubItems[ColumnIndex-1], Items[1].SubItems[ColumnIndex-1]);
  end;

  Case r of
   -1 : Result := stDESC;
    0 : Result := stASC;
    1 : Result := stASC;
  End;

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

procedure TFrmMain.OneProjectTracking(ProjectIndex: UInt16);
var
  JSONArray    : TJSONArray;
  tag_name     : string;
  published_at : string;
  FileURL      : string;
  STFilters    : TStrings;

  i: UInt8;

begin

  ShowMessage('OneProjectTracking');
exit;
  RESTResponse.RootElement := '[0]';
  RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
  RESTClient.BaseURL       := arProjectList[ProjectIndex].ApiReleasesUrl;
  RESTRequest.Execute;

  if RESTResponse.StatusCode <> 200 then
  begin
    // message
    Exit;
  end;

  if RESTResponse.JSONValue = Nil then
  begin
    // message
    Exit;
  end;

  if RESTResponse.JSONValue.FindValue('tag_name') = nil then
  begin
    // message
    exit;
  end;

  tag_name     := RESTResponse.JSONValue.FindValue('tag_name').Value;
  published_at := RESTResponse.JSONValue.FindValue('published_at').Value;

  // проверка версии релиза; verifying release version

  // ..............
  // ..............

  // Получаю массив загруженных файлов; Getting an array of downloaded files
  JSONArray := RESTResponse.JSONValue.FindValue('assets') as TJSONArray;
  if JSONArray.Count = 0 then
  begin
    // message
    Exit;
  end;

  STFilters := TStringList.Create;
  try
    for i := 0 to JSONArray.Count -1 do
    begin
      FileURL := JSONArray.Items[i].FindValue('browser_download_url').Value;
      if arProjectList[ProjectIndex].RuleDownload = 0 then
      begin
        // Безусловное скачивание

      end
      else
      begin
        // Условное скачивыание, с использованием фильтра
        STFilters.Clear;

      end;
    end;
  finally
    STFilters.Free;
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

procedure TFrmMain.PM_OneProjectTrackingClick(Sender: TObject);
var
  x: UInt16;
begin
  x := GetProjectIndex(sLVProj.Selected.Caption);
  OneProjectTracking(x);
end;

procedure TFrmMain.PopupMenuPopup(Sender: TObject);
begin
  if (sLVProj.Items.Count = 0) or (sLVProj.SelCount = 0) then
  begin
    PM_DeletProject.Visible       := false;
    PM_OneProjectTracking.Visible := false;
  end
  else
  begin
    PM_DeletProject.Visible       := true;
    PM_OneProjectTracking.Visible := true;
  end;
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

procedure TFrmMain.ProjectTracking;
var
  i: UInt16;
  ProjectCount: UInt16;
begin
   AddLog('Начало проверки обновлений релизов.');
   ProjectCount := Length(arProjectList);
   if ProjectCount = 0 then
   begin
     AddLog('Список проектов пуст. проверка завершина');
     exit;
   end;

  for i := 0 to ProjectCount -1 do
  begin

  end;

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

procedure TFrmMain.sBtnTestClick(Sender: TObject);
var
  s_temp: string;
  dt: TDateTime;
begin
   mmInfo.Lines.Add(DateTimeToStr(Date+Time));
   // 16.01.2022T14:14:41Z
   //ConvertGitHubDataToDataTime('2021-06-22T11:06:04Z');
   //mmInfo.Lines.Add('dt : ' + DateTimeToStr(dt));
end;

procedure TFrmMain.sLVProjColumnClick(Sender: TObject; Column: TListColumn);
var i: SmallInt;
begin
  if sLVProj.Items.Count < 2 then exit;

  {
  if LastColumnSorted <> Column.Index then
    ArSortColumnsPos[Column.Index] := stASC;
  LastColumnSorted := Column.Index;
  }

  ArSortColumnsPos[Column.Index] := GetWayToSortet(Column.Index);

  sLVProj.CustomSort(@CustomSortProc, Column.Index);

  if ArSortColumnsPos[Column.Index] = stASC then
    ArSortColumnsPos[Column.Index] := stDESC
  else
    ArSortColumnsPos[Column.Index] := stASC;

end;

procedure TFrmMain.TimerTrackerTimer(Sender: TObject);
begin
  // .........
end;

end.
