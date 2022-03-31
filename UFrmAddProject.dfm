object FrmAddProject: TFrmAddProject
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1099#1081' '#1087#1088#1086#1077#1082#1090
  ClientHeight = 551
  ClientWidth = 587
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object LblUrlProject: TLabel
    Left = 16
    Top = 16
    Width = 140
    Height = 13
    Caption = 'C'#1089#1099#1083#1082#1072' '#1087#1088#1086#1077#1082#1090#1072' '#1085#1072' GitHub: '
  end
  object SpdBtnOpenDir: TSpeedButton
    Left = 440
    Top = 104
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SpdBtnOpenDirClick
  end
  object edProjectLink: TEdit
    Left = 16
    Top = 32
    Width = 441
    Height = 21
    MaxLength = 1000
    TabOrder = 0
    Text = 'https://github.com/superbot-coder/chia_plotting_tools'
    OnChange = edProjectLinkChange
  end
  object statTextProjectDir: TStaticText
    Left = 16
    Top = 72
    Width = 441
    Height = 25
    AutoSize = False
    Caption = 
      #1044#1080#1088#1077#1082#1090#1086#1088#1080#1103' '#1076#1083#1103' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103' '#1088#1077#1083#1080#1079#1086#1074' '#1101#1090#1086#1075#1086' '#1087#1088#1086#1077#1082#1090#1072': '#13#10'('#1087#1091#1090#1100' '#1087#1086' '#1091#1084#1086#1083 +
      #1095#1072#1085#1080#1102' <User profile>\Downloads\GitHubReleasesTracker\<project na' +
      'me>)'
    TabOrder = 1
  end
  object ChBoxSubDir: TCheckBox
    Left = 16
    Top = 144
    Width = 209
    Height = 17
    Caption = #1044#1083#1103' '#1082#1072#1078#1076#1086#1075#1086' '#1088#1077#1083#1080#1079#1072' '#1089#1091#1073#1076#1080#1088#1077#1082#1090#1086#1088#1080#1103
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object ChBoxDownloadLastRelease: TCheckBox
    Left = 16
    Top = 192
    Width = 281
    Height = 17
    Caption = #1057#1082#1072#1095#1072#1090#1100' '#1092#1072#1081#1083#1099' '#1088#1077#1083#1080#1079#1072' '#1087#1086#1089#1083#1077' '#1076#1086#1073#1072#1074#1083#1077#1085#1080#1103' '#1087#1088#1086#1077#1082#1090#1072
    TabOrder = 3
  end
  object mm: TMemo
    Left = 16
    Top = 408
    Width = 553
    Height = 89
    TabOrder = 4
  end
  object Panel: TPanel
    Left = 472
    Top = 16
    Width = 97
    Height = 113
    BevelOuter = bvLowered
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    TabOrder = 5
    object ImagProject: TImage
      Left = 8
      Top = 8
      Width = 81
      Height = 81
      Stretch = True
    end
    object LblAvatar: TLabel
      Left = 27
      Top = 96
      Width = 41
      Height = 13
      Caption = '(Avatar)'
    end
  end
  object BtnApply: TButton
    Left = 216
    Top = 512
    Width = 145
    Height = 30
    Caption = #1044' '#1054' '#1041' '#1040' '#1042' '#1048' '#1058' '#1068
    TabOrder = 6
    OnClick = BtnApplyClick
  end
  object edSaveDir: TEdit
    Left = 16
    Top = 104
    Width = 417
    Height = 21
    MaxLength = 256
    TabOrder = 7
  end
  object RGRulesNotis: TRadioGroup
    Left = 344
    Top = 176
    Width = 225
    Height = 121
    Caption = #1055#1088#1072#1074#1080#1083#1072':'
    ItemIndex = 0
    Items.Strings = (
      #1058#1086#1083#1100#1082#1086' '#1091#1074#1077#1076#1086#1084#1083#1103#1090#1100
      #1059#1074#1077#1076#1086#1084#1083#1103#1090#1100' '#1080' '#1089#1082#1072#1095#1080#1074#1072#1090#1100
      #1057#1082#1072#1095#1080#1074#1072#1090#1100' '#1073#1077#1079' '#1091#1074#1077#1076#1086#1084#1083#1077#1085#1080#1081)
    TabOrder = 8
  end
  object RGRuleDownload: TRadioGroup
    Left = 16
    Top = 224
    Width = 297
    Height = 73
    Caption = #1055#1088#1080#1074#1080#1083#1072' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103' '#1092#1072#1081#1083#1086#1074
    ItemIndex = 0
    Items.Strings = (
      #1057#1082#1072#1095#1080#1074#1072#1090#1100' '#1074#1089#1077' '#1092#1072#1081#1083#1099
      #1057#1082#1072#1095#1080#1074#1072#1090#1100' '#1080#1089#1087#1086#1083#1100#1079#1091#1103' '#1092#1080#1083#1100#1090#1088)
    TabOrder = 9
  end
  object GrBoxFilter: TGroupBox
    Left = 16
    Top = 312
    Width = 553
    Height = 81
    Caption = #1060#1080#1083#1100#1090#1088' ('#1074#1087#1080#1096#1080#1090#1077' '#1089#1083#1086#1074#1072' '#1095#1077#1088#1077#1079' '#1079#1072#1087#1103#1090#1091#1102'):'
    TabOrder = 10
    object LblExclude: TLabel
      Left = 272
      Top = 28
      Width = 61
      Height = 13
      Caption = #1048#1089#1082#1083#1102#1095#1080#1090#1100':'
    end
    object LblInclude: TLabel
      Left = 8
      Top = 28
      Width = 55
      Height = 13
      Caption = #1042#1082#1083#1102#1095#1080#1090#1100':'
    end
    object EdFilterInclude: TEdit
      Left = 8
      Top = 44
      Width = 249
      Height = 21
      TabOrder = 0
      Text = 'windows, win, win64, 64bit'
    end
    object edFilterExclude: TEdit
      Left = 272
      Top = 44
      Width = 265
      Height = 21
      TabOrder = 1
      Text = 'mac, linux, 32bit'
    end
  end
  object BtnClose: TButton
    Left = 472
    Top = 512
    Width = 97
    Height = 30
    Caption = #1047#1040#1050#1056#1067#1058#1068
    TabOrder = 11
    OnClick = BtnCloseClick
  end
  object ChBoxAddVerToFileName: TCheckBox
    Left = 16
    Top = 168
    Width = 249
    Height = 17
    Caption = #1055#1088#1080#1073#1072#1074#1083#1103#1090#1100' '#1082' '#1080#1084#1077#1085#1080' '#1092#1072#1081#1083#1072' '#1074#1077#1088#1089#1080#1102' '#1088#1077#1083#1080#1079#1072
    TabOrder = 12
  end
end
