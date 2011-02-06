unit frmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MPlayer, IniFiles, ComCtrls, StdCtrls, ExtCtrls, DFHotKey, Contnrs,
  Menus;

type
  TMainForm = class(TForm)
    MediaPlayer: TMediaPlayer;
    ProgressBar: TProgressBar;
    ListBox: TListBox;
    ProgressTimer: TTimer;
    PopupMenu: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure ProgressTimerTimer(Sender: TObject);
    procedure ListBoxKeyPress(Sender: TObject; var Key: Char);
  private
    { Private-Deklarationen }
    FIniFile: TIniFile;
    FCurSection: Integer;
    FCurFiles: TStringList;
    FHotKeys: TObjectList;
    procedure LoadSections;
    procedure LoadSection(NewSection: Integer);
    procedure HandleEntry(const Name, Value: String);
    procedure PlayHotKey(Sender: TObject);
    procedure Play(Index: Integer);
    procedure CreateHotKey(ShortCut: String; Index: Integer);
    procedure UpMenuItemClick(Sender: TObject);
    procedure DownMenuItemClick(Sender: TObject);
    procedure LoadMenuItemClick(Sender: TObject);
    procedure ClosePlayer;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

const
  CAPTION_TEMPLATE = '%s - SoundBoard';

implementation

{$R *.dfm}

procedure TMainForm.ClosePlayer;
begin
  ProgressBar.Max := 0;
  MediaPlayer.Close;
end;

procedure TMainForm.CreateHotKey(ShortCut: String; Index: Integer);
var
  HotKey: TDFAppHotKey;
  LKey: Word;
  LShiftState: TShiftState;
  LShortCut: TShortCut;
begin
  LShortCut := TextToShortCut(Shortcut);
  if LShortCut > 0 then
  begin
    HotKey := TDFAppHotKey.Create(Self);
    HotKey.Tag := Index;
    HotKey.OnHotKey := PlayHotKey;
    ShortCutToKey(LShortCut, LKey, LShiftState);
    case LKey of
      Ord('A')..Ord('Z'):
        HotKey.Key := DFHotKeys(LKey - Ord('A') + Ord(Key_A));
      Ord('0')..Ord('9'):
        HotKey.Key := DFHotKeys(LKey - Ord('0') + Ord(Key_0));
      Ord(VK_F1)..Ord(VK_F12):
        HotKey.Key := DFHotKeys(LKey - Ord(VK_F1) + Ord(Key_F1));
    end;
    if ssShift in LShiftState then
      HotKey.Shift := True;
    if ssAlt in LShiftState then
      HotKey.Alt := True;
    if ssCtrl in LShiftState then
      HotKey.Ctrl := True;
    HotKey.Enabled := True;
  end;
end;

procedure TMainForm.DownMenuItemClick(Sender: TObject);
begin
  LoadSection(FCurSection - 1);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FIniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  FCurSection := 0;
  FCurFiles := TStringList.Create;

  FHotKeys := TObjectList.Create;
  FHotKeys.OwnsObjects := True;

  LoadSections;
  LoadSection(0);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FHotKeys.Free;
  FIniFile.Free;
  FCurFiles.Free;
end;

procedure TMainForm.HandleEntry(const Name, Value: String);
var
  p: Integer;
begin
  p := Pos(';', Value);
  if p > 0 then
  begin
    FCurFiles.Append(Copy(Value, 1, p-1));
    ListBox.Items.Append(Name + ' -- ' + Copy(Value, p+1, Length(Value)));
  end
  else
  begin
    FCurFiles.Append(Value);
    ListBox.Items.Append(Name + ' -- ' + Value);
  end;
  CreateHotKey(Name, ListBox.Items.Count - 1);
end;

procedure TMainForm.ListBoxDblClick(Sender: TObject);
begin
  Play(ListBox.ItemIndex);
end;

procedure TMainForm.ListBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Play(ListBox.ItemIndex);
end;

procedure TMainForm.LoadMenuItemClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  if Sender is TMenuItem then
  begin
    MenuItem := Sender as TMenuItem;
    LoadSection(MenuItem.Tag);
  end;
end;

procedure TMainForm.LoadSection(NewSection: Integer);
var
  List: TStringList;
  s: String;
  i: Integer;
begin
  List := TStringList.Create;
  try
    FIniFile.ReadSections(List);

    if (NewSection < List.Count) and (NewSection >= 0) then
    begin
      ClosePlayer;

      FHotKeys.Clear;
      ListBox.Clear;
      FCurFiles.Clear;

      s := List.Strings[NewSection];
      FCurSection := NewSection;

      PopupMenu.Items[NewSection + 3].Checked := True;

      Caption := Format(CAPTION_TEMPLATE, [s]);
      Application.Title := Caption;

      FIniFile.ReadSectionValues(s, List);
      for i := 0 to List.Count - 1 do
        HandleEntry(List.Names[i], List.ValueFromIndex[i]);

      ListBox.ItemIndex := 0;
    end;
  finally
    List.Free;
  end;
end;

procedure TMainForm.LoadSections;
var
  List: TStringList;
  i: Integer;
  Item: TMenuItem;
begin
  PopupMenu.Items.Clear;

  PopupMenu.Items.Add(NewItem('Weiter', ShortCut(VK_UP, [ssCtrl]), False, True, UpMenuItemClick, 0, ''));
  PopupMenu.Items.Add(NewItem('Zurück', ShortCut(VK_DOWN, [ssCtrl]), False, True, DownMenuItemClick, 0, ''));
  PopupMenu.Items.Add(NewItem('-', 0, False, True, nil, 0, ''));

  List := TStringList.Create;
  try
    FIniFile.ReadSections(List);

    for i := 0 to List.Count - 1 do
    begin
      Item := NewItem(List.Strings[i], 0, False, True, LoadMenuItemClick, 0, '');
      Item.GroupIndex := 1;
      Item.RadioItem := True;
      Item.Tag := i;
      PopupMenu.Items.Add(Item);
    end;
  finally
    List.Free;
  end;
end;

procedure TMainForm.Play(Index: Integer);
var
  FileName: String;
begin
  if (Index >= 0) and (Index < FCurFiles.Count) then
  begin
    ClosePlayer;
    FileName := FCurFiles.Strings[Index];
    ListBox.ItemIndex := Index;
    if FileExists(FileName) then
    begin
      MediaPlayer.FileName := FileName;
      MediaPlayer.Open;
      ProgressBar.Max := MediaPlayer.Length;
      MediaPlayer.Play;
    end;
  end;
end;

procedure TMainForm.PlayHotKey(Sender: TObject);
var
  HotKey: TDFAppHotKey;
begin
  if Sender is TDFAppHotKey then
  begin
    HotKey := Sender as TDFAppHotKey;
    Play(HotKey.Tag);
  end;
end;

procedure TMainForm.ProgressTimerTimer(Sender: TObject);
begin
  if ProgressBar.Max > 0 then
    ProgressBar.Position := MediaPlayer.Position;
end;

procedure TMainForm.UpMenuItemClick(Sender: TObject);
begin
  LoadSection(FCurSection + 1);
end;

end.
