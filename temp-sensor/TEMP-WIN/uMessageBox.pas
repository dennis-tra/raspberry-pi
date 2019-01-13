unit uMessageBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math,
  StdCtrls, ExtCtrls, ImgList;

type
  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
  TMsgDlgBtn = (mbYes, mbNo, mbOK, mbClose, mbIgnore, mbAbort);
  TMsgBut = Set of TMsgDlgBtn;

  TMsgBox = class(TForm)
    IconImg: TImageList;
    Img: TImage;
    InfoLabel: TLabel;
    procedure FormShow(Sender: TObject);
  private
    But: Array of TButton;
    ButCnt: integer;
  public
    CaptionTitle: string;
    function Execute(MsgText: string;
                     DlgType: TMsgDlgType=mtCustom;
                     CaptionTitle: string='';
                     Buttons: TMsgBut=[mbClose];
                     MsgBeep: boolean=TRUE): integer;
  end;

var
  MsgBox: TMsgBox;

implementation

{$R *.DFM}
{==========================================================}
function TMsgBox.Execute(MsgText: string;
                         DlgType: TMsgDlgType=mtCustom;
                         CaptionTitle: string='';
                         Buttons: TMsgBut=[mbClose];
                         MsgBeep: boolean=TRUE): integer;
var cap: string;
    ImgIndex: integer;
    i: integer;

    procedure AddBut(cap: TCaption; mr: TModalResult);
    const butDist = 10;
          butWidth = 75;
    var i: integer;
        gWidth, bPos: integer;
    begin
      inc(ButCnt);
      SetLength(But, ButCnt);
      But[ButCnt-1]:=TButton.Create(Self);
      with But[ButCnt-1] do begin
        Parent:=MsgBox;
        Top:=MsgBox.Height - 55;
        Width:=butWidth;
        Caption:=cap;
        ModalResult:=mr;
        Name:='But'+IntToStr(ButCnt);
      end;
      gWidth:=butWidth * ButCnt + (ButCnt - 1) * butDist ;
      bPos:=MsgBox.Width div 2 - gWidth div 2;
      for i:=1 to ButCnt do begin
        But[i-1].Left:=bPos;
        bPos:=bPos + butWidth + butDist;
      end;
    end;

begin
  case DlgType of
    mtWarning: begin cap:='Warning'; ImgIndex:=0; end;
    mtError:   begin cap:='Error'; ImgIndex:=1; end;
    mtInformation: begin cap:='Information'; ImgIndex:=2; end;
    mtConfirmation: begin cap:='Confirmation'; ImgIndex:=3; end;
    mtCustom: begin cap:='Message'; ImgIndex:=-1; end;
  end;

  Img.Visible:=ImgIndex>=0;
  if Img.Visible then InfoLabel.Left:=Img.Left + Img.Width + 20
                 else InfoLabel.Left:=20;
  Img.Canvas.FillRect(Rect(0,0,Img.Width,Img.Height));
  IconImg.Draw(Img.Canvas, 0, 0, ImgIndex);

  if CaptionTitle<>'' then Caption:=CaptionTitle
                      else Caption:=Cap;
  InfoLabel.Caption:=MsgText;
  MsgBox.Width:=Max(280, InfoLabel.Width + InfoLabel.Left + 20);
  MsgBox.Height:=Max(120, InfoLabel.Height + 75);

  ButCnt:=0;
  if mbClose in Buttons then AddBut('Schlieﬂen', mrCancel);
  if mbYes   in Buttons then AddBut('Ja',   mrYes);
  if mbNo    in Buttons then AddBut('Nein',    mrNo);
  if mbOk    in Buttons then AddBut('Ok',    mrOk);
  if mbIgnore in Buttons then AddBut('Ignorieren', mrIgnore);
  if mbAbort  in Buttons then AddBut('Abbruch',  mrAbort);

  MsgBox.Position:=poOwnerFormCenter;
  if MsgBeep then MessageBeep(MB_ICONSTOP);
  Result:=ShowModal;
  for i:=1 to ButCnt do But[i-1].Free;
end;
{==========================================================}
procedure TMsgBox.FormShow(Sender: TObject);
begin
  (FindComponent('But1') as TButton).SetFocus;
end;
{==========================================================}
end.
