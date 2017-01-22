program DelphiFunCuriosity;

uses
  System.StartUpCopy,
  FMX.Forms,
  principale in 'principale.pas' {fPrincipale},
  uCuriosityImg in 'uCuriosityImg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfPrincipale, fPrincipale);
  Application.Run;
end.
