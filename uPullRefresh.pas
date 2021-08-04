unit uPullRefresh;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Objects, FMX.Effects,
  FMX.Layouts, FMX.Ani;

Const
   PullHeight = 100;

type

  TPullRefresh = class(TFrame)
    Circle1       : TCircle;
    ShadowEffect1 : TShadowEffect;
    Path1         : TPath;
  Private
    Const
       PathOff : String = 'M17.65,6.35 C16.2,4.9 14.21,4 12,4 A8,8 0 0,0 4,12 A8,8 0 0,0 12,20 C15.73,20 18.84,17.45 19.73,14 H17.65 C16.83,16.33 14.61,18 12,18 A6,6 0 0,1 6,12 A6,6 0 0,1 12,6 C13.66,6 15.14,6.69 16.22,7.78 L13,11 H20 V4 L17.65,6.35 Z';
       PathOn  : String = 'M17.65,6.35 C16.2,4.9 14.21,4 12,4 A8,8 0 0,0 4,12 A8,8 0 0,0 12,20 C15.73,20 18.84,17.45 19.73,14 H17.65 C16.83,16.33 14.61,18 12,18 A6,6 0 0,1 6,12 A6,6 0 0,1 12,6 C13.66,6 15.14,6.69 16.22,7.78 Z';
  private
    FScrollBox      : TVertScrollBox;
    FBackViewChange : TPositionChangeEvent;
    FInTop          : Boolean;
    FInTouch        : Boolean;
    FPosYTouch      : Single;
    FOnRefresh      : TNotifyEvent;
    FAni            : TFloatAnimation;
    procedure ViewportChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
    procedure EvMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure EvMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure EvMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
  protected
    Procedure Loaded; Override;
  public
    Constructor Create(aOwner : TComponent); Override;
    Procedure SetScrollBox(aScrollBox : TVertScrollBox);
    Procedure Stop;
    Property OnRefresh : TNotifyEvent Read FOnRefresh   Write FOnRefresh;
  end;

implementation

{$R *.fmx}

{ TFrame7 }

constructor TPullRefresh.Create(aOwner: TComponent);
begin
inherited;
FInTop            := False;
FInTouch          := False;
FScrollBox    := Nil;
FAni              := TFloatAnimation.Create(Path1);
FAni.Parent       := Path1;
FAni.StartValue   := 0;
FAni.StopValue    := 360;
FAni.Duration     := 1;
FAni.Loop         := True;
FAni.PropertyName := 'RotationAngle';
end;

procedure TPullRefresh.Loaded;
begin
inherited;
Path1.Data.Data := PathOff;
if Not(CsDesigning In ComponentState) then Parent := Nil;
end;

procedure TPullRefresh.Stop;
begin
TThread.Queue(Nil,
   procedure
   Begin
   TAnimator.AnimateFloat(Self, 'Position.Y', (FScrollBox.Position.Y - Self.Height));
   FAni.Stop;
   FInTop := False;
   End);
end;

procedure TPullRefresh.SetScrollBox(aScrollBox: TVertScrollBox);
begin
if (aScrollBox = Nil) And (FScrollBox <> Nil) then
   Begin
   FScrollBox.OnViewportPositionChange := FBackViewChange;
   FScrollBox.OnMouseDown              := Nil;
   FScrollBox.OnMouseUp                := Nil;
   FScrollBox.OnMouseMove              := Nil;
   End;
if (aScrollBox <> Nil) And (aScrollBox <> FScrollBox) Then
   Begin
   FScrollBox                          := aScrollBox;
   FBackViewChange                     := FScrollBox.OnViewportPositionChange;
   FScrollBox.OnViewportPositionChange := ViewportChange;
   FScrollBox.OnMouseDown              := EvMouseDown;
   FScrollBox.OnMouseUp                := EvMouseUp;
   FScrollBox.OnMouseMove              := EvMouseMove;
   End;
end;

procedure TPullRefresh.EvMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
Begin
FInTouch   := True;
FPosYTouch := Y;
Opacity    := 1;
Path1.RotationAngle := 0;
Path1.Opacity       := 0.4;
Path1.Data.Data     := PathOff;
End;

procedure TPullRefresh.EvMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
Begin
FInTouch := False;
FInTop   := False;
if Position.Y < Pullheight then
   TAnimator.AnimateFloat(Self, 'Position.Y', (FScrollBox.Position.Y - Self.Height))
Else
   Begin
   if Assigned(FOnRefresh) then FOnRefresh(Self);
   Path1.Data.Data := PathOn;
   FAni.Start;
   TAnimator.AnimateFloat(Self, 'Position.Y', PullHeight/2);
   End;
End;

procedure TPullRefresh.EvMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
Var
   PosY       : Single;
begin
if FInTouch then
   Begin
   PosY := (FScrollBox.Position.Y - Self.Height) + (Y - FPosYTouch);
   if PosY <= PullHeight then
      Begin
      Position.Y := PosY;
      Path1.RotationAngle := (360/PullHeight)*Position.Y;
      Path1.Opacity       := (0.6/PullHeight)*Position.Y + 0.4;
      End;
   End;
end;

procedure TPullRefresh.ViewportChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
begin
if Assigned(FBackViewChange) then FBackViewChange(Sender, OldViewportPosition, NewViewportPosition, ContentSizeChanged);
if Not FIntop And (NewViewportPosition.Y = 0) then
   Begin
   FInTop     := True;
   Parent     := FScrollBox.Parent;
   Position.X := (FScrollBox.Width - Self.Width) /2;
   Position.Y := FScrollBox.Position.Y - Self.Height;
   End
Else
   FInTop := False;

end;

end.
