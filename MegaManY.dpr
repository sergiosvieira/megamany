program MegaManY;

uses
  Forms,
  UMain in 'UMain.pas' {FmMain},
  UClasses in 'UClasses.pas',
  UConstantes in 'UConstantes.pas',
  UFuncoes in 'UFuncoes.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFmMain, FmMain);
  Application.Run;
end.
