unit UFrmDownloadFiles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.JumpList, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.JSON, REST.Types ,RESTContentTypeStr, System.ImageList,
  Vcl.ImgList;

type
  TFrmDownloadFiles = class(TForm)
    LVFiles: TListView;
    BtnApply: TButton;
    BtnClose: TButton;
    PnlBoard: TPanel;
    ImageList: TImageList;
    procedure BtnCloseClick(Sender: TObject);
    Function AddLVItem: integer;
    procedure BtnApplyClick(Sender: TObject);
    procedure ShowInit(JSONData: TJSONValue; ProjectIndex: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    STDownloadFiles: TStrings;
    StDownloadFilesAfterFilter: TStrings;
    FProjectIndex: Integer;
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
begin
  ShowMessage(STDownloadFiles.Text);
end;

procedure TFrmDownloadFiles.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmDownloadFiles.FormCreate(Sender: TObject);
begin
  STDownloadFiles := TStringList.Create;
  StDownloadFilesAfterFilter := TStringList.Create;
end;

procedure TFrmDownloadFiles.ShowInit(JSONData: TJSONValue; ProjectIndex: Integer);
var
  JSONArray: TJSONArray;
  i, x: Word;
  FileName: string;
begin
  FProjectIndex := ProjectIndex;
  STDownloadFiles.Clear;
  STDownloadFilesAfterFilter.Clear;

  if JSONData.FindValue('assets') = Nil then ShowMessage('FindValue(''assets'') = Nil');

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
      LVFiles.Items[x].SubItems[0] := JSONArray.Items[i].FindValue('size').Value;
    end;
  end;

  x := AddLVItem;
  FileName := JSONData.FindValue('zipball_url').Value;
  STDownloadFiles.Add(FileName);
  Delete(FileName, 1, LastDelimiter('/', FileName));
  LVFiles.Items[x].Caption    := 'Source code ' + FileName + '.zip';
  LVFiles.Items[x].ImageIndex := 1;

  x := AddLVItem;
  FileName := JSONData.FindValue('tarball_url').Value;
  STDownloadFiles.Add(FileName);
  Delete(FileName, 1, LastDelimiter('/', FileName));
  LVFiles.Items[x].Caption := 'Source code ' + FileName + '.tar.gz';;
  LVFiles.Items[x].ImageIndex := 1;

  //STDownloadFiles.Add(JSONData.FindValue('tarball_url').Value);
  //STDownloadFiles.Add(JSONData.FindValue('zipball_url').Value);


  ShowModal;
end;

end.
