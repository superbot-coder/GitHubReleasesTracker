unit UFrmAddProject;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ComCtrls, System.ImageList, Vcl.ImgList, json, System.IOUtils,
  REST.Types, RESTContentTypeStr, StrUtils,
  Vcl.ExtCtrls, System.IniFiles, Vcl.Buttons, Vcl.FileCtrl;

type TFrmShowMode = (fsmAddNew, fsmEdit);

type
  TFrmAddProject = class(TForm)
    edProjectLink: TEdit;
    LblUrlProject: TLabel;
    statTextProjectDir: TStaticText;
    ChBoxSubDir: TCheckBox;
    ChBoxDownloadLastRelease: TCheckBox;
    mm: TMemo;
    Panel: TPanel;
    ImagProject: TImage;
    LblAvatar: TLabel;
    BtnApply: TButton;
    SpdBtnOpenDir: TSpeedButton;
    edSaveDir: TEdit;
    RGRulesNotis: TRadioGroup;
    RGRuleDownload: TRadioGroup;
    GrBoxFilter: TGroupBox;
    EdFilterInclude: TEdit;
    edFilterExclude: TEdit;
    LblExclude: TLabel;
    LblInclude: TLabel;
    BtnClose: TButton;
    procedure BtnApplyClick(Sender: TObject);
    function ConverLinkToApiLink(Link: String): String;
    Procedure AddProjectList;
    procedure FrmShowInit;
    function ExtractProjNameFromLink(URL: String): String;
    function ExcludeTrailingURLDelimiter(URL: String): String;
    function GetImageExtention(ContentType: string): String;
    procedure edProjectLinkChange(Sender: TObject);
    procedure SaveAddedNewProject(Index: Integer);
    function CheckProjectExistes(URL: String): boolean;
    procedure SpdBtnOpenDirClick(Sender: TObject);
    procedure FormShowEdit(ProjectIndex: integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnCloseClick(Sender: TObject);
  private
    { Private declarations }
    FApiProject         : string;
    FApiReleases        : string;
    FProjectName        : string;
    FFullName           : string;
    FAvatar_url         : string;
    FProgectDir         : string;
    FAvatarFileName     : string;
    FLastReleaseVersion : string;
    FProjChecked        : Boolean;
    FPublishRelease     : string;
    FLanguage           : string;
    FProjectIndex       : Integer;
    FFrmMode            : TFrmShowMode;
  public
    { Public declarations }
    Applay: Boolean;
  end;

var
  FrmAddProject: TFrmAddProject;

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

function TFrmAddProject.CheckProjectExistes(URL: String): boolean;
var i: SmallInt;
begin
  Result := False;
  for i := 0 to Length(arProjectList)-1 do
  begin
    if arProjectList[i].ProjectUrl = URL then
    begin
      Result := true;
      exit;
    end;
  end;
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

procedure TFrmAddProject.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then Close;
end;

procedure TFrmAddProject.FormShowEdit(ProjectIndex: integer);
begin
  FProjectIndex := ProjectIndex;
  FFrmMode      := fsmEdit;
  edProjectLink.Enabled := false;
  edProjectLink.Text    := arProjectList[ProjectIndex].ProjectUrl;
  edSaveDir.Text        := arProjectList[ProjectIndex].ProjectDir;
  ChBoxSubDir.Checked   := arProjectList[ProjectIndex].NeedSubDir;
  RGRuleDownload.ItemIndex := arProjectList[ProjectIndex].RuleDownload;
  RGRulesNotis.ItemIndex   := arProjectList[ProjectIndex].RuleNotis;
  EdFilterInclude.Text     := arProjectList[ProjectIndex].FilterInclude;
  edFilterExclude.Text     := arProjectList[ProjectIndex].FilterExclude;
  ChBoxDownloadLastRelease.Enabled := False;
  BtnApply.Caption         := 'С О Х Р А Н И Т Ь';
  if FileExists(arProjectList[ProjectIndex].AvatarFile) then
    ImagProject.Picture.LoadFromFile(arProjectList[ProjectIndex].AvatarFile);

  ShowModal;
end;

procedure TFrmAddProject.FrmShowInit;
begin
  // init controls
  FFrmMode              := fsmAddNew;
  edProjectLink.Text    := '';
  edProjectLink.Enabled := true;
  edSaveDir.Text        := '';
  BtnApply.Enabled      := False;
  BtnApply.Caption      := 'Д О Б А В И Т Ь';
  ChBoxSubDir.Checked   := True;
  ImagProject.Picture   := Nil;
  RGRuleDownload.ItemIndex := 0;
  RGRulesNotis.ItemIndex   := 0;
  ChBoxDownloadLastRelease.Checked := false;
  ChBoxDownloadLastRelease.Enabled := True;
  EdFilterInclude.Text := 'windows, win, win64, 64bit';
  edFilterExclude.Text := 'mac, linux, 32bit';

  mm.Clear;

  // init values
  Applay              := false;
  FApiProject         := '';
  FProgectDir         := '';
  FApiReleases        := '';
  FProjectName        := '';
  FFullName           := '';
  FAvatar_url         := '';
  FAvatarFileName     := '';
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

procedure TFrmAddProject.SaveAddedNewProject(Index: Integer);
var
  INI: TIniFile;
  Section: string;
begin

  if Not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  Section := 'PROJECT_LIST\'+ StringReplace(arProjectList[Index].FullProjectName, '/', '_', [rfReplaceAll]);

  INI := TIniFile.Create(FileConfig);
  try
    with INI do
    begin
      WriteString(Section, 'ProjectUrl', arProjectList[Index].ProjectUrl);
      WriteString(Section, 'ProjectDir', arProjectList[Index].ProjectDir);
      WriteString(Section, 'ApiProjUrl', arProjectList[Index].ApiProjectUrl);
      WriteString(Section, 'ApiReleasesUrl', arProjectList[Index].ApiReleasesUrl);
      WriteString(Section, 'ProjectName', arProjectList[Index].ProjectName);
      WriteString(Section, 'FullProjectName', arProjectList[Index].FullProjectName);
      WriteString(Section, 'AvatarFile', arProjectList[Index].AvatarFile);
      WriteString(Section, 'AvatarUrl',arProjectList[Index].AvatarUrl );
      WriteString(Section, 'FilterInclude', arProjectList[Index].FilterInclude);
      WriteString(Section, 'FilterExclude', arProjectList[Index].FilterExclude);
      WriteString(Section, 'DatePublish', arProjectList[Index].DatePublish);
      WriteString(Section, 'Language', arProjectList[Index].Language);
      WriteString(Section, 'LastVersion', arProjectList[Index].LastVersion);
      WriteDateTime(Section, 'LastChecked', arProjectList[Index].LastChecked);
      WriteInteger(Section, 'RuleDownload', arProjectList[Index].RuleDownload);
      WriteInteger(Section, 'RuleNotis', arProjectList[Index].RuleNotis);
      WriteBool(Section, 'NeedSubDir', arProjectList[Index].NeedSubDir);
      WriteDateTime(Section, 'NewReleaseDT', arProjectList[Index].NewReleaseDT);
    end;
  finally
    INI.Free;
  end;
end;

procedure TFrmAddProject.SpdBtnOpenDirClick(Sender: TObject);
var
  SelDir: String;
begin
  SelectDirectory('Выберите каталог', '', SelDir);
  edSaveDir.Text := SelDir;
end;

procedure TFrmAddProject.BtnApplyClick(Sender: TObject);
var
  JSONData : TJSONValue;
  ext      : string;
  x        : SmallInt;
begin

  if FFrmMode = fsmEdit then
  begin
    with arProjectList[FProjectIndex] do
    begin
      ProjectDir    := edSaveDir.Text;
      NeedSubDir    := ChBoxSubDir.Checked;
      RuleDownload  := RGRuleDownload.ItemIndex;
      RuleNotis     := RGRulesNotis.ItemIndex;
      FilterInclude := EdFilterInclude.Text;
      FilterExclude := edFilterExclude.Text;
    end;
    SaveAddedNewProject(FProjectIndex);
  end;

  if FFrmMode = fsmAddNew then
  begin
    BtnApply.Enabled := false;
    if edProjectLink.Text = '' then edProjectLink.Text := test_url;

    if edProjectLink.Text = '' then
    begin
      MessageBox(Handle, PChar('Введите ссылку на проект'),
               PChar(CAPTION_MB), MB_ICONWARNING);
      Exit;
    end;

    if Not AnsiContainsStr(AnsiLowerCase(edProjectLink.Text), 'https://') then
      edProjectLink.Text := 'https://' + edProjectLink.Text;

    // Проверяю что проект уже добавлен в список
    // Checking that the project has already been added to the list
    if CheckProjectExistes(edProjectLink.Text) then
    begin
      MessageBox(Handle, PChar('Такой проек уже добавлен в список..'),
                 PChar(CAPTION_MB), MB_ICONWARNING);
      Exit;
    end;

    edProjectLink.Text := ExcludeTrailingURLDelimiter(Trim(edProjectLink.Text));
    FApiProject         := ConverLinkToApiLink(edProjectLink.Text);
    FApiReleases        := FApiProject + '/releases';

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

      if RESTResponse.JSONValue.FindValue('name') = Nil then
      begin
        //
        Exit;
      end;
      // Получаю имя проекта; Getting name the project
      FProjectName := RESTResponse.JSONValue.FindValue('name').Value;

      if RESTResponse.JSONValue.FindValue('full_name') = Nil then
      begin
        //
        Exit;
      end;
      // Получаю полное имя проекта; Getting full name the project
      FFullName := RESTResponse.JSONValue.FindValue('full_name').Value;
      // Заменяю символ "/" на "_" ;
      mm.Lines.Add('Название проекта: ' + FProjectName);

      // Получаю URL аватарки проекта; Getting the avatar URL of the project
      JSONData := RESTResponse.JSONValue.FindValue('owner').FindValue('avatar_url');
      if JSONData <> Nil then FAvatar_url := JSONData.Value;

      // получаю язык программирования проекта; getting the project programming language
      FLanguage := RESTResponse.JSONValue.FindValue('language').Value;

      // Получаю директорию проекта; Getting the project directory
      if edSaveDir.Text <> '' then
        FProgectDir := edSaveDir.Text
      else
        FProgectDir := GLProjectsDir + PathDelim +  StringReplace(FFullName, '/', '_', [rfReplaceAll, rfIgnoreCase]);
      if Not DirectoryExists(FProgectDir) then ForceDirectories(FProgectDir);

      // Скачиваю файл аватарки; Downloading avatarka file
      RESTClient.BaseURL       := FAvatar_url;
      RESTClient.Accept        := '';
      RESTResponse.RootElement := '';
      RESTRequest.Execute;

      if RESTResponse.StatusCode = 200 then // 'StatusCode = 200 OK.
      begin
        // получаю расширение и тип картинки; getting extension and image(avatar) type
        ext := GetImageExtention(RESTResponse.ContentType);
        // Пoлучаю имя файла для сохранения аватарки
        // Getting the file name to save the avatar
        FAvatarFileName := FProgectDir + '\Avatar' + ext;
        TFile.WriteAllBytes(FAvatarFileName, RESTResponse.RawBytes);
        ImagProject.Picture.LoadFromFile(FAvatarFileName);
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
        mm.Lines.Add('Имя релиза: ' + FProjectName);
        FLastReleaseVersion := RESTResponse.JSONValue.FindValue('tag_name').Value;
        FPublishRelease     := RESTResponse.JSONValue.FindValue('published_at').Value;
        FPublishRelease     := ConvertGitHubDateToDateTime(FPublishRelease);
        mm.Lines.Add('Дата публикации последнего релиза: ' + FPublishRelease);
        mm.Lines.Add('Версия последнего релиза: ' + FLastReleaseVersion);
        mm.Lines.Add('Проверка выполнена.');
        MessageBox(Handle, PChar(mm.Lines.Text), PChar(CAPTION_MB), MB_ICONINFORMATION);
      end;
    end;

    // Добавляю новую запись в массив arProjectList
    // Adding a new entry to the array arProjectList
    SetLength(arProjectList, Length(arProjectList) + 1);
    with arProjectList[Length(arProjectList) - 1] do
    begin
      ProjectUrl      := edProjectLink.Text;
      ProjectDir      := FProgectDir;
      ApiProjectUrl   := FApiProject;
      ApiReleasesUrl  := FApiReleases;
      ProjectName     := FProjectName;
      FullProjectName := FFullName;
      AvatarFile      := FAvatarFileName;
      AvatarUrl       := FAvatar_url;
      FilterInclude   := EdFilterInclude.Text;
      FilterExclude   := edFilterExclude.Text;
      DatePublish     := FPublishRelease;
      Language        := FLanguage;
      LastVersion     := FLastReleaseVersion;
      LastChecked     := Date + Time;
      RuleDownload    := RGRuleDownload.ItemIndex;
      RuleNotis       := RGRulesNotis.ItemIndex;
      NewReleaseDT    := Date + Time;
    end;

    SaveAddedNewProject(Length(arProjectList) - 1);

    Applay := true;
    BtnApply.Enabled := true;
  end;

  Close;
end;

procedure TFrmAddProject.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmAddProject.edProjectLinkChange(Sender: TObject);
begin
  BtnApply.Enabled := true;
end;

end.
