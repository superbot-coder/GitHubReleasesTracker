object FrmDownloadFiles: TFrmDownloadFiles
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1057#1082#1072#1095#1080#1074#1072#1085#1080#1077' '#1092#1072#1081#1083#1086#1074
  ClientHeight = 445
  ClientWidth = 542
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LVFiles: TListView
    Left = 8
    Top = 72
    Width = 521
    Height = 329
    Checkboxes = True
    Columns = <
      item
        Caption = #1060#1072#1081#1083#1099' '#1076#1083#1103' '#1089#1082#1072#1095#1080#1074#1072#1085#1080#1103
        Width = 300
      end
      item
        Alignment = taCenter
        Caption = #1056#1072#1079#1084#1077#1088
        Width = 100
      end
      item
        Alignment = taCenter
        Caption = #1057#1090#1072#1090#1091#1089
        Width = 100
      end>
    ReadOnly = True
    RowSelect = True
    SmallImages = ImageList
    TabOrder = 0
    ViewStyle = vsReport
  end
  object BtnApply: TButton
    Left = 184
    Top = 408
    Width = 153
    Height = 30
    Caption = #1057#1050#1040#1063#1040#1058#1068
    TabOrder = 1
    OnClick = BtnApplyClick
  end
  object BtnClose: TButton
    Left = 440
    Top = 408
    Width = 91
    Height = 30
    Caption = #1047#1040#1050#1056#1067#1058#1068
    TabOrder = 2
    OnClick = BtnCloseClick
  end
  object PnlBoard: TPanel
    Left = 0
    Top = 0
    Width = 542
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
  end
  object ImageList: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Left = 376
    Top = 208
    Bitmap = {
      494C010102000800040010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D9D7D5FF98918BFF98918BFFD9D7D5FF000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D0CDCAFF685E55FF685E55FF685E55FFC7C3BFFF000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000ECEBEAFF98918BFF685E55FF685E55FF685E55FF685E55FF98918BFFECEB
      EAFF000000000000000000000000000000000000000000000000C7C3BFFF8E87
      80FF00000000B4AFAAFF685E55FFB5B0ABFF685E55FFB4AFAAFF000000007A71
      69FF70675EFFBDB9B5FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F6F5F4FFB4AF
      AAFF70675EFF71685FFFB5B0ABFF8E8780FF857B74FFB5B0ABFF71685FFF7067
      5EFFB4AFAAFF000000000000000000000000000000000000000070675EFF9892
      8BFF00000000B4AFAAFF685E55FF00000000685E55FFB4AFAAFF00000000D0CD
      CAFF8F8881FF7A7169FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E3E1DFFF7A7169FF685E
      55FFA29C96FFECEBEAFF000000008E8780FF8E8780FF00000000ECEBEAFFA29C
      96FF685E55FF7A7169FFE3E1DFFF000000000000000000000000685E55FFB4AF
      AAFF00000000B4AFAAFF685E55FF00000000685E55FFB4AFAAFF000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007A7169FF867C74FFD9D7
      D5FF0000000000000000000000008E8780FF8E8780FF00000000000000000000
      0000D9D7D5FF867C74FF7A7169FF000000000000000000000000685E55FFB4AF
      AAFF00000000E3E1DFFF685E55FF685E55FF685E55FFE3E1DFFF000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000685E55FFB4AFAAFF0000
      00000000000000000000000000008E8780FF8E8780FF00000000000000000000
      000000000000B4AFAAFF685E55FF000000000000000000000000685E55FFB4AF
      AAFF0000000000000000E3E1DFFFB5B0ABFF98928BFFC7C3BFFF000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000685E55FFB4AFAAFF0000
      00000000000000000000000000008E8780FF8E8780FF00000000000000000000
      000000000000B4AFAAFF685E55FF000000000000000000000000685E55FFB4AF
      AAFF00000000000000000000000000000000857B74FF7A726AFF000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000685E55FFB4AFAAFF0000
      00000000000000000000F6F5F4FF857B74FF857B74FFF6F5F4FF000000000000
      000000000000B4AFAAFF685E55FF000000000000000000000000685E55FFB4AF
      AAFF00000000000000007A7169FF7A7169FF0000000000000000000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000685E55FFB4AFAAFF0000
      000000000000BDB9B5FF70675EFF685E55FF685E55FF70675EFFBDB9B5FF0000
      000000000000B4AFAAFF685E55FF000000000000000000000000685E55FFB4AF
      AAFF0000000000000000D0CDCAFFC7C3BFFFC7C3BFFFC7C3BFFF000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000685E55FFB4AFAAFFD9D7
      D5FF857B74FF685E55FF8F8881FFECEBEAFFE3E1DFFF8F8881FF685E55FF857B
      74FFD9D7D5FFB4AFAAFF685E55FF000000000000000000000000685E55FFB4AF
      AAFF00000000000000000000000000000000857B74FF7A726AFF000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000685E55FF70675EFF685E
      55FF7A726AFFD0CDCAFF00000000000000000000000000000000D0CDCAFF7A72
      6AFF685E55FF70675EFF685E55FF000000000000000000000000685E55FFB4AF
      AAFF00000000000000007A7169FF7A7169FF0000000000000000000000000000
      0000B4AFAAFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007A7169FF685E55FF9892
      8BFF000000000000000000000000000000000000000000000000000000000000
      000098918BFF685E55FF7A726AFF000000000000000000000000685E55FFB4AF
      AAFF0000000000000000D0CDCAFFC7C3BFFFC7C3BFFFC7C3BFFF000000000000
      000098918BFF685E55FF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E3E1DFFF7A726AFF685E
      55FFA19B95FFECEBEAFF00000000000000000000000000000000ECEBEAFFA19B
      95FF685E55FF7A726AFFE3E1DFFF000000000000000000000000685E55FFB4AF
      AAFF00000000000000000000000000000000857B74FF7A726AFF00000000A19B
      95FF685E55FFB4AFAAFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000B5B0
      ABFF71685FFF70675EFFB4AFAAFF0000000000000000B4AFAAFF70675EFF7168
      5FFFB5B0ABFF0000000000000000000000000000000000000000685E55FFB4AF
      AAFF00000000000000007A7169FF7A7169FF0000000000000000A19B95FF685E
      55FFA29C96FF0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000ECEBEAFF98928BFF685E55FF7A7169FF7A7169FF685E55FF98928BFFECEB
      EAFF0000000000000000000000000000000000000000000000007A7169FF8E87
      80FFB4AFAAFFB4AFAAFF857B74FF7A7169FFB4AFAAFF98918BFF685E55FFA29C
      96FF000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000D9D7D5FF98928BFF98928BFFD9D7D5FF000000000000
      0000000000000000000000000000000000000000000000000000C7C3BFFF7A72
      6AFF685E55FF685E55FF685E55FF685E55FF685E55FF685E55FFB5B0ABFF0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FC3FF83F00000000F00FC82300000000
      C007C923000000008241C933000000008E71C833000000009E79CC3300000000
      9E79CF33000000009C39CCF3000000009819CC33000000008001CF3300000000
      83C1CCF3000000008FF1CC330000000083C1CF2300000000E187CCC700000000
      F00FC00F00000000FC3FC01F0000000000000000000000000000000000000000
      000000000000}
  end
end
