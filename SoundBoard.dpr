program SoundBoard;

uses
  Forms,
  frmMain in 'frmMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SoundBoard';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
