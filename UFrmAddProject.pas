unit UFrmAddProject;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, sSkinProvider, Vcl.StdCtrls, sEdit,
  sButton, sGroupBox, sCheckBox, Vcl.Mask, sMaskEdit, sCustomComboEdit,
  sToolEdit, sLabel, Vcl.ComCtrls, sListView, sListBox, System.ImageList,
  Vcl.ImgList, json,System.IOUtils, REST.Types, RESTContentTypeStr, StrUtils,
  Vcl.ExtCtrls, acImage, acPNG, sPanel, System.IniFiles;

type
  TFrmAddProject = class(TForm)
    sSkinProvider: TsSkinProvider;
    sBtnApply: TsButton;
    sLblPojectLink: TsLabel;
    sDirEdSaveDir: TsDirectoryEdit;
    sLblProjectDir: TsLabel;
    sChBoxSubDir: TsCheckBox;
    sRGRulesNotis: TsRadioGroup;
    sRGRuleDownload: TsRadioGroup;
    ImageList: TImageList;
    sEdFilter: TsEdit;
    sLblFilter: TsLabel;
    sEdProjectLink: TsEdit;
    mm: TMemo;
    sImagProject: TsImage;
    sBtnCheck: TsButton;
    sLblAvatar: TsLabel;
    sPnlImage: TsPanel;
    sChBoxDownloadLastRelease: TsCheckBox;
    procedure sBtnApplyClick(Sender: TObject);
    function ConverLinkToApiLink(Link: String): String;
    Procedure AddProjectList;
    procedure FrmShowInit;
    function ExtractProjNameFromLink(URL: String): String;
    function ExcludeTrailingURLDelimiter(URL: String): String;
    function GetImageExtention(ContentType: string): String;
    procedure sEdProjectLinkChange(Sender: TObject);
    procedure sBtnCheckClick(Sender: TObject);
    procedure SaveAddedNewProject(Index: Int16);
  private
    { Private declarations }
    FApiProject         : String;
    FApiReleases        : string;
    FProjectName        : string;
    FAvatar_url         : string;
    FProgectDir         : string;
    FAvatarFileName     : String;
    FAvatarFileNameTemp : String;
    FLastReleaseVersion : String;
    FProjChecked        : Boolean;
    FPublishRelease     : String;
  public
    { Public declarations }
    Applay: Boolean;
  end;

var
  FrmAddProject: TFrmAddProject;
  // ApiProject         : String;
  //ApiReleases        : string;
  //ProjectName        : string;
  //avatar_url         : string;
  //ProgectDir         : string;
  //AvatarFileName     : String;
  //tmpAvatarFileName  : String;
  //LastReleaseVersion : String;

const
   test_url = 'https://github.com/superbot-coder/chia_plotting_tools';
  // 'http://api.github.com/repos/superbot-coder/chia_plotting_tools/releases'

implementation

{$R *.dfm}

Uses UFrmMain;

procedure TFrmAddProject.AddProjectList;
begin
  //
end;

function TFrmAddProject.ConverLinkToApiLink(Link: String): String;
begin
  if Link = '' then Exit;
  if AnsiPos('https://', Link) > 0 then
    Result := StringReplace(Link, 'https://github.com', 'https://api.github.com/repos', [rfIgnoreCase])
  else
    Result := StringReplace(Link, 'github.com', 'https://api.github.com/repos', [rfIgnoreCase]);
  Result := Result;
end;

function TFrmAddProject.ExcludeTrailingURLDelimiter(URL: String): String;
var
  len: Integer;
