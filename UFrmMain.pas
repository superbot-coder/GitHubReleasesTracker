unit UFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Imaging.pngimage, System.IniFiles,
  RESTContentTypeStr, System.JSON, System.IOUtils, System.StrUtils,
  System.DateUtils, Vcl.Mask, Winapi.ShellAPI, BrightDarkSideStyles, UThreadReposCheck,
  CommonTypes;

type TSortType = (stASC, stDESC);
type TLoadConfigsType = (loadAllConfig, loadReposList);

type
  TFrmMain = class(TForm)
    MainMenu: TMainMenu;
    U1: TMenuItem;
    MM_AddRepository: TMenuItem;
    ImageListRepos: TImageList;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    PopupMenu: TPopupMenu;
    PM_DeletRepository: TMenuItem;
    TimerTracker: TTimer;
    PM_OneRepositoryCheck: TMenuItem;
    LVRepos: TListView;
    mmInfo: TMemo;
    BtnTest: TButton;
    Y1: TMenuItem;
    MM_Settings: TMenuItem;
    PM_OpenDir: TMenuItem;
    N1: TMenuItem;
    PM_OpenUrl: TMenuItem;
    PM_EditSettings: TMenuItem;
    PM_DownloadFiles: TMenuItem;
    Help: TMenuItem;
    MM_CheckMainUpdate: TMenuItem;
    MM_OpenGitHubRepos: TMenuItem;
    StatusBar: TStatusBar;
    MM_AvtoCheckMode: TMenuItem;
    Button1: TButton;
    procedure MM_AddRepositoryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure PM_DeletRepositoryClick(Sender: TObject);
    procedure ReposListUpdateVisible;
    procedure AddLog(StrMsg: String);
    procedure LVReposColumnClick(Sender: TObject; Column: TListColumn);
    procedure TimerTrackerTimer(Sender: TObject);
    procedure OneReleaseCheck(ReposIndex: Integer);
    procedure PM_OneRepositoryCheckClick(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
    procedure MM_SettingsClick(Sender: TObject);
    procedure PM_OpenDirClick(Sender: TObject);
    procedure PM_OpenUrlClick(Sender: TObject);
    procedure PM_EditSettingsClick(Sender: TObject);
    procedure PM_DownloadFilesClick(Sender: TObject);
    procedure MM_OpenGitHubReposClick(Sender: TObject);
    procedure MM_CheckMainUpdateClick(Sender: TObject);
    procedure MM_AvtoCheckModeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
     STLogList: TStrings;
     procedure RemoveRepositoryFromReposList(FullRepositoryName: String);
     procedure RepositoryTracking;
     procedure LoadConfigAndProjectList(LoadConfigType: TLoadConfigsType);
     function AddItems: Integer;
     function GetWayToSortet(ColumnIndex: UInt8): TSortType;
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
  GLReposDir        : String;
  GLDefReposDir     : string;
  GLStyleName       : String;
  GLStyleIcon       : Byte;
  arReposList       : array of TRepositoryRec;
  GMT               : ShortInt; // Часовой пояс
  GLNewReleasesLive : Byte;

  ThrReposCheck: ThreadReposCheck;

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

// function ConvertGitHubDateToDateTime(GitDateTime: String): String;

implementation

{$R *.dfm}

Uses Vcl.Themes, UFrmAddRepository, UFrmSettings, UFrmDownloadFiles;

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
  with LVRepos.Items.Add do
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

{
function ConvertGitHubDateToDateTime(GitDateTime: String): String;
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
}

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
  GLDefReposDir := GetEnvironmentVariable('USERPROFILE') + '\Downloads\GitHubReleasesTracker';
  STLogList  := TStringList.Create;

  LoadConfigAndProjectList(loadAllConfig);

  if Not AnsiMatchStr(GLStyleName, TStyleManager.StyleNames) Then GLStyleName := 'Windows';
  if AnsiMatchStr(GLStyleName, arDarkStyles) then GLStyleIcon := 2 else GLStyleIcon := 0;
  TStyleManager.SetStyle(GLStyleName);

  if GLReposDir = '' then GLReposDir := GLDefReposDir;
  ReposListUpdateVisible;

  for b := 0 to Length(ArSortColumnsPos) -1 do ArSortColumnsPos[b] := stASC;

end;

function TFrmMain.GetWayToSortet(ColumnIndex: UInt8): TSortType;
// Функция определяет направление сортировки
// The function determines the direction of sorting
var
  r, x: Integer;
begin
  r := 0;
  x := 1;
  with LVRepos do
  begin
    if ColumnIndex = 0 then
    begin
      while (x < LVRepos.Items.Count-1) do
      begin
        r := AnsiCompareText(Items[0].Caption, Items[x].Caption);
        if r <> 0 then Break;
        inc(x);
      end;
    end
      else
    begin
      while (x < LVRepos.Items.Count) do
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
      GLReposDir    := INI.ReadString(Section, 'DefaultRepositoryDir','');
      GLStyleName   := INI.ReadString(Section, 'StyleName', c_def_style);
      GLNewReleasesLive := INI.ReadInteger(Section, 'NewReleasesLive', c_def_releases_live);
      MM_AvtoCheckMode.Checked := INI.ReadBool(Section, 'AvtoCheckMode', false);
      TimerTracker.Enabled     := MM_AvtoCheckMode.Checked;
    end;

    // Загрузка списка репозиториев REPOSITORY_LIST

    LVRepos.Clear;
    Section := 'REPOSITORY_LIST';
    INI.ReadSubSections(Section, ST, false);
    arReposList := Nil;
    SetLength(arReposList, ST.Count);
    for i := 0 to ST.Count -1 do
    begin
      SubSection := Section + '\' + ST.Strings[i];
      with arReposList[i] do
      begin
        ReposUrl        := INI.ReadString(SubSection, 'RepositoryUrl', '');
        ReposDir        := INI.ReadString(SubSection, 'RepositoryDir','');
        ApiReposUrl     := INI.ReadString(SubSection, 'ApiRepositoryUrl','');
        ApiReleasesUrl  := INI.ReadString(SubSection, 'ApiReleasesUrl','');
        ReposName       := INI.ReadString(SubSection, 'RepositoryName','');
        FullReposName   := INI.ReadString(SubSection, 'FullRepositoryName', '');
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
        AddVerToFileName:= INI.ReadBool(SubSection, 'AddVerToFileName', false);
        TimelAvtoCheck  := INI.ReadInteger(SubSection, 'TimeAuvtoCheck', 24);
      end;
    end;
  finally
    ST.Free;
    INI.Free;
  end;
end;

procedure TFrmMain.MM_AddRepositoryClick(Sender: TObject);
var
  i, x: Integer;
begin
  FrmAddRepository.FrmShowInit;
  if Not FrmAddRepository.Applay then Exit;
  // ReposListUpdateVisible;
  i := Length(arReposList)-1;
  x := AddItems;
  with LVRepos.Items[x] do
  begin
    Caption                      := arReposList[i].FullReposName;
    SubItems[lv_proj_version]    := arReposList[i].LastVersion;
    SubItems[lv_date_publish]    := arReposList[i].DatePublish;
    SubItems[lv_date_last_check] := DateTimeToStr(arReposList[i].LastChecked);
    SubItems[lv_Language]        := arReposList[i].Language;
    SubItems[lv_project_url]     := arReposList[i].ReposUrl;
    ImageIndex := 1;
  end;
end;

procedure TFrmMain.MM_AvtoCheckModeClick(Sender: TObject);
var INI: TIniFile;
begin
  if MM_AvtoCheckMode.Checked then
  begin
    ShowMessage('Режим будет отключчен');
    MM_AvtoCheckMode.Checked := false;
    StatusBar.Panels[1].Text := 'Режим Авто проверки: остановлен';
    TimerTracker.Enabled     := false;
  end
  else
  begin
    ShowMessage('Режим будет включчен');
    MM_AvtoCheckMode.Checked := true;
    StatusBar.Panels[1].Text := 'Режим Авто проверки: запущен';
    TimerTracker.Enabled     := true;
  end;

  if Not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  INI := TIniFile.Create(FileConfig);
  try
    INI.WriteBool('SETTINGS', 'AvtoCheckMode', MM_AvtoCheckMode.Checked);
  finally
    INI.Free;
  end;
end;

procedure TFrmMain.MM_OpenGitHubReposClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('Open'),
               PChar('https://github.com/superbot-coder/GitHubReleasesTracker'),
               Nil, Nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.MM_SettingsClick(Sender: TObject);
begin
  FrmSettings.FormShowInit;
end;

procedure TFrmMain.MM_CheckMainUpdateClick(Sender: TObject);
begin
  //TimerTracker.Enabled := false;
  FrmDownloadFiles.ShowInit(Sender);

  //TimerTracker.Enabled := true;
end;

procedure TFrmMain.OneReleaseCheck(ReposIndex: Integer);
var
  JSONArray     : TJSONArray;
  tag_name      : string;
  s_temp        : string;
  vDatePublish  : TDateTime;
begin

  if ReposIndex = -1 then Exit;

  RESTResponse.RootElement := '[0]';
  RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
  RESTClient.BaseURL       := arReposList[ReposIndex].ApiReleasesUrl;
  RESTRequest.Execute;

  if RESTResponse.StatusCode <> 200 then
  begin
    // message
    Exit;
  end;

  // JSONValue := RESTResponse.JSONValue;

  if RESTResponse.JSONValue = Nil then
  begin
    MessageBox(Handle, PChar('Имя репозитория: ' + arReposList[ReposIndex].ReposName
                + #13+ 'Не было обнаружено ни одного репозитория.'),
               PChar(CAPTION_MB), MB_ICONWARNING);
    Exit;
  end;

  if RESTResponse.JSONValue.FindValue('tag_name') = nil then
  begin
    //
    exit;
  end;

  tag_name    := RESTResponse.JSONValue.FindValue('tag_name').Value;
  s_temp      := RESTResponse.JSONValue.FindValue('published_at').Value;
  s_temp      := XSDateTimeToDateTimeStr(s_temp); //ConvertGitHubDateToDateTime(s_temp);
  vDatePublish := StrToDateTime(s_temp);
  arReposList[ReposIndex].LastChecked := Date + Time;

  try
    // ****** проверка версии релиза; verifying release version ******
    if arReposList[ReposIndex].LastVersion = tag_name then
    begin
      s_temp := 'Имя репозитория: ' +arReposList[ReposIndex].ReposName + #13#10 +
                'Новый релиз не обнаружен' + #13#10 +
                'Проверка релиза завершена.' ;
      MessageBox(Handle, PChar(s_temp), PChar(CAPTION_MB), MB_ICONINFORMATION);
      mmInfo.Lines.Add('[' + DateTimeToStr(Date + Time) + ']' + #13#10 + s_temp);
      // mmInfo.Lines.Add('Проверка релиза завершена.');
      // FrmAddProject.SaveAddedNewProject(ProjectIndex);
      exit;
    end;

    arReposList[ReposIndex].LastVersion  := tag_name;
    arReposList[ReposIndex].DatePublish  := s_temp;
    arReposList[ReposIndex].NewReleaseDT := Date + Time;

    s_temp := 'Oбнаружен новый релиз: ' + tag_name + #13#10 +
              'Название проекта: ' + arReposList[ReposIndex].ReposName + #13#10 + #13#10 +
              'Скачать новые файлы?' + #13#10 +
              'ДА - скачать, НЕТ - Не скачивать';
    if MessageBox(Handle, PChar(s_temp),
                PChar(CAPTION_MB),
                MB_ICONINFORMATION or MB_YESNO) = ID_NO then Exit;

    FrmDownloadFiles.ShowInit(RESTResponse.JSONValue, arReposList[ReposIndex]);

  finally
    SaveReposRecDeltaConfig(arReposList[ReposIndex]);
    ReposListUpdateVisible;
  end;

end;

procedure TFrmMain.PM_DeletRepositoryClick(Sender: TObject);
Var
  DelReposName: string;
  INI: TIniFile;
begin
  if MessageBox(Handle, PChar('Вы собераетесь удалить репозиторий из списка'
                + #13#10 + ' Продолжить?'),
                PChar(CAPTION_MB), MB_ICONWARNING or MB_YESNO) = ID_NO then Exit;
  DelReposName := LVRepos.Selected.Caption;
  RemoveRepositoryFromReposList(LVRepos.Selected.Caption);
  ReposListUpdateVisible;
  INI := TIniFile.Create(FileConfig);
  try
    INI.EraseSection('REPOSITORY_LIST\' + StringReplace(DelReposName, '/', '_', []));
  finally
    INI.Free;
  end;
end;

procedure TFrmMain.PM_DownloadFilesClick(Sender: TObject);
begin
  FrmDownloadFiles.ShowInit(Nil, arReposList[GetReposIndex(LVRepos.Selected.Caption)]);
end;

procedure TFrmMain.PM_OneRepositoryCheckClick(Sender: TObject);
begin
  OneReleaseCheck(GetReposIndex(LVRepos.Selected.Caption));
end;

procedure TFrmMain.PM_OpenDirClick(Sender: TObject);
var
  i: Word;
  ProjDir: string;
begin
  i := GetReposIndex(LVRepos.Selected.Caption);
  ProjDir := arReposList[i].ReposDir;
  if arReposList[i].NeedSubDir then
    if DirectoryExists(ProjDir + '\' +arReposList[i].LastVersion) then
      ProjDir := ProjDir + '\' +arReposList[i].LastVersion;
  ShellExecute(Handle, PChar('Open'), PChar(ProjDir),Nil, Nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.PM_OpenUrlClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('Open'),
               PChar(arReposList[GetReposIndex(LVRepos.Selected.Caption)].ReposUrl),
               Nil, Nil, SW_SHOWNORMAL);
end;

procedure TFrmMain.PopupMenuPopup(Sender: TObject);
begin
  if (LVRepos.Items.Count = 0) or (LVRepos.SelCount = 0) then
  begin
    PM_DeletRepository.Visible    := false;
    PM_OneRepositoryCheck.Visible := false;
    PM_OpenDir.Visible            := false;
    PM_OpenUrl.Visible            := false;
    PM_DownloadFiles.Visible      := false;
    PM_EditSettings.Visible       := false;
  end
  else
  begin
    PM_DeletRepository.Visible    := true;
    PM_OneRepositoryCheck.Visible := true;
    PM_OpenDir.Visible            := true;
    PM_OpenUrl.Visible            := true;
    PM_DownloadFiles.Visible      := true;
    PM_EditSettings.Visible       := true;
  end;
end;

procedure TFrmMain.PM_EditSettingsClick(Sender: TObject);
begin
  FrmAddRepository.FormShowEdit(GetReposIndex(LVRepos.Selected.Caption));
end;

procedure TFrmMain.ReposListUpdateVisible;
var
  i, x, len: Word;
  dt, dtl: TDateTime; //localized  date time
begin
  LVRepos.Items.Clear;
  len := Length(arReposList);
  if len = 0 then Exit;

  LVRepos.Items.BeginUpdate;
  for i := 0 to Len-1 do
  begin
    x := AddItems;
    with LVRepos.Items[x] do
    begin
      Caption                      := arReposList[i].FullReposName;
      SubItems[lv_proj_version]    := arReposList[i].LastVersion;
      // Получаю локализованую дату и время; Getting localized date time
      if arReposList[i].DatePublish <> '' then
        dtl := IncHour(StrToDateTime(arReposList[i].DatePublish), GMT);
      SubItems[lv_date_publish]    := DateTimeToStr(dtl);
      //SubItems[lv_date_publish]    := arReposList[i].DatePublish; // No GMT
      SubItems[lv_date_last_check] := DateTimeToStr(arReposList[i].LastChecked);
      SubItems[lv_Language]        := arReposList[i].Language;
      SubItems[lv_project_url]     := arReposList[i].ReposUrl;

      dt := IncHour(arReposList[i].NewReleaseDT, GLNewReleasesLive);
      if dt < Date + Time then ImageIndex := GLStyleIcon else ImageIndex := 1;

    end;
  end;
  LVRepos.Items.EndUpdate;
end;

procedure TFrmMain.RepositoryTracking;
var
  i: UInt16;
  ReposCount: UInt16;
begin
   AddLog('Начало проверки обновлений релизов.');
   ReposCount := Length(arReposList);
   if ReposCount = 0 then
   begin
     AddLog('Список репозиториев пуст. проверка завершена');
     exit;
   end;

  for i := 0 to ReposCount -1 do
  begin
    //....................
  end;

end;

procedure TFrmMain.RemoveRepositoryFromReposList(FullRepositoryName: String);
var
  i, ix, len: Word;
begin
  len := Length(arReposList);
  for i := 0 to Len - 1 do
  begin
    if arReposList[i].FullReposName = FullRepositoryName then
    begin
       if i = len-1 then
       begin
         setLength(arReposList, len-1);
         Exit;
       end;
       for ix := i + 1 to len-1 do arReposList[ix-1] := arReposList[ix];
       setLength(arReposList, len-1);
       Exit;
    end;
  end;
end;

procedure TFrmMain.BtnTestClick(Sender: TObject);
var
  s: string;
  v: string;
  i: integer;
begin

  mmInfo.Lines.Add(IntToStr(GetReposIndex('superbot-coder/chia_plotting_tools')));
  //ThrReposCheck := ThreadReposCheck.Create(0, true);

  FrmDownloadFiles.ShowInit(Nil, arReposList[15]);

end;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  ThrReposCheck.Start;
  //ThrReposCheck.Terminate;
end;

procedure TFrmMain.LVReposColumnClick(Sender: TObject; Column: TListColumn);
var i: SmallInt;
begin
  if LVRepos.Items.Count < 2 then exit;
  {
  if LastColumnSorted <> Column.Index then
    ArSortColumnsPos[Column.Index] := stASC;
  LastColumnSorted := Column.Index;
  }

  // Функция GetWayToSortet() определяет направление сортировки
  // The function GetWayToSortet() determines the direction of sorting
  ArSortColumnsPos[Column.Index] := GetWayToSortet(Column.Index);

  LVRepos.CustomSort(@CustomSortProc, Column.Index);

  if ArSortColumnsPos[Column.Index] = stASC then
    ArSortColumnsPos[Column.Index] := stDESC
  else
    ArSortColumnsPos[Column.Index] := stASC;
end;

procedure TFrmMain.TimerTrackerTimer(Sender: TObject);
var
   ReposItem: TRepositoryRec;
   s: string;
begin

  for ReposItem in arReposList do
  begin
    if Not MM_AvtoCheckMode.Checked then Exit;
    if IncHour(ReposItem.LastChecked, ReposItem.TimelAvtoCheck) < Date + Time then
    begin
      s := DateTimeToStr(IncHour(ReposItem.LastChecked, ReposItem.TimelAvtoCheck));
      mmInfo.Lines.Add(ReposItem.FullReposName + '  проверка ' +s)
    end
    else
    begin
      s := DateTimeToStr(IncHour(ReposItem.LastChecked, ReposItem.TimelAvtoCheck));
      mmInfo.Lines.Add(ReposItem.FullReposName + '  нет проверки '+s);
    end;
  end;

  // TimerTracker.Enabled := false;
end;

end.
