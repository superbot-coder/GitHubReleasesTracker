unit UFrmDownloadFiles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.JumpList, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.JSON, REST.Types ,RESTContentTypeStr, System.ImageList,
  Vcl.ImgList, FormatFileSizeMod, System.StrUtils, System.IOUtils, System.IniFiles,
  Vcl.Menus;

type
  TFrmDownloadFiles = class(TForm)
    LVFiles: TListView;
    BtnApply: TButton;
    BtnClose: TButton;
    PnlBoard: TPanel;
    ImageList: TImageList;
    EdFilterInclude: TEdit;
    EdFilterExclude: TEdit;
    LblFilterInclude: TLabel;
    LblFilterExclude: TLabel;
    BtnApplyFilter: TButton;
    BtnSaveFilter: TButton;
    PopupMenu: TPopupMenu;
    PM_CheckedAllFiles: TMenuItem;
    PM_DownCheckAllFiles: TMenuItem;
    mmBody: TMemo;
    PnlInfo: TPanel;
    PnlFilesList: TPanel;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure ShowInit(JSONData: TJSONValue; ProjectIndex: Integer; Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnApplyFilterClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSaveFilterClick(Sender: TObject);
    procedure PM_CheckedAllFilesClick(Sender: TObject);
    procedure PM_DownCheckAllFilesClick(Sender: TObject);
  private
    { Private declarations }
    STDownloadFiles : TStrings;
    FReposIndex     : Integer;
    Ftag_name       : string;
    FMainUpdate     : Boolean;
    procedure ExecutFilters;
    Function AddLVItem: integer;
  public
    { Public declarations }
  end;

var
  FrmDownloadFiles: TFrmDownloadFiles;

const
  MainUpdateReleaseURL = 'https://api.github.com/repos/superbot-coder/GitHubReleasesTracker/releases';
  //MainUpdateReleaseURL = 'https://api.github.com/repos/xmrig/xmrig/releases'; // for test

implementation

USES UFrmMain;

{$R *.dfm}

function TFrmDownloadFiles.AddLVItem: integer;
begin
  With LVFiles.Items.Add do
  begin
    Result := index;
    SubItems.Add('');
    SubItems.Add('');
    ImageIndex := 0;
  end;
end;

procedure TFrmDownloadFiles.BtnApplyClick(Sender: TObject);
var
  i: Word;
  SavedFileName: string;
  DownloadDir: string;
begin

  // подготовка директорнии для скачивания; preparing a directory for download
  if FMainUpdate then
    DownloadDir := GLDefReposDir
  else
    if arReposList[FReposIndex].NeedSubDir then
      DownloadDir := arReposList[FReposIndex].ReposDir + '\' + Ftag_name
    else
      DownloadDir := arReposList[FReposIndex].ReposDir;

  if Not DirectoryExists(DownloadDir) then ForceDirectories(DownloadDir);

  for i := 0 to LVFiles.Items.Count -1 do
  begin
    if Not LVFiles.Items[i].Checked then Continue;
    LVFiles.Items[i].Selected := true;

    // Получаю финальное имя файла
    SavedFileName := LVFiles.Items[i].Caption;
    if Not FMainUpdate then
      if arReposList[FReposIndex].AddVerToFileName then
        insert('_' + Ftag_name, SavedFileName, LastDelimiter('.', SavedFileName)-1);

    SavedFileName := DownloadDir + '\' + SavedFileName;

    // Загружаю файл с GitHub
    with FrmMain do begin
      RESTResponse.RootElement := '';
      RESTClient.Accept        := 'application'; //'application/zip';
      RESTClient.BaseURL       := STDownloadFiles.Strings[i];
      RESTRequest.Execute;
      if RESTResponse.StatusCode <> 200 then
      begin
        LVRepos.Items[i].SubItems[1] := 'Ошибка';
        Continue;
      end;
    end;

    // Сохраняю загруженный файл
    TFile.WriteAllBytes(SavedFileName, FrmMain.RESTResponse.RawBytes);
    If FileExists(SavedFileName) then LVFiles.Items[i].SubItems[1] := 'Скачано';
    Application.ProcessMessages;
  end;

  MessageBox(Handle, PChar('Закачка файлов завершена.'),
             PChar(CAPTION_MB), MB_ICONINFORMATION);
end;

procedure TFrmDownloadFiles.BtnApplyFilterClick(Sender: TObject);
begin
  ExecutFilters;
end;

procedure TFrmDownloadFiles.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmDownloadFiles.BtnSaveFilterClick(Sender: TObject);
var
  INI: TIniFile;
  Section: string;
begin
  if EdFilterInclude.Modified or EdFilterExclude.Modified then
  begin
    arReposList[FReposIndex].FilterInclude := EdFilterInclude.Text;
    arReposList[FReposIndex].FilterExclude := EdFilterExclude.Text;
    Section := 'PROJECT_LIST\' +
               StringReplace(arReposList[FReposIndex].FullReposName, '/', '_' , []);
    INI := TIniFile.Create(FileConfig);
    try
      INI.WriteString(Section, 'FilterInclude', EdFilterInclude.Text);
      INI.WriteString(Section, 'FilterExclude', EdFilterExclude.Text);
    finally
      INI.Free;
    end;
  end;
end;

procedure TFrmDownloadFiles.ExecutFilters;
var
  STFilterInclude: TStrings;
  STFilterExclude: TStrings;
  s_temp : string;
  i, j: Word;
begin
  STFilterInclude := TStringList.Create;
  STFilterExclude := TStringList.Create;

  //  подготавливаю список фильтка "Include"
  if EdFilterInclude.Modified then
    s_temp := AnsiLowerCase(EdFilterInclude.Text)
  else
    s_temp := AnsiLowerCase(arReposList[FReposIndex].FilterInclude);
  s_temp := StringReplace(s_temp, ' ', '', [rfReplaceAll]);
  s_temp := StringReplace(s_temp, ',', #13, [rfReplaceAll]);
  STFilterInclude.Text := s_temp;

  //  подготавливаю список фильтка "Exclude"
  if EdFilterExclude.Modified then
    s_temp := AnsiLowerCase(EdFilterExclude.Text)
  else
    s_temp := AnsiLowerCase(arReposList[FReposIndex].FilterExclude);
  s_temp := StringReplace(s_temp, ' ', '', [rfReplaceAll]);
  s_temp := StringReplace(s_temp, ',', #13, [rfReplaceAll]);
  STFilterExclude.Text := s_temp;

  try
    for i:=0 to LVFiles.Items.Count -1 do
    begin
      LVFiles.Items[i].Checked := false;

      for j := 0 to STFilterInclude.Count -1 do
        if AnsiContainsStr(LVFiles.Items[i].Caption, STFilterInclude.Strings[j]) then
        begin
          LVFiles.Items[i].Checked := true;
          Break;
        end;

      for j := 0 to STFilterExclude.Count -1 do
        if AnsiContainsStr(LVFiles.Items[i].Caption, STFilterExclude.Strings[j]) then
        begin
          LVFiles.Items[i].Checked := false;
          Break;
        end;
    end;

  finally
    STFilterInclude.Free;
    STFilterExclude.Free;
  end;
end;

procedure TFrmDownloadFiles.FormCreate(Sender: TObject);
begin
  EdFilterInclude.MaxLength := 500;
  EdFilterExclude.MaxLength := 500;
  STDownloadFiles := TStringList.Create;
end;

procedure TFrmDownloadFiles.FormDestroy(Sender: TObject);
begin
  STDownloadFiles.Free;
end;

procedure TFrmDownloadFiles.PM_CheckedAllFilesClick(Sender: TObject);
var i: Word;
begin
  for i := 0 to LVFiles.Items.Count -1 do LVFiles.Items[i].Checked := true;
end;

procedure TFrmDownloadFiles.PM_DownCheckAllFilesClick(Sender: TObject);
var i: Word;
begin
  for i := 0 to LVFiles.Items.Count -1 do LVFiles.Items[i].Checked := false;
end;

procedure TFrmDownloadFiles.ShowInit(JSONData: TJSONValue; ProjectIndex: Integer; Sender: TObject);
var
  JSONArray: TJSONArray;
  i, x: Word;
  FileName: string;
  sz : string;
begin
  STDownloadFiles.Clear;
  LVFiles.Clear;
  (****************************************************************************
    Этот блок кода отвечает за проверку обновления нового релиза
    самой программы автора
  ****************************************************************************)
  if Sender <> Nil then
  begin
    if Sender.ClassType = TMenuItem then
      if (Sender as TMenuItem).Name = 'MM_CheckMainUpdate' then
      begin
        FMainUpdate         := true;
        Height              := 580;
        PnlFilesList.Height := 160;
        PnlInfo.Visible     := true;
        PnlBoard.Visible    := false;
        with FrmMain do
        begin
          RESTClient.BaseURL       := MainUpdateReleaseURL;
          RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
          RESTResponse.RootElement := '[0]';
          RESTRequest.Execute;
          if RESTResponse.StatusCode <> 200 then
          begin
            // msg ...
            Exit;
          end;
          if RESTResponse.JSONValue = Nil then
          begin
            MessageBox(Handle, PChar('Не обнаружено ни одного релиза программы.'),
                       PChar(CAPTION_MB), MB_ICONINFORMATION);
            Exit;
          end;
          JSONData  := RESTResponse.JSONValue;
          Ftag_name := JSONData.FindValue('tag_name').Value;

          (*
            Алгоритм проверки текущей версии программы и версии полученого релиза
            Пока не реализовано..
            If <current version> = Ftag_name then
            begin
              MessageBox(Handle, PChar('У вас самая актульная версия программы.'),
                         PChar(CAPTION_MB), MB_ICONINFORMATION);
            end;
          *)

          mmBody.Lines.Add('Обнаружена новая версия: ' + Ftag_name);
          mmBody.Lines.Add(JSONData.FindValue('body').Value);
          JSONArray   := JSONData.FindValue('assets') as TJSONArray;
          for i := 0 to JSONArray.Count -1 do
          begin
            if JSONArray.Items[i].FindValue('browser_download_url') <> Nil then
            begin
              x := AddLVItem;
              FileName := JSONArray.Items[i].FindValue('browser_download_url').Value;
              STDownloadFiles.Add(FileName);
              Delete(FileName, 1, LastDelimiter('/', FileName));
              LVFiles.Items[x].Caption     := FileName;
              sz := JSONArray.Items[i].FindValue('size').Value;
              LVFiles.Items[x].SubItems[0] := FormatFileSize(StrToFloat(sz));
              LVFiles.Items[x].Checked     := true;
            end;
          end;

          x := AddLVItem;
          FileName := JSONData.FindValue('zipball_url').Value;
          STDownloadFiles.Add(FileName);
          Delete(FileName, 1, LastDelimiter('/', FileName));
          LVFiles.Items[x].Caption    := 'Source code ' + FileName + '.zip';
          LVFiles.Items[x].ImageIndex := 1;
          LVFiles.Items[x].Checked    := true;

          (*
            Отключил этот тип файлов. Возникает ошибка при закачке файла
            "REST request filed: No mapping for the Unicode character existes
            in then target multi-byte code page."

          x := AddLVItem;
          FileName := JSONData.FindValue('tarball_url').Value;
          STDownloadFiles.Add(FileName);
          Delete(FileName, 1, LastDelimiter('/', FileName));
          LVFiles.Items[x].Caption := 'Source code ' + FileName + '.tar.gz';;
          LVFiles.Items[x].ImageIndex := 1;
          LVFiles.Items[x].Checked    := true;
          *)

        end;
        ShowModal;
        Exit;
      end;
  end;

  (*****************************************************************************
    Этот блок кода отвечает за скачивание файлов релизов
    всех остальных репозиториев
  *****************************************************************************)
  FMainUpdate          := false;
  Height               := 480;
  PnlBoard.Visible     := true;
  PnlInfo.Visible      := false;
  PnlFilesList.Height  := 310;
  FReposIndex          := ProjectIndex;
  EdFilterInclude.Text := arReposList[ProjectIndex].FilterInclude;
  EdFilterExclude.Text := arReposList[ProjectIndex].FilterExclude;

  if JSONData = Nil then
  begin
    with FrmMain do
    begin
      RESTClient.BaseURL       := arReposList[ProjectIndex].ApiReleasesUrl;
      RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
      RESTResponse.RootElement := '[0]';
      RESTRequest.Execute;
      if RESTResponse.StatusCode <> 200 then Exit;
      JSONData := RESTResponse.JSONValue;
    end;
  end;

  if JSONData = Nil then
  begin
    MessageBox(Handle, PChar('Репозиторий: ' +
                             arReposList[ProjectIndex].ReposName + #13#10 +
                             'Не найдено ни одного релиза'),
               PChar(CAPTION_MB), MB_ICONINFORMATION);
    Exit;
  end;

  Ftag_name   := JSONData.FindValue('tag_name').Value;
  if JSONData.FindValue('assets') <> Nil then
  begin;
    JSONArray := JSONData.FindValue('assets') as TJSONArray;
    for i := 0 to JSONArray.Count -1 do
    begin
      if JSONArray.Items[i].FindValue('browser_download_url') <> Nil then
      begin
        x := AddLVItem;
        FileName := JSONArray.Items[i].FindValue('browser_download_url').Value;
        STDownloadFiles.Add(FileName);
        Delete(FileName, 1, LastDelimiter('/', FileName));
        LVFiles.Items[x].Caption     := FileName;
        sz := JSONArray.Items[i].FindValue('size').Value;
        LVFiles.Items[x].SubItems[0] := FormatFileSize(StrToFloat(sz));
        LVFiles.Items[x].Checked     := true;
      end;
    end;
  end;

  x := AddLVItem;
  FileName := JSONData.FindValue('zipball_url').Value;
  STDownloadFiles.Add(FileName);
  Delete(FileName, 1, LastDelimiter('/', FileName));
  LVFiles.Items[x].Caption    := 'Source code ' + FileName + '.zip';
  LVFiles.Items[x].ImageIndex := 1;
  LVFiles.Items[x].Checked    := true;

 (*
   Отключил этот тип файлов. Возникает ошибка при закачке файла
   "REST request filed: No mapping for the Unicode character existes
                        in then target multi-byte code page."

  x := AddLVItem;
  FileName := JSONData.FindValue('tarball_url').Value;
  STDownloadFiles.Add(FileName);
  Delete(FileName, 1, LastDelimiter('/', FileName));
  LVFiles.Items[x].Caption := 'Source code ' + FileName + '.tar.gz';;
  LVFiles.Items[x].ImageIndex := 1;
  LVFiles.Items[x].Checked    := true;
  *)

  if arReposList[FReposIndex].RuleDownload = 1 then ExecutFilters;
  ShowModal;
end;

end.
