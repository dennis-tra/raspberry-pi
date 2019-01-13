program TempWin;

uses
  Forms,
  uMain in 'uMain.pas' {Main};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
