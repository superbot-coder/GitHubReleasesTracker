Unit CommonTypes;

interface

Uses
  System.SysUtils, System.IniFiles, RESTContentTypeStr;

type
  TRepositoryRec = Record
    ReposUrl       : string; // Repository URL
    ReposDir       : string; // Repository Directory
    ApiReposUrl    : string; // Api repository URL
    ApiReleasesUrl : string; // Api Repository Releases URL
    ReposName      : string; // Repository name
    FullReposName  : string; //
    AvatarFile     : string; //
    AvatarUrl      : string; //
    FilterInclude  : string; //
    FilterExclude  : string; //
    DatePublish    : string; // Дата публикации релиза на GitHub
    Language       : string; // Язык программирования репозитория (бонус)
    LastVersion    : string; // Последняя версия релиза
    LastChecked    : TDateTime; // Дата и время последней проверки
    RuleDownload   : UInt8;     // Параметры правила для скасивания
    RuleNotis      : UInt8;     // Параметры правила для уведомления об новой версии
    NeedSubDir     : Boolean;   // необходимость субдиректории для каждого редиза
    NewReleaseDT   : TDateTime; // Дата и время скачивания нового релиза
    AddVerToFileName: Boolean;  // Прибавлять версию релиза к сохраняемому файлу
    TimelAvtoCheck : Byte;      // Время интервала для автоматической проверки релиза
  End;

procedure SaveReposRecDeltaConfig(ReposRec: TRepositoryRec);
procedure SaveReposRecConfig(ReposRec: TRepositoryRec);
function GetReposIndex(ReposytoryName: string): Integer;
function XSDateTimeToDateTime(XSDateTime: string): TDateTime;
function XSDateTimeToDateTimeStr(XSDateTime: string): string;

implementation

Uses UFrmMain;

Var
  INI: TIniFile;
  Section: string;

{---------------------------- SaveReposRecDeltaConfig -------------------------}
procedure SaveReposRecDeltaConfig(ReposRec: TRepositoryRec);
begin
  if Not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  Section := 'REPOSITORY_LIST\'+ StringReplace(ReposRec.FullReposName, '/', '_', [rfReplaceAll]);
  INI := TIniFile.Create(FileConfig);
  try
    INI.WriteString(Section, 'DatePublish', ReposRec.DatePublish);
    INI.WriteString(Section, 'LastVersion', ReposRec.LastVersion);
    INI.WriteDateTime(Section, 'LastChecked', ReposRec.LastChecked);
    INI.WriteDateTime(Section, 'NewReleaseDT', ReposRec.NewReleaseDT);
  finally
    INI.free;
  end;
end;

{--------------------------- SaveReposRecConfig -------------------------------}
procedure SaveReposRecConfig(ReposRec: TRepositoryRec);
begin
  if Not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  Section := 'REPOSITORY_LIST\'+ StringReplace(ReposRec.FullReposName, '/', '_', [rfReplaceAll]);
  INI := TIniFile.Create(FileConfig);
  try
    with INI do
    begin
      WriteString(Section, 'RepositoryUrl', ReposRec.ReposUrl);
      WriteString(Section, 'RepositoryDir', ReposRec.ReposDir);
      WriteString(Section, 'ApiRepositoryUrl', ReposRec.ApiReposUrl);
      WriteString(Section, 'ApiReleasesUrl', ReposRec.ApiReleasesUrl);
      WriteString(Section, 'RepositoryName', ReposRec.ReposName);
      WriteString(Section, 'FullRepositoryName', ReposRec.FullReposName);
      WriteString(Section, 'AvatarFile', ReposRec.AvatarFile);
      WriteString(Section, 'AvatarUrl',ReposRec.AvatarUrl );
      WriteString(Section, 'FilterInclude', ReposRec.FilterInclude);
      WriteString(Section, 'FilterExclude', ReposRec.FilterExclude);
      WriteString(Section, 'DatePublish', ReposRec.DatePublish);
      WriteString(Section, 'Language', ReposRec.Language);
      WriteString(Section, 'LastVersion', ReposRec.LastVersion);
      WriteDateTime(Section, 'LastChecked', ReposRec.LastChecked);
      WriteInteger(Section, 'RuleDownload', ReposRec.RuleDownload);
      WriteInteger(Section, 'RuleNotis', ReposRec.RuleNotis);
      WriteBool(Section, 'NeedSubDir', ReposRec.NeedSubDir);
      WriteDateTime(Section, 'NewReleaseDT', ReposRec.NewReleaseDT);
      WriteBool(Section, 'AddVerToFileName', ReposRec.AddVerToFileName);
      WriteInteger(Section, 'TimeAvtoCheck', ReposRec.TimelAvtoCheck);
    end;
  finally
    INI.Free;
  end;
end;

{------------------------------ GetReposIndex --------------------------------}
function GetReposIndex(ReposytoryName: string): Integer;
var i: Integer;
begin
  Result := -1;
  for i := 0 to length(arReposList) -1 do
    if arReposList[i].FullReposName = ReposytoryName then
    begin
      Result := i;
      Break;
    end;
end;
{------------------------- XSDateTimeDateToDateTime ---------------------------}
function XSDateTimeToDateTime(XSDateTime: string): TDateTime;
var
  fs: TFormatSettings;
begin
  fs.ShortDateFormat := 'YYYY-MM-DD';
  fs.ShortTimeFormat := 'HH:MM:SS';
  fs.DateSeparator   := '-';
  fs.TimeSeparator   := ':';
  // Гдобальное нелокализованое время; global non-localized time
  Result := StrToDateTime(XSDateTime, fs);
end;
{----------------------- XSDateTimeDateToDateTimeStr --------------------------}
function XSDateTimeToDateTimeStr(XSDateTime: string): string;
begin
  Result := DateTimeToStr(XSDateTimeToDateTime(XSDateTime));
end;

end.