unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  JvComponentBase, JvHidControllerClass, StdCtrls,
  Spin, IniFiles, ComCtrls, JvLED;

const
  MyVid = $16C0;
  MyPid = $0480;

type
  TTempData = packed record
    SensCnt:  Byte;
    SensNr:   Byte;
    Power:    Byte;
    Dummy1:   Byte;
    Temp:     Smallint;
    Dummy2:   Word;
    SensId:   Array[0..7] of Byte;
  end;

  TSensPanels = record
    Group: TGroupBox;
    LabPowerInfo: TLabel;
    LabPowerText: TLabel;
    LabIdInfo: TLabel;
    LabIdText: TLabel;
    LabTemp:   TLabel;
    Led:       TJVLed;
  end;

  TMain = class(TForm)
    HidCtrl: TJvHidDeviceController;
    cbDevices: TComboBox;
    sBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HidCtrlDeviceChange(Sender: TObject);
    function HidCtrlEnumerate(HidDev: TJvHidDevice;
      const Idx: Integer): Boolean;
    procedure cbDevicesChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HidCtrlDeviceData(HidDev: TJvHidDevice; ReportID: Byte;
      const Data: Pointer; Size: Word);
  private
    procedure ClearSensors;
  public
    SensPanels: Array of TSensPanels;
    SaveSnr:  AnsiString;
    FirstSnr: boolean;
    OldSnr: AnsiString;
    Dev: TJvHidDevice;
    IniFile:  AnsiString;
    ProgPath: AnsiString;
    ProgVersion: integer;
    ProgTitle: AnsiString;
  end;

var
  Main: TMain;

implementation

uses Hid;

{$R *.DFM}
{==========================================================}
procedure TMain.FormCreate(Sender: TObject);
begin
  ProgVersion:=$11;
  ProgTitle:='Temp-Win v'+Format('%1x.%1x', [ProgVersion div 16, ProgVersion and $0F]);
  ProgPath:=ExtractFilePath(Application.ExeName);
  IniFile:=ChangeFileExt(Application.ExeName, '.ini');
  Application.Title:=ProgTitle;
  Caption:=Application.Title;
  ForceCurrentDirectory:=TRUE;
  FormatSettings.DecimalSeparator:='.';
  Dev:=NIL;
end;
{==========================================================}
procedure TMain.FormShow(Sender: TObject);
begin
  setLength(SensPanels, 0);
  FirstSnr:=TRUE;
end;
{==========================================================}
procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
end;
{==========================================================}
procedure TMain.ClearSensors;
var n, i: integer;
begin
  n:=length(SensPanels);
  if(n > 0) then begin
    for i:=0 to n - 1 do with SensPanels[i] do begin
      LabPowerInfo.Free;
      LabPowerText.Free;
      LabIdInfo.Free;
      LabIdText.Free;
      LabTemp.Free;
      Group.Free;
    end;
  end;
  SetLength(SensPanels, 0);
  Main.Height:=1 * 50 + 54;
end;
{==========================================================}
procedure TMain.HidCtrlDeviceChange(Sender: TObject);
var i: integer;
    MyDev: TJvHidDevice;
begin
  OldSnr:=cbDevices.Text;
  for i:= 0 to cbDevices.Items.Count-1 do begin
    MyDev:=TJvHidDevice(cbDevices.Items.Objects[i]);
    HidCtrl.CheckIn(MyDev);
    cbDevices.Items.Objects[I]:=nil;
  end;
  cbDevices.Items.Clear;
  HidCtrl.Enumerate;
  cbDevicesChange(Self);
end;
{==========================================================}
function TMain.HidCtrlEnumerate(HidDev: TJvHidDevice;
  const Idx: Integer): Boolean;

var n, sel: integer;
    MyDev: TJvHidDevice;
    sTmp:  AnsiString;
begin
  sel:=0;
  if(HidDev.Attributes.VendorID = MyVid) and (HidDev.Attributes.ProductID = MyPid) then begin
    HidCtrl.CheckOutByIndex(MyDev, Idx);
    sTmp:=HidDev.SerialNumber;
    if(sTmp = '') then sTmp:='SERIAL IS MISSING';
    n:=cbDevices.Items.Add(sTmp);
    if(HidDev.SerialNumber = OldSnr) then sel:=n;
    cbDevices.Items.Objects[n]:=HidDev;

//    Debug.S(HidDev.Attributes.VersionNumber.ToHexString);
  end;
  cbDevices.ItemIndex:=sel;
  if(cbDevices.Items.Count = 0) then begin
    sBar.Panels[0].Text:='No Temp-Sensor Hardware found';
    ClearSensors;
  end else begin
    sBar.Panels[0].Text:='Waiting for data...';
  end;
  Result:=TRUE;
