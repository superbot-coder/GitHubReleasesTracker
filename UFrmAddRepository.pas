unit UFrmAddRepository;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ComCtrls, System.ImageList, Vcl.ImgList, json, System.IOUtils,
  REST.Types, RESTContentTypeStr, StrUtils,
  Vcl.ExtCtrls, System.IniFiles, Vcl.Buttons, Vcl.FileCtrl, Vcl.Samples.Spin;

type TFrmShowMode = (fsmAddNew, fsmEdit);

type
  TFrmAddRepository = class(TForm)
    edRepositoryLink: TEdit;
    LblUrlRepository: TLabel;
    statTextReposDir: TStaticText;
    ChBoxSubDir: TCheckBox;
    ChBoxDownloadLastRelease: TCheckBox;
    mm: TMemo;
    Panel: TPanel;
    ImagRepository: TImage;
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
    ChBoxAddVerToFileName: TCheckBox;
    LblIntervalAvtoCheck: TLabel;
    SpEdTimeAutoCheck: TSpinEdit;
    LblAvtoCheckInfo: TLabel;
    procedure BtnApplyClick(Sender: TObject);
    procedure edRepositoryLinkChange(Sender: TObject);
    procedure FrmShowInit;
    procedure SaveAddedNewRepository(Index: Integer);
    procedure SpdBtnOpenDirClick(Sender: TObject);
    procedure FormShowEdit(ReposIndex: integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FApiRepository      : string;
    FApiReleases        : string;
    FRepositoryName     : string;
    FFullName           : string;
    FAvatar_url         : string;
    FRepositoryDir      : string;
    FAvatarFileName     : string;
    FLastReleaseVersion : string;
    FProjChecked        : Boolean;
    FPublishRelease     : string;
    FLanguage           : string;
    FReposIndex         : Integer;
    FFrmMode            : TFrmShowMode;
    function ConverLinkToApiLink(Link: String): String;
    function ExtractReposNameFromLink(URL: String): String;
    function ExcludeTrailingURLDelimiter(URL: String): String;
    function GetImageExtention(ContentType: string): String;
    function CheckRepositoryExistes(URL: String): boolean;
  public
    { Public declarations }
    Applay: Boolean;
  end;

var
  FrmAddRepository: TFrmAddRepository;

const
   test_url = 'https://github.com/superbot-coder/chia_plotting_tools';
  // 'http://api.github.com/repos/superbot-coder/chia_plotting_tools/releases'

implementation

{$R *.dfm}

Uses UFrmMain;

function TFrmAddRepository.CheckRepositoryExistes(URL: String): boolean;
var i: SmallInt;
begin
  Result := False;
  for i := 0 to Length(arReposList)-1 do
  begin
    if arReposList[i].ReposUrl = URL then
    begin
      Result := true;
      exit;
    end;
  end;
end;

function TFrmAddRepository.ConverLinkToApiLink(Link: String): String;
begin
  if Link = '' then Exit;
  if AnsiPos('https://', Link) > 0 then
    Result := StringReplace(Link, 'https://github.com', 'https://api.github.com/repos', [rfIgnoreCase])
  else
    Result := StringReplace(Link, 'github.com', 'https://api.github.com/repos', [rfIgnoreCase]);
  Result := Result;
end;

function TFrmAddRepository.ExcludeTrailingURLDelimiter(URL: String): String;
var
  len: Integer;
begin
  if URL = '' then Exit;
  len := Length(URL);
  Result := URL;
  if (URL[len] = '/') or (URL[len] = '\')  then Delete(Result, len, 1);
end;

function TFrmAddRepository.ExtractReposNameFromLink(URL: String): String;
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

procedure TFrmAddRepository.FormCreate(Sender: TObject);
begin
  EdFilterInclude.MaxLength  := 500;
  edFilterExclude.MaxLength  := 500;
  edSaveDir.MaxLength        := 260;
  edRepositoryLink.MaxLength := 500;
end;

procedure TFrmAddRepository.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then Close;
end;

procedure TFrmAddRepository.FormShowEdit(ReposIndex: integer);
begin
  FReposIndex := ReposIndex;
  FFrmMode    := fsmEdit;
  edRepositoryLink.Enabled := false;
  edRepositoryLink.Text    := arReposList[ReposIndex].ReposUrl;
  edSaveDir.Text           := arReposList[ReposIndex].ReposDir;
  ChBoxSubDir.Checked      := arReposList[ReposIndex].NeedSubDir;
  RGRuleDownload.ItemIndex := arReposList[ReposIndex].RuleDownload;
  RGRulesNotis.ItemIndex   := arReposList[ReposIndex].RuleNotis;
  EdFilterInclude.Text     := arReposList[ReposIndex].FilterInclude;
  edFilterExclude.Text     := arReposList[ReposIndex].FilterExclude;
  ChBoxDownloadLastRelease.Enabled := False;
  BtnApply.Caption         := 'С О Х Р А Н И Т Ь';
  if FileExists(arReposList[ReposIndex].AvatarFile) then
    ImagRepository.Picture.LoadFromFile(arReposList[ReposIndex].AvatarFile);
  SpEdTimeAutoCheck.Value  := arReposList[ReposIndex].TimelAvtoCheck;

  ShowModal;
end;

procedure TFrmAddRepository.FrmShowInit;
begin
  // init controls
  FFrmMode := fsmAddNew;
  edRepositoryLink.Text    := '';
  edRepositoryLink.Enabled := true;
  edSaveDir.Text           := '';
  BtnApply.Enabled         := False;
  BtnApply.Caption         := 'Д О Б А В И Т Ь';
  ImagRepository.Picture   := Nil;
  RGRuleDownload.ItemIndex := 0;
  RGRulesNotis.ItemIndex   := 0;
  ChBoxSubDir.Checked      := false;
  ChBoxAddVerToFileName.Checked    := false;
  ChBoxDownloadLastRelease.Enabled := True;
  EdFilterInclude.Text := 'windows, win, win64, 64bit';
  edFilterExclude.Text := 'mac, linux, 32bit';
  SpEdTimeAutoCheck.Value := 24;

  mm.Clear;

  // init values
  Applay              := false;
  FApiRepository      := '';
  FRepositoryDir      := '';
  FApiReleases        := '';
  FRepositoryName     := '';
  FFullName           := '';
  FAvatar_url         := '';
  FAvatarFileName     := '';
  FLastReleaseVersion := '';

  ShowModal;
end;

function TFrmAddRepository.GetImageExtention(ContentType: string): String;
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

procedure TFrmAddRepository.SaveAddedNewRepository(Index: Integer);
var
  INI: TIniFile;
  Section: string;
begin

  if Not DirectoryExists(ConfigDir) then ForceDirectories(ConfigDir);
  Section := 'REPOSITORY_LIST\'+ StringReplace(arReposList[Index].FullReposName, '/', '_', [rfReplaceAll]);

  INI := TIniFile.Create(FileConfig);
  try
    with INI do
    begin
      WriteString(Section, 'RepositoryUrl', arReposList[Index].ReposUrl);
      WriteString(Section, 'RepositoryDir', arReposList[Index].ReposDir);
      WriteString(Section, 'ApiRepositoryUrl', arReposList[Index].ApiReposUrl);
      WriteString(Section, 'ApiReleasesUrl', arReposList[Index].ApiReleasesUrl);
      WriteString(Section, 'RepositoryName', arReposList[Index].ReposName);
      WriteString(Section, 'FullRepositoryName', arReposList[Index].FullReposName);
      WriteString(Section, 'AvatarFile', arReposList[Index].AvatarFile);
      WriteString(Section, 'AvatarUrl',arReposList[Index].AvatarUrl );
      WriteString(Section, 'FilterInclude', arReposList[Index].FilterInclude);
      WriteString(Section, 'FilterExclude', arReposList[Index].FilterExclude);
      WriteString(Section, 'DatePublish', arReposList[Index].DatePublish);
      WriteString(Section, 'Language', arReposList[Index].Language);
      WriteString(Section, 'LastVersion', arReposList[Index].LastVersion);
      WriteDateTime(Section, 'LastChecked', arReposList[Index].LastChecked);
      WriteInteger(Section, 'RuleDownload', arReposList[Index].RuleDownload);
      WriteInteger(Section, 'RuleNotis', arReposList[Index].RuleNotis);
      WriteBool(Section, 'NeedSubDir', arReposList[Index].NeedSubDir);
      WriteDateTime(Section, 'NewReleaseDT', arReposList[Index].NewReleaseDT);
      WriteBool(Section, 'AddVerToFileName', arReposList[Index].AddVerToFileName);
      WriteInteger(Section, 'TimeAvtoCheck', arReposList[Index].TimelAvtoCheck);
    end;
  finally
    INI.Free;
  end;
end;

procedure TFrmAddRepository.SpdBtnOpenDirClick(Sender: TObject);
var
  SelDir: String;
begin
  SelectDirectory('Выберите каталог', '', SelDir);
  edSaveDir.Text := SelDir;
end;

procedure TFrmAddRepository.BtnApplyClick(Sender: TObject);
var
  JSONData : TJSONValue;
  ext      : string;
  x        : SmallInt;
begin

  if FFrmMode = fsmEdit then
  begin
    with arReposList[FReposIndex] do
    begin
      ReposDir      := edSaveDir.Text;
      NeedSubDir    := ChBoxSubDir.Checked;
      RuleDownload  := RGRuleDownload.ItemIndex;
      RuleNotis     := RGRulesNotis.ItemIndex;
      FilterInclude := EdFilterInclude.Text;
      FilterExclude := edFilterExclude.Text;
      AddVerToFileName := ChBoxAddVerToFileName.Checked;
      TimelAvtoCheck := SpEdTimeAutoCheck.Value;
    end;
    SaveAddedNewRepository(FReposIndex);
  end;

  if FFrmMode = fsmAddNew then
  begin
    BtnApply.Enabled := false;
    if edRepositoryLink.Text = '' then edRepositoryLink.Text := test_url;

    if edRepositoryLink.Text = '' then
    begin
      MessageBox(Handle, PChar('Введите ссылку на проект'),
               PChar(CAPTION_MB), MB_ICONWARNING);
      Exit;
    end;

    if Not AnsiContainsStr(AnsiLowerCase(edRepositoryLink.Text), 'https://') then
      edRepositoryLink.Text := 'https://' + edRepositoryLink.Text;

    // Проверяю что проект уже добавлен в список
    // Checking that the project has already been added to the list
    if CheckRepositoryExistes(edRepositoryLink.Text) then
    begin
      MessageBox(Handle, PChar('Такой проек уже добавлен в список..'),
                 PChar(CAPTION_MB), MB_ICONWARNING);
      Exit;
    end;

    edRepositoryLink.Text := ExcludeTrailingURLDelimiter(Trim(edRepositoryLink.Text));
    FApiRepository        := ConverLinkToApiLink(edRepositoryLink.Text);
    FApiReleases          := FApiRepository + '/releases';

    with FrmMain do
    begin
      // проверка правильная ссылки; Check Existes the project
      RESTResponse.RootElement := '';
      RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
      RESTClient.BaseURL       := FApiRepository;
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
      FRepositoryName := RESTResponse.JSONValue.FindValue('name').Value;

      if RESTResponse.JSONValue.FindValue('full_name') = Nil then
      begin
        //
        Exit;
      end;
      // Получаю полное имя проекта; Getting full name the project
      FFullName := RESTResponse.JSONValue.FindValue('full_name').Value;
      // Заменяю символ "/" на "_" ;
      mm.Lines.Add('Название репозитория: ' + FRepositoryName);

      // Получаю URL аватарки проекта; Getting the avatar URL of the project
      JSONData := RESTResponse.JSONValue.FindValue('owner').FindValue('avatar_url');
      if JSONData <> Nil then FAvatar_url := JSONData.Value;

      // получаю язык программирования проекта; getting the project programming language
      FLanguage := RESTResponse.JSONValue.FindValue('language').Value;

      // Получаю директорию проекта; Getting the project directory
      if edSaveDir.Text <> '' then
        FRepositoryDir := edSaveDir.Text
      else
        FRepositoryDir := GLReposDir + PathDelim +
                       StringReplace(FFullName, '/', '_', [rfReplaceAll, rfIgnoreCase]);
      if Not DirectoryExists(FRepositoryDir) then ForceDirectories(FRepositoryDir);

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
        FAvatarFileName := FRepositoryDir + '\Avatar' + ext;
        TFile.WriteAllBytes(FAvatarFileName, RESTResponse.RawBytes);
        ImagRepository.Picture.LoadFromFile(FAvatarFileName);
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
        mm.Lines.Add('Имя релиза: ' + FRepositoryName);
        FLastReleaseVersion := RESTResponse.JSONValue.FindValue('tag_name').Value;
        FPublishRelease     := RESTResponse.JSONValue.FindValue('published_at').Value;
        FPublishRelease     := ConvertGitHubDateToDateTime(FPublishRelease);
        mm.Lines.Add('Дата публикации последнего релиза: ' + FPublishRelease);
        mm.Lines.Add('Версия последнего релиза: ' + FLastReleaseVersion);
        mm.Lines.Add('Проверка выполнена.');
        MessageBox(Handle, PChar(mm.Lines.Text), PChar(CAPTION_MB), MB_ICONINFORMATION);
      end;
    end;

    // Добавляю новую запись в массив arReposList
    // Adding a new entry to the array arReposList
    SetLength(arReposList, Length(arReposList) + 1);
    with arReposList[Length(arReposList) - 1] do
    begin
      ReposUrl         := edRepositoryLink.Text;
      ReposDir         := FRepositoryDir;
      ApiReposUrl      := FApiRepository;
      ApiReleasesUrl   := FApiReleases;
      ReposName        := FRepositoryName;
      FullReposName    := FFullName;
      AvatarFile       := FAvatarFileName;
      AvatarUrl        := FAvatar_url;
      FilterInclude    := EdFilterInclude.Text;
      FilterExclude    := edFilterExclude.Text;
      DatePublish      := FPublishRelease;
      Language         := FLanguage;
      LastVersion      := FLastReleaseVersion;
      LastChecked      := Date + Time;
      RuleDownload     := RGRuleDownload.ItemIndex;
      RuleNotis        := RGRulesNotis.ItemIndex;
      NewReleaseDT     := Date + Time;
      AddVerToFileName := ChBoxAddVerToFileName.Checked;
      TimelAvtoCheck   := SpEdTimeAutoCheck.Value;
    end;

    SaveAddedNewRepository(Length(arReposList) - 1);

    Applay := true;
    BtnApply.Enabled := true;
  end;

  Close;
end;

procedure TFrmAddRepository.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmAddRepository.edRepositoryLinkChange(Sender: TObject);
begin
  BtnApply.Enabled := true;
end;

end.
