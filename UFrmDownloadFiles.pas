unit UFrmDownloadFiles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.JumpList, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.JSON, REST.Types ,RESTContentTypeStr, System.ImageList,
  Vcl.ImgList, FormatFileSizeMod, System.StrUtils, System.IOUtils;

type
  TFrmDownloadFiles = class(TForm)
    LVFiles: TListView;
    BtnApply: TButton;
    BtnClose: TButton;
    PnlBoard: TPanel;
    ImageList: TImageList;
    EdFilterEnclude: TEdit;
    EdFilterExclude: TEdit;
    LblFilterInclude: TLabel;
    LblFilterExclude: TLabel;
    BtnApplyFilter: TButton;
    BtnSelectAll: TButton;
    BtnDownAll: TButton;
    mm: TMemo;
    procedure BtnCloseClick(Sender: TObject);
    Function AddLVItem: integer;
    procedure BtnApplyClick(Sender: TObject);
    procedure ShowInit(JSONData: TJSONValue; ProjectIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ExecutFilters;
    procedure BtnApplyFilterClick(Sender: TObject);
    procedure BtnSelectAllClick(Sender: TObject);
    procedure BtnDownAllClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    STDownloadFiles : TStrings;
    FProjectIndex   : Integer;
    Ftag_name       : string;
  public
    { Public declarations }
  end;

var
  FrmDownloadFiles: TFrmDownloadFiles;

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
  for i := 0 to LVFiles.Items.Count -1 do
  begin
    if Not LVFiles.Items[i].Checked then Continue;

    LVFiles.Items[i].Selected := true;

    with FrmMain do begin
      RESTResponse.RootElement := '';
      RESTClient.Accept        := 'application'; //'application/zip';
      RESTClient.BaseURL       := STDownloadFiles.Strings[i];
      RESTRequest.Execute;
      if RESTResponse.StatusCode <> 200 then
      begin
        LVProj.Items[i].SubItems[1] := 'Ошибка';
        Continue;
      end;
    end;

    // подготовка директорнии для скачивания; preparing a directory for download
    if arProjectList[FProjectIndex].NeedSubDir then
      DownloadDir := arProjectList[FProjectIndex].ProjectDir + '\' + Ftag_name
    else
      DownloadDir := arProjectList[FProjectIndex].ProjectDir;
    if Not DirectoryExists(DownloadDir) then ForceDirectories(DownloadDir);

    SavedFileName := LVFiles.Items[i].Caption;
    if arProjectList[FProjectIndex].AddVerToFileName then
      insert('_' + Ftag_name, SavedFileName, LastDelimiter('.', SavedFileName)-1);

    SavedFileName := DownloadDir + '\' + SavedFileName;

    TFile.WriteAllBytes(SavedFileName, FrmMain.RESTResponse.RawBytes);
    If FileExists(SavedFileName) then LVFiles.Items[i].SubItems[1] := 'Скачано';
    Application.ProcessMessages;

  end;

  if EdFilterEnclude.Modified then ShowMessage('Modified');

end;

procedure TFrmDownloadFiles.BtnApplyFilterClick(Sender: TObject);
begin
  ExecutFilters;
end;

procedure TFrmDownloadFiles.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmDownloadFiles.BtnDownAllClick(Sender: TObject);
var i: Word;
begin
  for i := 0 to LVFiles.Items.Count -1 do LVFiles.Items[i].Checked := false;
end;

procedure TFrmDownloadFiles.BtnSelectAllClick(Sender: TObject);
var i: Word;
begin
  for i := 0 to LVFiles.Items.Count -1 do LVFiles.Items[i].Checked := true;
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
  if EdFilterEnclude.Modified then
    s_temp := AnsiLowerCase(EdFilterEnclude.Text)
  else
    s_temp := AnsiLowerCase(arProjectList[FProjectIndex].FilterInclude);
  s_temp := StringReplace(s_temp, ' ', '', [rfReplaceAll]);
  s_temp := StringReplace(s_temp, ',', #13, [rfReplaceAll]);
  STFilterInclude.Text := s_temp;

  //  подготавливаю список фильтка "Exclude"
  if EdFilterExclude.Modified then
    s_temp := AnsiLowerCase(EdFilterExclude.Text)
  else
    s_temp := AnsiLowerCase(arProjectList[FProjectIndex].FilterExclude);
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
  EdFilterEnclude.MaxLength := 500;
  EdFilterExclude.MaxLength := 500;
  STDownloadFiles := TStringList.Create;
end;

procedure TFrmDownloadFiles.FormDestroy(Sender: TObject);
begin
  STDownloadFiles.Free;
end;

procedure TFrmDownloadFiles.ShowInit(JSONData: TJSONValue; ProjectIndex: Integer);
var
  JSONArray: TJSONArray;
  i, x: Word;
  FileName: string;
  sz : string;
begin
  FProjectIndex := ProjectIndex;
  STDownloadFiles.Clear;
  EdFilterEnclude.Text := arProjectList[ProjectIndex].FilterInclude;
  EdFilterExclude.Text := arProjectList[ProjectIndex].FilterExclude;

  if JSONData = Nil then
  begin
    with FrmMain do
    begin
      RESTClient.BaseURL       := arProjectList[ProjectIndex].ApiReleasesUrl;
      RESTClient.Accept        := arContentTypeStr[ord(ctAPPLICATION_JSON)];
      RESTResponse.RootElement := '[0]';
      RESTRequest.Execute;
      if RESTResponse.StatusCode <> 200 then Exit;
      JSONData := RESTResponse.JSONValue;
    end;
  end;

  Ftag_name := JSONData.FindValue('tag_name').Value;
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

  x := AddLVItem;
  FileName := JSONData.FindValue('tarball_url').Value;
  STDownloadFiles.Add(FileName);
  Delete(FileName, 1, LastDelimiter('/', FileName));
  LVFiles.Items[x].Caption := 'Source code ' + FileName + '.tar.gz';;
  LVFiles.Items[x].ImageIndex := 1;
  LVFiles.Items[x].Checked    := true;

  if arProjectList[FProjectIndex].RuleDownload = 1 then ExecutFilters;

  ShowModal;

end;

end.