end;
{==========================================================}
procedure TMain.cbDevicesChange(Sender: TObject);
var tmp: integer;
begin
  if(FirstSnr) then begin
    tmp:=cbDevices.Items.IndexOf(SaveSnr);
    if(tmp < 0) then tmp:=0; 
    cbDevices.ItemIndex:=tmp;
    FirstSnr:=FALSE;
  end;
end;
{==========================================================}
procedure TMain.HidCtrlDeviceData(HidDev: TJvHidDevice; ReportID: Byte;
  const Data: Pointer; Size: Word);
var td: ^TTempData;
    i: integer;
    sTmp: AnsiString;
begin
  td:=Data;
  if(td.SensCnt <> length(SensPanels)) then begin
    sBar.Panels[0].Text:=Format('Sensors found: %d', [td.SensCnt]);
    setLength(SensPanels, td.SensCnt);
    if(td.SensCnt <> 0) then begin
      for i:=0 to td.SensCnt - 1 do with SensPanels[i] do begin
        //--- GROUP-BOX ---
        Group:=TGroupBox.Create(Main);
        Group.Left:=4;
        Group.Top:=4 + 50 * i;
        Group.Height:=50;
        Group.Width:=ClientWidth - 8;
        Group.Caption:=Format(' Sensor %d ', [i + 1]);
        Group.Font.Style:=[fsBold];
        Group.Parent:=Main;
        Group.Visible:=TRUE;

        //--- LAB-POWERINFO ---
        LabPowerInfo:=TLabel.Create(Group);
        LabPowerInfo.Top:=16;
        LabPowerInfo.Left:=4;
        LabPowerInfo.Width:=54;
        LabPowerInfo.Alignment:=taRightJustify;
        LabPowerInfo.Caption:='Power:';
        LabPowerInfo.ParentFont:=FALSE;
        LabPowerInfo.Parent:=Group;
        LabPowerInfo.Visible:=TRUE;

        //--- LAB-POWERTEXT ---
        LabPowerText:=TLabel.Create(Group);
        LabPowerText.Top:=16;
        LabPowerText.Left:=64;
        LabPowerText.Caption:='...';
        LabPowerText.ParentFont:=FALSE;
        LabPowerText.Parent:=Group;
        LabPowerText.Visible:=TRUE;

        //--- LAB-IDINFO ---
        LabIdInfo:=TLabel.Create(Group);
        LabIdInfo.Top:=30;
        LabIdInfo.Left:=4;
        LabIdInfo.Width:=54;
        LabIdInfo.Alignment:=taRightJustify;
        LabIdInfo.Caption:='Sensor-Id:';
        LabIdInfo.ParentFont:=FALSE;
        LabIdInfo.Parent:=Group;
        LabIdInfo.Visible:=TRUE;

        //--- LAB-IDTEXT ---
        LabIdText:=TLabel.Create(Group);
        LabIdText.Top:=30;
        LabIdText.Left:=64;
        LabIdText.Caption:='...';
        LabIdText.ParentFont:=FALSE;
        LabIdText.Parent:=Group;
        LabIdText.Visible:=TRUE;

        //--- LAB-TEMP ---
        LabTemp:=TLabel.Create(Group);
        LabTemp.Top:=14;
        LabTemp.Left:=220;
        LabTemp.Caption:='---';
        LabTemp.ParentFont:=FALSE;
        LabTemp.Font.Name:='Arial';
        LabTemp.Font.Style:=[fsBold];
        LabTemp.Font.Size:=18;
        LabTemp.Parent:=Group;
        LabTemp.Visible:=TRUE;

        //--- LED ---
        Led:=TJVLed.Create(Group);
        Led.Top:=20;
        Led.Left:=320;
        Led.ColorOff:=clBlack;
        Led.ColorOn:=clLime;
        Led.Status:=FALSE;
        Led.Parent:=Group;
        Led.Visible:=TRUE;
      end;
    end;
    Main.Height:=td.SensCnt * 50 + 54;
  end;

  for i:=0 to td.SensCnt - 1 do with SensPanels[i] do begin
    if(i = td.SensNr - 1) then Led.Status:=TRUE
                          else Led.Status:=FALSE;
  end;


  with SensPanels[td.SensNr - 1] do begin
    if(td.Power = 0) then LabPowerText.Caption:='Parasite'
                     else LabPowerText.Caption:='Extern';
    sTmp:='';
    for i:=0 to 7 do begin
      sTmp:=sTmp + IntToHex(td.SensId[i], 2) + ' ';
    end;
    LabIdText.Caption:=sTmp;
    LabTemp.Caption:=Format('%.1f °C', [td.Temp / 10.0]);
  end;

//  Debug.BUFF(Data, Size);
end;
{==========================================================}
end.
