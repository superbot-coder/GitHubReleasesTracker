unit UFrmSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sLabel, Vcl.Mask,
  sMaskEdit, sCustomComboEdit, sToolEdit, sButton;

type
  TFrmSettings = class(TForm)
    sDirEdDefaultDownloadDir: TsDirectoryEdit;
    sLblDefaultDownloadDir: TsLabel;
    sBtnOk: TsButton;
    sLblChekInterval: TsLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSettings: TFrmSettings;

implementation

{$R *.dfm}

end.
