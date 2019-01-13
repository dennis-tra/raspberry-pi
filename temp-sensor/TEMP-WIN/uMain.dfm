object Main: TMain
  Left = 676
  Top = 328
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Main'
  ClientHeight = 168
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cbDevices: TComboBox
    Left = 40
    Top = 24
    Width = 273
    Height = 21
    Style = csDropDownList
    TabOrder = 0
    Visible = False
    OnChange = cbDevicesChange
  end
  object sBar: TStatusBar
    Left = 0
    Top = 149
    Width = 367
    Height = 19
    Font.Charset = ANSI_CHARSET
    Font.Color = clBtnText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Panels = <
      item
        Width = 500
      end>
    SizeGrip = False
    UseSystemFont = False
  end
  object HidCtrl: TJvHidDeviceController
    OnEnumerate = HidCtrlEnumerate
    OnDeviceChange = HidCtrlDeviceChange
    OnDeviceData = HidCtrlDeviceData
    Left = 8
    Top = 8
  end
end
