program GitHubReleasesTracker;

uses
  Vcl.Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UFrmAddProject in 'UFrmAddProject.pas' {FrmAddProject};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmAddProject, FrmAddProject);
  Application.Run;
end.
