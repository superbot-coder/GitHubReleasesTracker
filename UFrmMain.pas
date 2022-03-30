unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage, System.IniFiles,
  RESTContentTypeStr, System.JSON, System.IOUtils, System.StrUtils,
  System.DateUtils, Vcl.Mask, Winapi.ShellAPI, BrightDarkSideStyles;

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
    FilterInclude  : string;
    FilterExclude  : string;
    DatePublish    : string;
    Language       : string;
    LastVersion    : string;
    LastChecked    : TDateTime;
    RuleDownload   : UInt8;
    RuleNotis      : UInt8;
    NeedSubDir     : Boolean;
    NewReleaseDT   : TDateTime;
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
    LVProj: TListView;
    mmInfo: TMemo;
    BtnTest: TButton;
    Y1: TMenuItem;
    MM_Settings: TMenuItem;
    PM_OpenDir: TMenuItem;
    N1: TMenuItem;
    PM_OpenUrl: TMenuItem;
    PP_EditItemSettings: TMenuItem;
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
    function GetProjectIndex(ProjectName: string): Integer;
    procedure TimerTrackerTimer(Sender: TObject);
    procedure ProjectTracking;
    procedure OneProjectCheck(ProjectIndex: Integer);
    procedure PM_OneProjectCheckClick(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
    function ConvertGitHubDateToDateTime(GitDateTime: String): String;
    procedure MM_SettingsClick(Sender: TObject);
    procedure PM_OpenDirClick(Sender: TObject);
    procedure PM_OpenUrlClick(Sender: TObject);
    procedure PP_EditItemSettingsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain           : TFrmMain;
  CurrDir           : string;
  CurrPath          : string;
  TEMP              : string;
  ConfigDir         : string;
  FileConfig        : string;
  GLProjectsDir     : String;
  GLDefProjectsDir  : string;
  GLStyleName       : String;
  GLStyleIcon       : Byte;
  arProjectList     : array of TProjectListRec;
  GMT               : ShortInt; // Часовой пояс
  GLNewReleasesLive : Byte;


Const
  CAPTION_MB = 'GitHub Releases Tracker';
  lv_proj_version     = 0;
  lv_date_publish     = 1;
  lv_date_last_check  = 2;
  lv_Language         = 3;
  lv_project_url      = 4;
  c_def_style         = 'Amethyst Kamri';
  c_def_releases_live = 72;
  // ALL_PROJECT_DIR = 'GitHubReleasesTracker';

implementation

{$R *.dfm}

Uses Vcl.Themes, UFrmAddProject, UFrmSettings, UFrmDownloadFiles;

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
    Caption    := '';
    Result     := Index;
    ImageIndex := GLStyleIcon;
    for i := 1 to 5 do SubItems.Add('');
  end;
end;

procedure TFrmMain.AddLog(StrMsg: String);
begin
  mmInfo.Lines.Add(DateTimeToStr(Date + Time)  + ' ' + StrMsg);
end;

function TFrmMain.ConvertGitHubDateToDateTime(GitDateTime: String): String;
var
  fs: TFormatSettings;
begin
  fs.ShortDateFormat := 'YYYY-MM-DD';
  fs.ShortTimeFormat := 'HH:MM:SS';
  fs.DateSeparator   := '-';
  fs.TimeSeparator   := ':';
  // Гдобальное нелокализованое время; global non-localized time
  Result := DateTimeToStr(StrToDateTime(GitDateTime, fs));
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  b: UInt8;
  tz: TTimeZoneInformation;
begin
  GetTimeZoneInformation(tz);
  GMT        := tz.Bias div -60;
  Caption    := CAPTION_MB;
  CurrDir    := ExtractFileDir(Application.ExeName);
  CurrPath   := CurrDir + PathDelim;
  TEMP       := GetEnvironmentVariable('TEMP');
  ConfigDir  := GetEnvironmentVariable('APPDATA') + '\GitHubReleasesTracker';
  FileConfig := ConfigDir + '\Config.ini';
  GLDefProjectsDir := GetEnvironmentVariable('USERPROFILE') + '\Downloads\GitHubReleasesTracker';

  LoadConfigAndProjectList(loadAllConfig);

  if Not AnsiMatchStr(GLStyleName, TStyleManager.StyleNames) Then GLStyleName := 'Windows';
  if AnsiMatchStr(GLStyleName, arDarkStyles) then GLStyleIcon := 2 else GLStyleIcon := 0;
  TStyleManager.SetStyle(GLStyleName);

  if GLProjectsDir = '' then GLProjectsDir := GLDefProjectsDir;

  ProjectListUpdateVisible;
  for b := 0 to Length(ArSortColumnsPos) -1 do ArSortColumnsPos[b] := stASC;

end;

function TFrmMain.GetProjectIndex(ProjectName: string): Integer;
var i: Integer;
begin
  Result := -1;
  for i := 0 to length(arProjectList) -1 do
    if arProjectList[i].FullProjectName = ProjectName then
    begin
      Result := i;
      Break;
    end;
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
  try

    // Загрузка секции настройки программы
    if LoadConfigType = loadAllConfig then
    begin
      Section       := 'SETTINGS';
      GLProjectsDir := INI.ReadString(Section, 'DefaultProjectDir','');
      GLStyleName   := INI.ReadString(Section, 'StyleName', c_def_style);
      GLNewReleasesLive := INI.ReadInteger(Section, 'NewReleasesLive', c_def_releases_live);
    end;

    // Загрузка списка проектов PROJECT_LIST

    LVProj.Clear;
    Section := 'PROJECT_LIST';
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
        FilterInclude   := INI.ReadString(SubSection, 'FilterInclude','');
        FilterExclude   := INI.ReadString(SubSection, 'FilterExclude','');
        DatePublish     := INI.ReadString(SubSection, 'DatePublish','');
        Language        := INI.ReadString(SubSection, 'Language','');
        LastVersion     := INI.ReadString(SubSection, 'LastVersion','');
        LastChecked     := INI.ReadDateTime(SubSection, 'LastChecked', 0);
        RuleDownload    := INI.ReadInteger(SubSection, 'RuleDownload', 0);
        RuleNotis       := INI.ReadInteger(SubSection, 'RuleNotis', 0);
        NeedSubDir      := INI.ReadBool(SubSection, 'NeedSubDir', true);
        NewReleaseDT    := INI.ReadDateTime(SubSection, 'NewReleaseDT', 0);
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
  ProjectListUpdateVisible;
  {
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
  }
end;

procedure TFrmMain.MM_SettingsClick(Sender: TObject);
begin
  FrmSettings.FormShowInit;
end;

procedure TFrmMain.OneProjectCheck(ProjectIndex: Integer);
var
  JSONArray     : TJSONArray;
  tag_name      : string;
  DownloadDir   : string;
  SavedFileName : string;
  ext           : string;
  s_temp        : string;
  STFilters     : TStrings;
  STFilesURL    : TStrings;
  Checked       : Boolean;
  i, j          : UInt8;
  cnt           : UInt8;
  DatePublish   : TDateTime;
begin

  if ProjectIndex = -1 then Exit;

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

  tag_name    := RESTResponse.JSONValue.FindValue('tag_name').Value;
  s_temp      := RESTResponse.JSONValue.FindValue('published_at').Value;
  s_temp      := ConvertGitHubDateToDateTime(s_temp);
  DatePublish := StrToDateTime(s_temp);
  arProjectList[ProjectIndex].LastChecked := Date + Time;

  STFilters  := TStringList.Create;
  STFilesURL := TStringList.Create;
  try

    // ****** проверка версии релиза; verifying release version ******
    if arProjectList[ProjectIndex].LastVersion = tag_name then
    begin
      s_temp := 'Имя проекта: ' +arProjectList[ProjectIndex].ProjectName + #13#10 +
                'Новый релиз не обнаружен' + #13#10 +
                'Проверка релиза завершена.' ;
      MessageBox(Handle, PChar(s_temp), PChar(CAPTION_MB), MB_ICONINFORMATION);
      mmInfo.Lines.Add('[' + DateTimeToStr(Date + Time) + ']' + #13#10 + s_temp);
      // mmInfo.Lines.Add('Проверка релиза завершена.');
      // FrmAddProject.SaveAddedNewProject(ProjectIndex);
      exit;
    end;

    arProjectList[ProjectIndex].LastVersion  := tag_name;
    arProjectList[ProjectIndex].DatePublish  := s_temp;
    arProjectList[ProjectIndex].NewReleaseDT := Date + Time;

    s_temp := 'Oбнаружен новый релиз: ' + tag_name + #13#10 +
              'Название проекта: ' + arProjectList[ProjectIndex].ProjectName + #13#10 + #13#10 +
              'Скачать новые файлы?' + #13#10 +
              'ДА - скачать, НЕТ - Не скачивать';
    if MessageBox(Handle, PChar(s_temp),
                PChar(CAPTION_MB),
                MB_ICONINFORMATION or MB_YESNO) = ID_NO then Exit;

    // Получаю массив загруженных файлов; Getting an array of downloaded files
    JSONArray := RESTResponse.JSONValue.FindValue('assets') as TJSONArray;
    if JSONArray.Count = 0 then
    begin
      // message
      Exit;
    end;

    // создание списка файлов для закачки; creating files list for downloasd
    for i := 0 to JSONArray.Count -1 do
      STFilesURL.Add(JSONArray.Items[i].FindValue('browser_download_url').Value);

    // Условное скачивание, использование фильтра
    // Conditional download, using a filter
    if arProjectList[ProjectIndex].RuleDownload = 1 then
    begin

      // Использую фильтр "Включить"; Use the filter "Include"
      s_temp := StringReplace(arProjectList[ProjectIndex].FilterInclude, ' ', '', [rfReplaceAll]);
      STFilters.Text := StringReplace(s_temp, ',', #13, [rfReplaceAll]);
      //ShowMessage(STFilters.Text);

      cnt := 0;
      while STFilesURL.Count <> cnt do
      begin
        SavedFileName := AnsiLowerCase(STFilesURL.Strings[cnt]);
        Delete(SavedFileName, 1, LastDelimiter('/',SavedFileName));

        Checked := false;
        for j := 0 to STFilters.Count -1 do
          if AnsiPos(STFilters.Strings[j], SavedFileName) <> 0 then
          begin
            Checked := true;
            Break;
          end;

        if Checked = false then
        begin
          STFilesURL.Delete(cnt);
          Continue;
        end;
        Inc(cnt);
      end;

      // Использую фильтр "Исключить"; Use the filter "Exclude"
      s_temp := StringReplace(arProjectList[ProjectIndex].FilterExclude, ' ', '', [rfReplaceAll]);
      STFilters.Text := StringReplace(s_temp, ',', #13, [rfReplaceAll]);

      cnt := 0;
      while STFilesURL.Count <> cnt do
      begin
        SavedFileName := AnsiLowerCase(STFilesURL.Strings[cnt]);
        Delete(SavedFileName, 1, LastDelimiter('/',SavedFileName));

        Checked := false;
        for j := 0 to STFilters.Count -1 do
          if AnsiPos(STFilters.Strings[j], SavedFileName) <> 0 then
          begin
            Checked := true;
            Break;
          end;

        if Checked = true then
        begin
          STFilesURL.Delete(cnt);
          Continue;
        end;
        Inc(cnt);
      end;

    end;

    // ****** Скачивание файлов из списка; Download files from the list ******

    // подготовка директорнии для скачивания; preparing a directory for download
    if arProjectList[ProjectIndex].NeedSubDir then
      DownloadDir := arProjectList[ProjectIndex].ProjectDir + '\' + tag_name
    else
      DownloadDir := arProjectList[ProjectIndex].ProjectDir;
    if Not DirectoryExists(DownloadDir) then ForceDirectories(DownloadDir);

    //mmInfo.Lines.Add(STFilesURL.text);

    for i:=0 to STFilesURL.Count -1 do
    begin

      RESTResponse.RootElement := '';
      RESTClient.Accept        := 'application'; //'application/zip';
      RESTClient.BaseURL       := STFilesURL.Strings[i];
      RESTRequest.Execute;

      if RESTResponse.StatusCode <> 200 then
      begin
        // message ...
        Continue;
      end;

      SavedFileName := STFilesURL.Strings[i];
      Delete(SavedFileName, 1, LastDelimiter('/', SavedFileName));
      if arProjectList[ProjectIndex].NeedSubDir then
        SavedFileName := DownloadDir + '\' + SavedFileName
      else
      begin
        ext           := ExtractFileExt(SavedFileName);
        SavedFileName := Copy(SavedFileName, 1, length(SavedFileName)-length(ext));
        SavedFileName := DownloadDir + '\' + SavedFileName + '_' + tag_name + ext;
      end;

      TFile.WriteAllBytes(SavedFileName, RESTResponse.RawBytes);

      if FileExists(SavedFileName) then
        mmInfo.Lines.Add('Файл: ' + SavedFileName + ' был скачан удачно.')
      else
        mmInfo.Lines.Add('Ошибка файл: ' + SavedFileName + ' не обнаружен.');
    end;


  finally
    STFilters.Free;
    STFilesURL.Free;
    FrmAddProject.SaveAddedNewProject(ProjectIndex);
    ProjectListUpdateVisible;
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
  x: Word;
begin
  x := GetProjectIndex(LVProj.Selected.Caption);
  OneProjectCheck(x);
end;

procedure TFrmMain.PM_OpenDirClick(Sender: TObject);
var
  x: Word;
  ProjDir: string;
begin
  if LVProj.SelCount = 0 then exit;
  x := GetProjectIndex(LVProj.Selected.Caption);
  ProjDir := arProjectList[x].ProjectDir;
  if arProjectList[x].NeedSubDir then
    if DirectoryExists(ProjDir + '\' +arProjectList[x].LastVersion) then
      ProjDir := ProjDir + '\' +arProjectList[x].LastVersion;
  ShellExecute(Handle, PChar('Open'), PChar(ProjDir),Nil, Nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.PM_OpenUrlClick(Sender: TObject);
begin
  if LVProj.SelCount = 0 then exit;
  ShellExecute(Handle, PChar('Open'),
               PChar(arProjectList[GetProjectIndex(LVProj.Selected.Caption)].ProjectUrl),
               Nil, Nil, SW_SHOWMAXIMIZED);
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

procedure TFrmMain.PP_EditItemSettingsClick(Sender: TObject);
begin
  if LVProj.SelCount = 0 then exit;
  FrmAddProject.FormShowEdit(GetProjectIndex(LVProj.Selected.Caption));
end;

procedure TFrmMain.ProjectListUpdateVisible;
var
  i, x, len: Word;
  dt, dtl: TDateTime; //localized  date time
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

      dt := IncHour(arProjectList[i].NewReleaseDT, GLNewReleasesLive);
      if dt < Date + Time then ImageIndex := GLStyleIcon else ImageIndex := 1;

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
begin

  RESTResponse.RootElement := '[0]';
  RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
  RESTClient.BaseURL       := arProjectList[0].ApiReleasesUrl;
  RESTRequest.Execute;

  if RESTResponse.StatusCode <> 200 then Exit;

  FrmDownloadFiles.ShowInit(RESTResponse.JSONValue, 0);

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
