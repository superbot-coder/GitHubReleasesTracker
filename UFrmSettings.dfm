object FrmSettings: TFrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 348
  ClientWidth = 463
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    463
    348)
  PixelsPerInch = 96
  TextHeight = 16
  object SpdBtnOpenDir: TSpeedButton
    Left = 424
    Top = 72
    Width = 25
    Height = 25
    Caption = '...'
    OnClick = SpdBtnOpenDirClick
  end
  object LblNewReleaseLive: TLabel
    Left = 16
    Top = 128
    Width = 324
    Height = 16
    Caption = #1057#1082#1086#1083#1100#1082#1086' '#1095#1072#1089#1086#1074' '#1085#1086#1074#1099#1081' '#1088#1077#1083#1080#1079' '#1073#1091#1076#1077#1090' '#1086#1090#1084#1077#1095#1077#1085' '#1082#1072#1082' '#1085#1086#1074#1099#1081':'
  end
  object LblHoursLimit: TLabel
    Left = 80
    Top = 160
    Width = 252
    Height = 16
    Caption = #1084#1080#1085'. = 0 '#1095#1072#1089#1086#1074'  '#1084#1072#1082#1089'. = 720 '#1095#1072#1089#1086#1074' - 30 '#1076#1085'.'
  end
  object LblSelectStyle: TLabel
    Left = 16
    Top = 207
    Width = 92
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1089#1090#1080#1083#1100':'
  end
  object BtnApplay: TButton
    Left = 160
    Top = 312
    Width = 129
    Height = 25
    Cancel = True
    Caption = #1055#1056#1048#1052#1045#1053#1048#1058#1068
    TabOrder = 0
    OnClick = BtnApplayClick
  end
  object SpEditHours: TSpinEdit
    Left = 16
    Top = 152
    Width = 57
    Height = 26
    MaxValue = 720
    MinValue = 0
    TabOrder = 1
    Value = 72
  end
  object edDefaultProjectDir: TEdit
    Left = 16
    Top = 72
    Width = 401
    Height = 24
    TabOrder = 2
  end
  object StTextDefReleasesDir: TStaticText
    Left = 16
    Top = 16
    Width = 433
    Height = 49
    AutoSize = False
    Caption = 
      #1044#1080#1088#1077#1082#1090#1086#1088#1080#1103' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102' '#1076#1083#1103' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103' '#1092#1072#1081#1083#1086#1074' '#1085#1086#1074#1099#1093' '#1088#1077#1083#1080#1079#1086#1074'.'#13#10#1045#1089 +
      #1083#1080' '#1076#1080#1088#1077#1082#1090#1086#1088#1080#1103' '#1085#1077' '#1073#1091#1076#1077#1090' '#1091#1082#1072#1079#1072#1085#1072' '#1090#1086' '#1073#1091#1076#1077#1090' '#1091#1082#1072#1079#1072#1085' '#1087#1091#1090#1100' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102 +
      ':'#13#10'<User profile>\Downloads\GitHubReleasesTracker\<project name>'
    TabOrder = 3
  end
  object cbxVclStyles: TComboBox
    Left = 120
    Top = 204
    Width = 217
    Height = 24
    Style = csDropDownList
    Anchors = [akLeft, akBottom]
    TabOrder = 4
    OnSelect = cbxVclStylesSelect
  end
  object BtnClose: TButton
    Left = 376
    Top = 312
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 5
    OnClick = BtnCloseClick
  end
end
