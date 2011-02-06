object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'SoundBoard'
  ClientHeight = 172
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object MediaPlayer: TMediaPlayer
    Left = 88
    Top = 112
    Width = 253
    Height = 30
    Visible = False
    TabOrder = 0
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 0
    Width = 379
    Height = 10
    Align = alTop
    Max = 0
    Smooth = True
    TabOrder = 1
  end
  object ListBox: TListBox
    Left = 0
    Top = 10
    Width = 379
    Height = 162
    Align = alClient
    ItemHeight = 13
    PopupMenu = PopupMenu
    TabOrder = 2
    OnDblClick = ListBoxDblClick
    OnKeyPress = ListBoxKeyPress
  end
  object ProgressTimer: TTimer
    Interval = 100
    OnTimer = ProgressTimerTimer
    Left = 88
    Top = 48
  end
  object PopupMenu: TPopupMenu
    Left = 168
    Top = 48
  end
end
