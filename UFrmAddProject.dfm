object FrmAddProject: TFrmAddProject
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1099' '#1087#1088#1086#1077#1082#1090
  ClientHeight = 483
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object sLblPojectLink: TsLabel
    Left = 16
    Top = 16
    Width = 140
    Height = 13
    Caption = 'C'#1089#1099#1083#1082#1072' '#1087#1088#1086#1077#1082#1090#1072' '#1085#1072' GitHub: '
  end
  object sLblProjectDir: TsLabel
    Left = 16
    Top = 72
    Width = 435
    Height = 26
    Caption = 
      #1044#1080#1088#1077#1082#1090#1086#1088#1080#1103' '#1076#1083#1103' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103' '#1088#1077#1083#1080#1079#1086#1074' '#1101#1090#1086#1075#1086' '#1087#1088#1086#1077#1082#1090#1072': '#13#10'('#1087#1091#1090#1100' '#1087#1086' '#1091#1084#1086#1083 +
      #1095#1072#1085#1080#1102' <User profile>\Downloads\GitHubReleasesTracker\<project na' +
      'me>)'
  end
  object sLblFilter: TsLabel
    Left = 16
    Top = 296
    Width = 208
    Height = 13
    Caption = #1060#1080#1083#1100#1090#1088' ('#1074#1087#1080#1096#1080#1090#1077' '#1089#1083#1086#1074#1072' '#1095#1077#1088#1077#1079' '#1079#1072#1087#1103#1090#1091#1102'):'
  end
  object sBtnApply: TsButton
    Left = 216
    Top = 440
    Width = 145
    Height = 33
    Caption = #1044' '#1054' '#1041' '#1040' '#1042' '#1048' '#1058' '#1068
    TabOrder = 0
    OnClick = sBtnApplyClick
  end
  object sEdProjectLink: TsEdit
    Left = 16
    Top = 32
    Width = 441
    Height = 21
    TabOrder = 1
    Text = 'https://github.com/superbot-coder/chia_plotting_tools'
    OnChange = sEdProjectLinkChange
  end
  object sDirEdSaveDir: TsDirectoryEdit
    Left = 16
    Top = 104
    Width = 441
    Height = 21
    MaxLength = 255
    TabOrder = 2
    Text = ''
    CheckOnExit = True
    Root = 'rfDesktop'
  end
  object sChBoxSubDir: TsCheckBox
    Left = 16
    Top = 144
    Width = 212
    Height = 17
    Caption = #1044#1083#1103' '#1082#1072#1078#1076#1086#1075#1086' '#1088#1077#1083#1080#1079#1072' '#1089#1091#1073#1076#1080#1088#1077#1082#1090#1086#1088#1080#1103
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object sRGRulesNotis: TsRadioGroup
    Left = 344
    Top = 160
    Width = 225
    Height = 121
    Caption = #1055#1088#1072#1074#1080#1083#1072':'
    TabOrder = 4
    ItemIndex = 0
    Items.Strings = (
      #1058#1086#1083#1100#1082#1086' '#1091#1074#1077#1076#1086#1084#1083#1103#1090#1100
      #1059#1074#1077#1076#1086#1084#1083#1103#1090#1100' '#1080' '#1089#1082#1072#1095#1080#1074#1072#1090#1100
      #1057#1082#1072#1095#1080#1074#1072#1090#1100' '#1073#1077#1079' '#1091#1074#1077#1076#1086#1084#1083#1077#1085#1080#1081)
  end
  object sRGRuleDownload: TsRadioGroup
    Left = 16
    Top = 208
    Width = 297
    Height = 73
    Caption = #1055#1088#1080#1074#1080#1083#1072' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103' '#1092#1072#1081#1083#1086#1074
    TabOrder = 5
    ItemIndex = 0
    Items.Strings = (
      #1057#1082#1072#1095#1080#1074#1072#1090#1100' '#1074#1089#1077' '#1092#1072#1081#1083#1099
      #1057#1082#1072#1095#1080#1074#1072#1090#1100' '#1080#1089#1087#1086#1083#1100#1079#1091#1103' '#1092#1080#1083#1100#1090#1088)
  end
  object sEdFilter: TsEdit
    Left = 16
    Top = 312
    Width = 553
    Height = 21
    TabOrder = 6
    Text = 'windows, win, win64, zip, rar'
  end
  object sPnlImage: TsPanel
    Left = 472
    Top = 16
    Width = 97
    Height = 113
    BevelOuter = bvLowered
    TabOrder = 7
    object sImagProject: TsImage
      Left = 8
      Top = 8
      Width = 80
      Height = 80
      Align = alCustom
      Picture.Data = {07544269746D617000000000}
      Stretch = True
    end
    object sLblAvatar: TsLabel
      Left = 25
      Top = 93
      Width = 41
      Height = 13
      Caption = '(Avatar)'
    end
  end
  object sChBoxDownloadLastRelease: TsCheckBox
    Left = 16
    Top = 176
    Width = 288
    Height = 17
    Caption = #1057#1082#1072#1095#1072#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1080#1081' '#1088#1077#1083#1080#1079' '#1087#1088#1080' '#1076#1086#1073#1072#1074#1083#1077#1085#1085#1080' '#1087#1088#1086#1077#1082#1090#1072
    TabOrder = 8
  end
  object mm: TsMemo
    Left = 16
    Top = 344
    Width = 553
    Height = 81
    Lines.Strings = (
      'mm')
    ScrollBars = ssVertical
    TabOrder = 9
    Text = 'mm'
    BoundLabel.ParentFont = False
  end
  object sSkinProvider: TsSkinProvider
    AddedTitle.Font.Charset = DEFAULT_CHARSET
    AddedTitle.Font.Color = clNone
    AddedTitle.Font.Height = -11
    AddedTitle.Font.Name = 'Tahoma'
    AddedTitle.Font.Style = []
    SkinData.SkinSection = 'FORM'
    TitleButtons = <>
    Left = 56
    Top = 360
  end
end
