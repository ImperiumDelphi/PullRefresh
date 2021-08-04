unit uTestePull;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, uPullRefresh;

type
  TForm6 = class(TForm)
    Scroll1: TVertScrollBox;
    Layout1: TLayout;
    PullRefresh1: TPullRefresh;
    procedure FormShow(Sender: TObject);
  private
    procedure Refresh(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.fmx}

procedure TForm6.Refresh(Sender: TObject);
begin
TTHread.CreateAnonymousThread(
   procedure
   Begin
   Sleep(3000);
   PullRefresh1.Stop;
   End).Start;
end;

procedure TForm6.FormShow(Sender: TObject);
begin
PullRefresh1.SetScrollBox(Scroll1);
PullRefresh1.OnRefresh := Refresh;
end;

end.
