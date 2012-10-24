unit SM_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, StdCtrls, sm_base, sm_types, sm_web;

type

  { TForm1 }

  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    ListBox1: TListBox;
    ListView1: TListView;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PageControl1: TPageControl;
    SMPanel: TPanel;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    TreeView1: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView1Click(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
  private
    procedure LoadPackageToListView(aPackageItem: TPackageItem);
    procedure LoadToTreeView;
    procedure UpdateFileData(aFileItem: TFileItem);
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;
  FConfig: TConfig;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FConfig := TConfig.Create();
  FConfig.LoadFromXmlFile('j:\server.xml');
  LoadToTreeView;
end;

procedure TForm1.ListView1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin

end;

procedure TForm1.ListView1Click(Sender: TObject);
begin
  if not assigned(ListView1.Selected) then exit;
  UpdateFileData (TFileItem(ListView1.Selected.Data));
end;


procedure TForm1.TreeView1Click(Sender: TObject);
begin
    if not assigned(TreeView1.Selected) then exit;
    LoadPackageToListView(TPackageItem(TreeView1.Selected.Data));
    UpdateFileData (TFileItem(ListView1.Items[0].Data));
end;

procedure TForm1.LoadPackageToListView(aPackageItem: TPackageItem);
var
  I: Integer;
  oListItem: TListItem;
begin
  ListView1.Items.Clear;
 // oListItem:= ListView1.Items.Add;
//    oListItem:= ListView1.AddItem(aPackageItem.Files[i].FileName, aPackageItem.Files[i]);
 //
 // oListItem.Data:=aPackageItem.Files[i];
//  oListItem.Caption:='1';
//  oListItem.SubItems.Add('2');
//  Memo1.Lines.Text:=aPackageItem.
  //d:= aPackageItem.Files.GetCount();

  for I := 0 to aPackageItem.Files.Count - 1 do
  begin
    oListItem:= ListView1.Items.Add;

//    oListItem:= ListView1.AddItem(aPackageItem.Files[i].FileName, aPackageItem.Files[i]);

    oListItem.Data:=aPackageItem.Files[i];

    oListItem.Caption:=aPackageItem.Files[i].FileName;
    oListItem.SubItems.Add(aPackageItem.Files[i].Author);
    oListItem.SubItems.Add(aPackageItem.Files[i].EMail);

    //Items.AddObject(nil, FConfig.Items[i].Name, FConfig.Items[i]);

  end;


  if aPackageItem.Files.Count = 0 then
    UpdateFileData(nil);
 // Exit;
//  if aPackageItem.Files.Count > 0 then
 //   UpdateFileData(TFileItem(ListView1.Items[0].Data));

end;

procedure TForm1.LoadToTreeView;
var
  I: Integer;
  TempNode: TTreeNode;
begin
  TreeView1.Items.Clear;
  for I := 0 to FConfig.Count - 1 do
    //TreeView1.Items.AddObject(nil, FConfig.Items[i].Name, FConfig.Items[i]);
  begin
     TempNode:=TreeView1.Items.Add(nil,FConfig.Items[i].Name);
     TempNode.Data:=FConfig.Items[i];
  end;

  LoadPackageToListView(TPackageItem(FConfig.Items[0]));
end;

procedure TForm1.UpdateFileData(aFileItem: TFileItem);
var
  I: Integer;
  sItem: TSubItem;
begin
//  Exit;
//  Assert(Assigned(aFileItem));
  ListBox1.Items.Clear;
  Memo1.Lines.Text:='';

  if not Assigned(aFileItem) then
   Exit;


  Memo1.Lines.Text:=aFileItem.Description;

  for I := 0 to aFileItem.SubFiles.Count - 1 do
  begin
     sItem:=TSubItem(aFileItem.SubFiles[i]);
     ListBox1.Items.Add (sItem.FileName);
  end;

end;

end.

