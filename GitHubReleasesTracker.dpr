program GitHubReleasesTracker;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UFrmAddRepository in 'UFrmAddRepository.pas' {FrmAddRepository},
  UFrmSettings in 'UFrmSettings.pas' {FrmSettings},
  Vcl.Themes,
  Vcl.Styles,
  UFrmDownloadFiles in 'UFrmDownloadFiles.pas' {FrmDownloadFiles},
  UThreadReposCheck in 'UThreadReposCheck.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Sapphire Kamri');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmAddRepository, FrmAddRepository);
  Application.CreateForm(TFrmSettings, FrmSettings);
  Application.CreateForm(TFrmDownloadFiles, FrmDownloadFiles);
  Application.Run;
end.
