unit UThreadReposCheck;

interface

uses
  System.Classes, System.SysUtils, System.JSON, System.IOUtils, REST.Types, REST.Client,
  CommonTypes, Vcl.Dialogs;

type
  ThreadReposCheck = class(TThread)
  private
    FReposIndex  : SmallInt;
    RESTClient   : TRESTClient;
    RESTRequest  : TRESTRequest;
    RESTResponse : TRESTResponse;
    FReposRec    : TRepositoryListRec;
    STFilters    : TStrings;
    STFilesURL   : TStrings;
    STFileName   : TStrings;
    FLastVersion : string;
    Ftag_name    : string;
    FDatePublish : string;
    FDtNewRelease: TDateTime;
    FLastChecked : TDateTime;
    FMsg         : string;
    Procedure FiltersExecute;
    procedure SendMsg(MsgStr: String);
    procedure MemoMessage;
    procedure SaveReposRec;
  protected
    procedure Execute; override;
  public
    constructor Create(ReposIndex: SmallInt; CreateSuspended: Boolean);
    destructor  Destroy;
  end;

implementation

USES UFrmMain, UFrmAddRepository;

constructor ThreadReposCheck.Create(ReposIndex: SmallInt; CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FReposIndex  := ReposIndex;
  FReposRec    := arReposList[ReposIndex];
  RESTClient   := TRESTClient.Create(FReposRec.ApiReleasesUrl);
  RESTRequest  := TRESTRequest.Create(Nil);
  RESTResponse := TRESTResponse.Create(Nil);
  RESTRequest.Client   := RESTClient;
  RESTRequest.Response := RESTResponse;
  RESTResponse.RootElement := '[0]';
  STFilters  := TStringList.Create;
  STFilesURL := TStringList.Create;
  STFileName := TStringList.Create;
end;

destructor ThreadReposCheck.Destroy;
begin
  inherited Destroy;
  RESTClient.Free;
  RESTRequest.Free;
  RESTResponse.Free;
  STFilters.Free;
  STFilesURL.Free;
  STFileName.Free;
end;

procedure ThreadReposCheck.Execute;
var
  JSONArray: TJSONArray;
  s_temp: string;
  i, j, cnt: byte;
  DownloadDir: string;
  SavedFileName: string;
begin

  RESTRequest.Execute;

  if RESTResponse.StatusCode <> 200 then
  begin
    SendMsg('StatusCode = ' + RESTResponse.StatusText);
    Exit;
  end;

  SendMsg('StatusCode = ' + RESTResponse.StatusText);

  if RESTResponse.JSONValue = Nil then Exit;
  if RESTResponse.JSONValue.FindValue('tag_name') = nil then exit;

  Ftag_name    := RESTResponse.JSONValue.FindValue('tag_name').Value;
  s_temp       := RESTResponse.JSONValue.FindValue('published_at').Value;
  s_temp       := ConvertGitHubDateToDateTime(s_temp);
  FDatePublish := s_temp;
  FLastChecked := Date + Time;

  // ****** проверка версии релиза; verifying release version ******
  if (FReposRec.LastVersion <> Ftag_name) and
      (StrToDateTime(FReposRec.DatePublish) < StrToDateTime(FDatePublish)) then
  begin
    //
    //exit;
  end;

  FLastVersion  := Ftag_name;
  FDtNewRelease := Date + Time;

  // Получаю массив загруженных файлов; Getting an array of downloaded files
  JSONArray := RESTResponse.JSONValue.FindValue('assets') as TJSONArray;
  if JSONArray.Count = 0 then
  begin
    // message
    Exit;
  end;

  // создание списка файлов для закачки; creating files list for downloasd
  for i := 0 to JSONArray.Count -1 do
  begin
    s_temp := JSONArray.Items[i].FindValue('browser_download_url').Value;
    STFilesURL.Add(s_temp);
    Delete(s_temp, 1, LastDelimiter('/', s_temp));
    STFileName.Add(s_temp);
  end;

  s_temp := RESTResponse.JSONValue.FindValue('zipball_url').Value;
  STFilesURL.Add(s_temp);
  Delete(s_temp, 1, LastDelimiter('/', s_temp));
  STFileName.Add('Source code ' + s_temp + '.zip');

  SendMsg(STFileName.Text);

  // Условное скачивание, использование фильтра
  // Conditional download, using a filter
  if FReposRec.RuleDownload = 1 then FiltersExecute;


  // ****** Скачивание файлов из списка; Download files from the list ******

  // подготовка директорнии для скачивания; preparing a directory for download
  if FReposRec.NeedSubDir then
    DownloadDir := FReposRec.ReposDir + '\' + Ftag_name
  else
    DownloadDir := FReposRec.ReposDir;
  if Not DirectoryExists(DownloadDir) then ForceDirectories(DownloadDir);

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

    SavedFileName := STFileName.Strings[i];

    if FReposRec.AddVerToFileName then
      Insert('_' + Ftag_name, SavedFileName, LastDelimiter('.', SavedFileName) -1);

    SavedFileName := DownloadDir + '\' + SavedFileName;

    TFile.WriteAllBytes(SavedFileName, RESTResponse.RawBytes);

    if FileExists(SavedFileName) then
      SendMsg('Файл: ' + SavedFileName + ' был скачан удачно.')
    else
      SendMsg('Ошибка файл: ' + SavedFileName + ' не обнаружен.');
  end;

  Synchronize(SaveReposRec);

  /////////////////////////////////////////////////////////////////////////////

  While true do
  begin
    Sleep(2000);
    SendMsg('ThreadReposCheck.Execute');
  end;

end;

procedure ThreadReposCheck.FiltersExecute;
var
  s_temp: string;
  i, cnt: SmallInt;
  Checked: Boolean;
begin
  // Использую фильтр "Включить"; Use the filter "Include"
  s_temp := StringReplace(FReposRec.FilterInclude, ' ', '', [rfReplaceAll]);
  STFilters.Text := StringReplace(s_temp, ',', #13, [rfReplaceAll]);
  cnt := 0;
  while STFileName.Count <> cnt do
  begin
    Checked := false;
    for i := 0 to STFilters.Count -1 do
      if AnsiPos(STFilters.Strings[i], STFileName.Strings[cnt]) <> 0 then
      begin
        Checked := true;
        Break;
      end;
    if Checked = false then
    begin
      STFileName.Delete(cnt);
      STFilesURL.Delete(cnt);
      Continue;
    end;
    Inc(cnt);
  end;

  // Использую фильтр "Исключить"; Use the filter "Exclude"
  s_temp := StringReplace(FReposRec.FilterExclude, ' ', '', [rfReplaceAll]);
  STFilters.Text := StringReplace(s_temp, ',', #13, [rfReplaceAll]);
  cnt := 0;
  while STFileName.Count <> cnt do
  begin
    Checked := false;
    for i := 0 to STFilters.Count -1 do
      if AnsiPos(STFilters.Strings[i], STFileName.Strings[cnt]) <> 0 then
      begin
        Checked := true;
        Break;
      end;
    if Checked = true then
    begin
      STFileName.Delete(cnt);
      STFilesURL.Delete(cnt);
      Continue;
    end;
    Inc(cnt);
  end;
  // SendMsg(STFileName.Text);
end;

procedure ThreadReposCheck.MemoMessage;
begin
  FrmMain.mmInfo.Lines.Add(FMsg);
end;

procedure ThreadReposCheck.SaveReposRec;
begin
  with arReposList[FReposIndex] do
  begin
    DatePublish  := FDatePublish;
    LastVersion  := FLastVersion;
    NewReleaseDT := FDtNewRelease;
    LastChecked  := Date + Time;
  end;
  //FrmAddRepository.SaveAddedNewRepository(ReposIndex);
end;

procedure ThreadReposCheck.SendMsg(MsgStr: String);
begin
  FMsg := MsgStr;
  Synchronize(MemoMessage);
end;

end.
