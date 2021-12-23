object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'FrmMain'
  ClientHeight = 527
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    788
    527)
  PixelsPerInch = 96
  TextHeight = 13
  object sLVProj: TsListView
    Left = 8
    Top = 16
    Width = 774
    Height = 353
    BoundLabel.ParentFont = False
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #8470
        MaxWidth = 70
        MinWidth = 30
      end
      item
        Caption = #1048#1084#1103' '#1087#1088#1086#1077#1082#1090#1072
        MaxWidth = 300
        MinWidth = 100
        Width = 180
      end
      item
        Alignment = taCenter
        Caption = #1042#1077#1088#1089#1080#1103
        MaxWidth = 300
        MinWidth = 100
        Width = 180
      end
      item
        Alignment = taCenter
        Caption = #1044#1072#1090#1072' '#1088#1077#1083#1080#1079#1072
        MaxWidth = 300
        MinWidth = 100
        Width = 180
      end
      item
        Alignment = taCenter
        Caption = #1055#1086#1089#1083#1077#1076#1085#1103#1103' '#1087#1088#1086#1074#1077#1088#1082#1072
        MaxWidth = 300
        MinWidth = 100
        Width = 180
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object MainMenu: TMainMenu
    Left = 184
    Top = 168
    object U1: TMenuItem
      Caption = #1043#1083#1072#1074#1085#1086#1077
      object MM_AddReleases: TMenuItem
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1087#1088#1086#1077#1082#1090
        OnClick = MM_AddReleasesClick
      end
    end
  end
  object sSkinManager: TsSkinManager
    ButtonsOptions.OldGlyphsMode = True
    InternalSkins = <>
    SkinDirectory = 'C:\PROJECT+\COMPONENTS\AlphaSkins\askins_v14\Skins'
    SkinInfo = 'N/A'
    ThirdParty.ThirdEdits = ' '
    ThirdParty.ThirdButtons = 'TButton'
    ThirdParty.ThirdBitBtns = ' '
    ThirdParty.ThirdCheckBoxes = ' '
    ThirdParty.ThirdGroupBoxes = ' '
    ThirdParty.ThirdListViews = ' '
    ThirdParty.ThirdPanels = ' '
    ThirdParty.ThirdGrids = ' '
    ThirdParty.ThirdTreeViews = ' '
    ThirdParty.ThirdComboBoxes = ' '
    ThirdParty.ThirdWWEdits = ' '
    ThirdParty.ThirdVirtualTrees = ' '
    ThirdParty.ThirdGridEh = ' '
    ThirdParty.ThirdPageControl = ' '
    ThirdParty.ThirdTabControl = ' '
    ThirdParty.ThirdToolBar = ' '
    ThirdParty.ThirdStatusBar = ' '
    ThirdParty.ThirdSpeedButton = ' '
    ThirdParty.ThirdScrollControl = ' '
    ThirdParty.ThirdUpDown = ' '
    ThirdParty.ThirdScrollBar = ' '
    ThirdParty.ThirdStaticText = ' '
    ThirdParty.ThirdNativePaint = ' '
    Left = 272
    Top = 168
  end
  object ImgListProj: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Left = 368
    Top = 168
  end
  object RESTClient: TRESTClient
    Params = <>
    Left = 184
    Top = 232
  end
  object RESTRequest: TRESTRequest
    Client = RESTClient
    Params = <>
    Response = RESTResponse
    SynchronizedEvents = False
    Left = 272
    Top = 232
  end
  object RESTResponse: TRESTResponse
    Left = 368
    Top = 232
  end
end