begin
  if URL = '' then Exit;
  len := Length(URL);
  Result := URL;
  if (URL[len] = '/') or (URL[len] = '\')  then Delete(Result, len, 1);
end;

function TFrmAddProject.ExtractProjNameFromLink(URL: String): String;
var
  x: Word;
begin
  Result := URL;
  x := LastDelimiter('/', Result);
  if x = 0 then
  begin
    Result := '';
    Exit;
  end;
  Result :=  copy(Result, x + 1, Length(Result) - x);
end;

procedure TFrmAddProject.FrmShowInit;
begin
  // init controls
  sEdProjectLink.Text := '';
  //sEdFilter.Text      := '';
  sDirEdSaveDir.Text  := '';
  sBtnApply.Enabled   := False;
  sBtnCheck.Enabled   := True;
  sRGRuleDownload.ItemIndex := 0;
  sRGRulesNotis.ItemIndex   := 0;
  sChBoxSubDir.Checked      := True;
  sChBoxDownloadLastRelease.Checked := false;

  // init values
  Applay             := false;
  FApiProject         := '';
  FApiReleases        := '';
  FProjectName        := '';
  FAvatar_url         := '';
  FProgectDir         := '';
  FAvatarFileName     := '';
  FAvatarFileNameTemp := '';
  FLastReleaseVersion := '';

  ShowModal;
end;

function TFrmAddProject.GetImageExtention(ContentType: string): String;
var
  x: Byte;
begin
  x := AnsiIndexStr(ContentType, arContentTypeStr);
  if x <> -1 then
    case TRESTContentType(X) of
      ctIMAGE_GIF     : Result := '.gif';
      ctIMAGE_JPEG    : Result := '.jpeg';
      ctIMAGE_PJPEG   : Result := '.pjpeg';
      ctIMAGE_PNG     : Result := '.png';
      ctIMAGE_SVG_XML : Result := '.svg';
      ctIMAGE_TIFF    : Result := '.tiff';
      ctIMAGE_X_XCF   : Result := '.xcf';
    end
    else Result := '';
end;

procedure TFrmAddProject.SaveAddedNewProject(Index: Int16);
var
  INI: TIniFile;
begin
  INI := TIniFile.Create('');
  try
    //
  finally
    INI.Free;
  end;
end;

procedure TFrmAddProject.sBtnApplyClick(Sender: TObject);
var
  JSONData : TJSONValue;
  ext      : string;
  x        : SmallInt;
begin

  sBtnCheck.Enabled := false;

  if sEdProjectLink.Text = '' then sEdProjectLink.Text := test_url;

  if sEdProjectLink.Text = '' then
  begin
    MessageBox(Handle, PChar('Введите ссылку на проект'),
               PChar(CAPTION_MB), MB_ICONWARNING);
    Exit;
  end;

  sEdProjectLink.Text := ExcludeTrailingURLDelimiter(Trim(sEdProjectLink.Text));
  FApiProject         := ConverLinkToApiLink(sEdProjectLink.Text);
  FApiReleases         := FApiProject + '/releases';

  with FrmMain do
  begin

    // проверка правильная ссылки; Check Existes the project
    RESTResponse.RootElement := '';
    RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
    RESTClient.BaseURL       := FApiProject;
    RESTRequest.Execute;

    if RESTResponse.StatusCode <> 200 then
    begin
      MessageBox(Handle, PChar('Ошибка: ' + RESTResponse.StatusText +
                 ' код: ' + IntToStr(RESTResponse.StatusCode)),
                 PChar(CAPTION_MB), MB_ICONERROR);
      exit;
    end;

    // Получаю имя проекта; Getting name the project
    FProjectName := ExtractProjNameFromLink(sEdProjectLink.Text);
    mm.Lines.Add('Название проекта: ' + FProjectName);

    // Проверяю, что объект JSON создан; Checking that the JSON object is created
    if RESTResponse.JSONValue = Nil then
    begin
      // ошибка; error ...
      MessageBox(Handle, PChar('Ошибка: RESTResponse.JSONValue = Nil'),
                 PChar(CAPTION_MB), MB_ICONERROR);
      Exit;
    end;

    // Получаю путь аватарки проекта; Getting the avatar path of the project
    JSONData := RESTResponse.JSONValue.FindValue('owner').FindValue('avatar_url');
    if JSONData <> Nil then FAvatar_url := JSONData.Value;

    // Скачиваю файл аватарки; Downloading avatarka file
    RESTClient.BaseURL       := FAvatar_url;
    RESTClient.Accept        := '';
    RESTResponse.RootElement := '';
    RESTRequest.Execute;

    if RESTResponse.StatusCode = 200 then // 'StatusCode = 200 OK.
    begin
      // получаю расширение и тип картинки; getting extension and image(avatar) type
      ext := GetImageExtention(RESTResponse.ContentType);

      // Временно скачиваю аватарку в "TEMP"; Temporarily download the avatark to "TEMP"
      FAvatarFileNameTemp := TEMP + '\' + 'Avatar_' + FProjectName + ext;
      TFile.WriteAllBytes(FAvatarFileNameTemp, RESTResponse.RawBytes);
      sImagProject.Picture.LoadFromFile(FAvatarFileNameTemp);

    end;

    // Проверяю существуют ли релизы; Checking if releases exist
    // Поучаю самую последнюю версию релиза; I'll get the latest release
    RESTClient.BaseURL       := FApiReleases;
    RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
    RESTResponse.RootElement := '[0]';
    RESTRequest.Execute;

    If RESTResponse.StatusCode <> 200 then
    begin
      mm.Lines.Add('Ошибка: StatusCode: ' + IntToStr(RESTResponse.StatusCode) +
                   ' ' + RESTResponse.StatusText);
      Exit;
    end;

    if RESTResponse.JSONValue = Nil then
    begin
      mm.Lines.Add('Не найдено ни одного опубликованого релиза.');
      mm.Lines.Add('Проверка выполнена.');
      MessageBox(Handle, PChar(mm.Lines.Text),
                PChar(CAPTION_MB), MB_ICONINFORMATION);
    end;

    if RESTResponse.JSONValue.FindValue('tag_name') <> nil then
    begin
      mm.Lines.Add('Имя релиза: ' + RESTResponse.JSONValue.FindValue('name').Value);
      FLastReleaseVersion := RESTResponse.JSONValue.FindValue('tag_name').Value;
      FPublishRelease     := RESTResponse.JSONValue.FindValue('published_at').Value;
      mm.Lines.Add('Дата публикации последнего релиза: ' + FPublishRelease);
      mm.Lines.Add('Версия последнего релиза: ' + FLastReleaseVersion);
      mm.Lines.Add('Проверка выполнена.');
      MessageBox(Handle, PChar(mm.Lines.Text),
                 PChar(CAPTION_MB), MB_ICONINFORMATION);
    end;
  end;


 {------------------------------------------------------}

  if sDirEdSaveDir.Text <> '' then
    FProgectDir := sDirEdSaveDir.Text
  else
    FProgectDir := GLProjectsPath + FProjectName;

  if Not DirectoryExists(FProgectDir) then ForceDirectories(FProgectDir);
  FAvatarFileName := FProgectDir + '\Avatar' + FProjectName + ext;

  if FileExists(FAvatarFileNameTemp) then
    CopyFile(Pchar(FAvatarFileNameTemp), PChar(FAvatarFileName), false);
  DeleteFile(FAvatarFileNameTemp);

  // Добавляю новую запись в массив arProjectList
  // Adding a new entry to the array arProjectList
  SetLength(arProjectList, Length(arProjectList) + 1);
  with arProjectList[Length(arProjectList) - 1] do
  begin
    ProjLink     := sEdProjectLink.Text;
    ApiProjLink  := FApiProject;
    ProjName     := FProjectName;
    Filters      := sEdFilter.Text;
    DatePublish  := FPublishRelease;
    LastVersion  := FLastReleaseVersion;
    RuleDownload := sRGRuleDownload.ItemIndex;
    RuleNotis    := sRGRulesNotis.ItemIndex;
  end;



  Applay := true;
  sBtnApply.Enabled := false;
  // Close;
end;

procedure TFrmAddProject.sBtnCheckClick(Sender: TObject);
var
  JSONData : TJSONValue;
  ext      : string;
  x        : SmallInt;
begin

  sBtnCheck.Enabled := false;

  if sEdProjectLink.Text = '' then sEdProjectLink.Text := test_url;

  if sEdProjectLink.Text = '' then
  begin
    MessageBox(Handle, PChar('Введите ссылку на проект'),
               PChar(CAPTION_MB), MB_ICONWARNING);
    Exit;
  end;

  sEdProjectLink.Text := ExcludeTrailingURLDelimiter(Trim(sEdProjectLink.Text));
  FApiProject         := ConverLinkToApiLink(sEdProjectLink.Text);
  FApiReleases         := FApiProject + '/releases';

  with FrmMain do
  begin

    // проверка правильная ссылки; Check Existes the project
    RESTResponse.RootElement := '';
    RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
    RESTClient.BaseURL       := FApiProject;
    RESTRequest.Execute;

    if RESTResponse.StatusCode <> 200 then
    begin
      MessageBox(Handle, PChar('Ошибка: ' + RESTResponse.StatusText +
                 ' код: ' + IntToStr(RESTResponse.StatusCode)),
                 PChar(CAPTION_MB), MB_ICONERROR);
      exit;
    end;

    // Получаю имя проекта; Getting name the project
    FProjectName := ExtractProjNameFromLink(sEdProjectLink.Text);
    mm.Lines.Add('Название проекта: ' + FProjectName);

    // Проверяю, что объект JSON создан; Checking that the JSON object is created
    if RESTResponse.JSONValue = Nil then
    begin
      // ошибка; error ...
      MessageBox(Handle, PChar('Ошибка: RESTResponse.JSONValue = Nil'),
                 PChar(CAPTION_MB), MB_ICONERROR);
      Exit;
    end;

    // Получаю путь аватарки проекта; Getting the avatar path of the project
    JSONData := RESTResponse.JSONValue.FindValue('owner').FindValue('avatar_url');
    if JSONData <> Nil then FAvatar_url := JSONData.Value;

    // Скачиваю файл аватарки; Downloading avatarka file
    RESTClient.BaseURL       := FAvatar_url;
    RESTClient.Accept        := '';
    RESTResponse.RootElement := '';
    RESTRequest.Execute;

    if RESTResponse.StatusCode = 200 then // 'StatusCode = 200 OK.
    begin
      // получаю расширение и тип картинки; getting extension and image(avatar) type
      ext := GetImageExtention(RESTResponse.ContentType);

      // Временно скачиваю аватарку в "TEMP"; Temporarily download the avatark to "TEMP"
      FAvatarFileNameTemp := TEMP + '\' + 'Avatar_' + FProjectName + ext;
      TFile.WriteAllBytes(FAvatarFileNameTemp, RESTResponse.RawBytes);
      sImagProject.Picture.LoadFromFile(FAvatarFileNameTemp);

    end;

    // Проверяю существуют ли релизы; Checking if releases exist
    // Поучаю самую последнюю версию релиза; I'll get the latest release
    RESTClient.BaseURL       := FApiReleases;
    RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
    RESTResponse.RootElement := '[0]';
    RESTRequest.Execute;

    If RESTResponse.StatusCode <> 200 then
    begin
      mm.Lines.Add('Ошибка: StatusCode: ' + IntToStr(RESTResponse.StatusCode) +
                   ' ' + RESTResponse.StatusText);
      Exit;
    end;

    if RESTResponse.JSONValue = Nil then
    begin
      mm.Lines.Add('Не найдено ни одного опубликованого релиза.');
      mm.Lines.Add('Проверка выполнена.');
      MessageBox(Handle, PChar(mm.Lines.Text),
                PChar(CAPTION_MB), MB_ICONINFORMATION);
    end;

    if RESTResponse.JSONValue.FindValue('tag_name') <> nil then
    begin
      mm.Lines.Add('Имя релиза: ' + RESTResponse.JSONValue.FindValue('name').Value);
      FLastReleaseVersion := RESTResponse.JSONValue.FindValue('tag_name').Value;
      FPublishRelease     := RESTResponse.JSONValue.FindValue('published_at').Value;
      mm.Lines.Add('Дата публикации последнего релиза: ' + FPublishRelease);
      mm.Lines.Add('Версия последнего релиза: ' + FLastReleaseVersion);
      mm.Lines.Add('Проверка выполнена.');
      MessageBox(Handle, PChar(mm.Lines.Text),
                 PChar(CAPTION_MB), MB_ICONINFORMATION);
    end;
  end;

  sBtnApply.Enabled := true;
  sBtnCheck.Enabled := true;

end;

procedure TFrmAddProject.sEdProjectLinkChange(Sender: TObject);
begin
  sBtnApply.Enabled := true;
end;

end.
