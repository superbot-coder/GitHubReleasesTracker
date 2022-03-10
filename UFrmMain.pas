unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage, System.IniFiles,
  RESTContentTypeStr, System.JSON, System.IOUtils, System.StrUtils,
  System.DateUtils, Vcl.Mask;

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
    Language       : string;
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
    ImageListProj: TImageList;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    PopupMenu: TPopupMenu;
    PM_DeletProject: TMenuItem;
    TimerTracker: TTimer;
    PM_OneProjectCheck: TMenuItem;
    cbxVclStyles: TComboBox;
    LVProj: TListView;
    Label1: TLabel;
    mmInfo: TMemo;
    BtnTest: TButton;
    procedure MM_AddReleasesClick(Sender: TObject);
    function AddItems: Integer;
    procedure FormCreate(Sender: TObject);
    procedure LoadConfigAndProjectList(LoadConfigType: TLoadConfigsType);
    procedure PopupMenuPopup(Sender: TObject);
    procedure PM_DeletProjectClick(Sender: TObject);
    procedure RemoveProjectFromProjectList(FullProjectName: String);
    procedure ProjectListUpdateVisible;
    procedure AddLog(StrMsg: String);
    procedure LVProjColumnClick(Sender: TObject; Column: TListColumn);
    function GetWayToSortet(ColumnIndex: UInt8): TSortType;
    function GetProjectIndex(ProjectName: string): UInt16;
    procedure TimerTrackerTimer(Sender: TObject);
    procedure ProjectTracking;
    procedure OneProjectCheck(ProjectIndex: UInt16);
    procedure PM_OneProjectCheckClick(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
    function ConvertGitHubDateToDateTime(GitDateTime: String): String;
    procedure cbxVclStylesChange(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain        : TFrmMain;
  CurrDir        : string;
  CurrPath       : string;
  TEMP           : string;
  ConfigDir      : string;
  FileConfig     : string;
  GLProjectsPath : String;
  arProjectList  : array of TProjectListRec;
  GMT            : ShortInt; // Часовой пояс

Const
  CAPTION_MB = 'GitHub Releases Tracker';
  lv_proj_version     = 0;
  lv_date_publish     = 1;
  lv_date_last_check  = 2;
  lv_Language         = 3;
  lv_project_url      = 4;
  // ALL_PROJECT_DIR = 'GitHubReleasesTracker';

implementation

{$R *.dfm}

Uses Vcl.Themes, UFrmAddProject, UFrmSettings;

Var
  ArSortColumnsPos: array[0..5] of TSortType;
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
var i: byte;
begin
  with LVProj.Items.Add do
  begin
    Caption := ''; IntToStr(Index + 1);
    Result  := Index;
    ImageIndex := 0;
    for i := 1 to 5 do SubItems.Add('');
  end;
end;

procedure TFrmMain.AddLog(StrMsg: String);
begin
  mmInfo.Lines.Add(DateTimeToStr(Date + Time)  + ' ' + StrMsg);
end;

procedure TFrmMain.cbxVclStylesChange(Sender: TObject);
begin
  TStyleManager.SetStyle(cbxVclStyles.Text);
end;

function TFrmMain.ConvertGitHubDateToDateTime(GitDateTime: String): String;
var
  fs: TFormatSettings;
begin
  fs.ShortDateFormat := 'YYYY-MM-DD';
  fs.ShortTimeFormat := 'HH:MM:SS';
  fs.DateSeparator   := '-';
  fs.TimeSeparator   := ':';
  //gдобальное нелокализованое время; global non-localized time
  Result := DateTimeToStr(StrToDateTime(GitDateTime, fs));
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  b: UInt8;
  tz: TTimeZoneInformation;
  StyleName: string;
begin
  GetTimeZoneInformation(tz);
  GMT := tz.Bias div -60;
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

  for StyleName in TStyleManager.StyleNames do cbxVclStyles.Items.Add(StyleName);
  cbxVclStyles.Text := 'Amethyst Kamri';
  TStyleManager.SetStyle(cbxVclStyles.Items[4]);
  TStyleManager.SetStyle('Amethyst Kamri');

end;

function TFrmMain.GetProjectIndex(ProjectName: string): UInt16;
begin
  Result := 0;
end;

function TFrmMain.GetWayToSortet(ColumnIndex: UInt8): TSortType;
// Функция определяет направление сортировки
// The function determines the direction of sorting
var
  r, x: Integer;
begin
  r := 0;
  x := 1;
  with LVProj do
  begin
    if ColumnIndex = 0 then
    begin
      while (x < LVProj.Items.Count-1) do
      begin
        r := AnsiCompareText(Items[0].Caption, Items[x].Caption);
        if r <> 0 then Break;
        inc(x);
      end;
    end
      else
    begin
      while (x < LVProj.Items.Count) do
      begin
        r := AnsiCompareText(Items[0].SubItems[ColumnIndex-1], Items[x].SubItems[ColumnIndex-1]);
        if r <> 0 then Break;
        Inc(x);
      end;
    end;
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
  LVProj.Clear;
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
        Language        := INI.ReadString(SubSection, 'Language','');
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
  with LVProj.Items[x] do
  begin
    Caption                      := arProjectList[i].FullProjectName;
    SubItems[lv_proj_version]    := arProjectList[i].LastVersion;
    SubItems[lv_date_publish]    := arProjectList[i].DatePublish;
    SubItems[lv_date_last_check] := DateTimeToStr(arProjectList[i].LastChecked);
    SubItems[lv_Language]        := arProjectList[i].Language;
    SubItems[lv_project_url]     := arProjectList[i].ProjectUrl;
  end;
end;

procedure TFrmMain.OneProjectCheck(ProjectIndex: UInt16);
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
  DelProjName := LVProj.Selected.Caption;

  RemoveProjectFromProjectList(LVProj.Selected.Caption);
  ProjectListUpdateVisible;

  INI := TIniFile.Create(FileConfig);
  try
    INI.EraseSection('PROJECT_LIST\' + DelProjName);
  finally
    INI.Free;
  end;

end;

procedure TFrmMain.PM_OneProjectCheckClick(Sender: TObject);
var
  x: UInt16;
begin
  x := GetProjectIndex(LVProj.Selected.Caption);
  OneProjectCheck(x);
end;

procedure TFrmMain.PopupMenuPopup(Sender: TObject);
begin
  if (LVProj.Items.Count = 0) or (LVProj.SelCount = 0) then
  begin
    PM_DeletProject.Visible    := false;
    PM_OneProjectCheck.Visible := false;
  end
  else
  begin
    PM_DeletProject.Visible    := true;
    PM_OneProjectCheck.Visible := true;
  end;
end;

procedure TFrmMain.ProjectListUpdateVisible;
var
  i, x, len: Word;
  dtl: TDateTime; //localized  date time
begin
  LVProj.Items.Clear;
  len := Length(arProjectList);
  if len = 0 then Exit;

  LVProj.Items.BeginUpdate;
  for i := 0 to Len-1 do
  begin
    x := AddItems;
    with LVProj.Items[x] do
    begin
      Caption                      := arProjectList[i].FullProjectName;
      SubItems[lv_proj_version]    := arProjectList[i].LastVersion;
      // Получаю локализованую дату и время; Getting localized date time
      if arProjectList[i].DatePublish <> '' then
        dtl := IncHour(StrToDateTime(arProjectList[i].DatePublish), GMT);
      SubItems[lv_date_publish]    := DateTimeToStr(dtl);
      //SubItems[lv_date_publish]    := arProjectList[i].DatePublish; // No GMT
      SubItems[lv_date_last_check] := DateTimeToStr(arProjectList[i].LastChecked);
      SubItems[lv_Language]        := arProjectList[i].Language;
      SubItems[lv_project_url]     := arProjectList[i].ProjectUrl;
    end;
  end;
  LVProj.Items.EndUpdate;
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
    //....................
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

procedure TFrmMain.BtnTestClick(Sender: TObject);
var
  s: string;
  tz: TTimeZoneInformation;
  fs: TFormatSettings;
  dt:  TDateTime; // пдобальное нелокализованое время
  dtl: TDateTime; // локализованное время с учетом часового пояса
  GMT: ShortInt;
begin

   GetTimeZoneInformation(tz);
   GMT := tz.Bias div -60;
   mmInfo.Lines.Add('GMT ' + IntToStr(GMT));
   mmInfo.Lines.Add(tz.StandardName);
   mmInfo.Lines.Add(tz.DaylightName);
   mmInfo.Lines.Add('GMT ' + IntToStr(tz.DaylightBias div -60 ));


   // YYYY-MM-DDTHH:MM:SSZ '2021-06-22T11:06:04Z'
   fs.ShortDateFormat := 'YYYY-MM-DD';
   fs.ShortTimeFormat := 'HH:MM:SS';
   fs.DateSeparator  := '-';
   fs.TimeSeparator  := ':';
   dt  := StrToDateTime('2021-06-22T11:06:04Z', fs);
   dtl := IncHour(dt, GMT);

   mmInfo.Lines.Add('dt: ' +DateTimeToStr(dt) + ' dtl: ' + DateTimeToStr(dtl));

   s := ConvertGitHubDateToDateTime('2021-06-22T11:06:04Z');
   mmInfo.Lines.Add('DateTime : ' + s);

end;

procedure TFrmMain.LVProjColumnClick(Sender: TObject; Column: TListColumn);
var i: SmallInt;
begin
  if LVProj.Items.Count < 2 then exit;

  {
  if LastColumnSorted <> Column.Index then
    ArSortColumnsPos[Column.Index] := stASC;
  LastColumnSorted := Column.Index;
  }

  // Функция GetWayToSortet() определяет направление сортировки
  // The function GetWayToSortet() determines the direction of sorting
  ArSortColumnsPos[Column.Index] := GetWayToSortet(Column.Index);

  LVProj.CustomSort(@CustomSortProc, Column.Index);

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
