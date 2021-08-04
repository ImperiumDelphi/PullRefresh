program TestePullRefresh;

uses
  System.StartUpCopy,
  FMX.Forms,
  uTestePull in 'uTestePull.pas' {Form6},
  uPullRefresh in 'uPullRefresh.pas' {PullRefresh: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
