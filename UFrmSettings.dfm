object FrmSettings: TFrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 332
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object sLblDefaultDownloadDir: TsLabel
    Left = 16
    Top = 48
    Width = 197
    Height = 13
    Caption = #1044#1080#1088#1077#1082#1090#1086#1088#1080#1103' '#1076#1083#1103' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103' '#1087#1088#1086#1077#1082#1090#1086#1074
  end
  object sLblChekInterval: TsLabel
    Left = 16
    Top = 120
    Width = 104
    Height = 13
    Caption = #1048#1085#1090#1088#1077#1074#1072#1083' '#1087#1088#1086#1074#1077#1088#1082#1080':'
  end
  object sDirEdDefaultDownloadDir: TsDirectoryEdit
    Left = 16
    Top = 72
    Width = 393
    Height = 21
    MaxLength = 255
    TabOrder = 0
    Text = ''
    CheckOnExit = True
    Root = 'rfDesktop'
  end
  object sBtnOk: TsButton
    Left = 160
    Top = 288
    Width = 121
    Height = 25
    Caption = #1055#1056#1048#1052#1045#1053#1048#1058#1068
    TabOrder = 1
  end
end
