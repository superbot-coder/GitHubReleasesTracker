program GitHubReleasesTracker;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UFrmAddProject in 'UFrmAddProject.pas' {FrmAddProject},
  UFrmSettings in 'UFrmSettings.pas' {FrmSettings},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Sapphire Kamri');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmAddProject, FrmAddProject);
  Application.CreateForm(TFrmSettings, FrmSettings);
  Application.Run;
end.
