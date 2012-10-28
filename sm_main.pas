unit SM_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, StdCtrls, sm_srv_base,sm_client_base, sm_types,sm_utils, sm_web;

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
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PageControl1: TPageControl;
    ManagerPopup: TPopupMenu;
    SMPanel: TPanel;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    TreeView1: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeView1Click(Sender: TObject);
    procedure InstallClick(Sender: TObject);
  private
    procedure LoadPackageToListView(aPackageItem: TPackageItem;idx: integer);
    procedure LoadToTreeView;
    procedure UpdateFileData(aFileItem: TFileItem);
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;
  Repository: TServerStorage;
    Local: TClientStorage;
  ManagerPopup: TPopupMenu;
  Index: integer;//current selected category index

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Repository := TServerStorage.Create();
  Repository.LoadFromXmlFile('server.xml');
 // Repository.ToFileItemEx;
 // Repository.SaveLocalXMLRegistry('E:\Coding\ScriptManager\saved_registry.xml');
  Local := TClientStorage.Create();
  Local.LoadLocalXMLRegistry('saved_registry.xml');
  Local.CheckStorage(Repository);
  Local.CheckUpdates(Repository);
  Local.UpdateLocalXMLRegistry('saved_registry.xml');
 // Local.Free;
  //Local:=TScriptStorage.Create;
  //Local.LoadLocalXMLRegistry('E:\Coding\ScriptManager\saved_registry_up.xml');
 // Local.UpdateLocalXMLRegistry('E:\Coding\ScriptManager\saved_registry_up.xml',Repository);
  //Repository.SaveLocalXMLRegistry('j:\test.xml');
  LoadToTreeView;
end;


procedure TForm1.ListView1Click(Sender: TObject);
begin
  if not assigned(ListView1.Selected) then exit;
  UpdateFileData (TFileItem(ListView1.Selected.Data));
end;

procedure TForm1.ListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  oFileItem: TFileItemEx;
begin
  if not assigned(ListView1.Selected) then exit;
  if (button=mbRight)  then
   begin
     oFileItem:=Local.Items[index].Files.ItemsEx[ListView1.Selected.Index];
     case oFileItem.Installed of
       0:ManagerPopup.Items[0].Caption:='Install';
       1:ManagerPopup.Items[0].Caption:='Uninstall';
    end;
     ManagerPopup.PopUp;
   end;
end;


procedure TForm1.TreeView1Click(Sender: TObject);
begin
    if not assigned(TreeView1.Selected) then exit;
    index:=TreeView1.Selected.Index;
    LoadPackageToListView(TPackageItem(TreeView1.Selected.Data),Index);
    UpdateFileData (TFileItem(ListView1.Items[0].Data));
end;

procedure TForm1.InstallClick(Sender: TObject);
var
   oFileItem: TFileItemEx;
begin
   oFileItem:=Local.Items[index].Files.ItemsEx[ListView1.Selected.Index];
   ShowMessage(GetPackageUrl(oFileItem.filename));
   case oFileItem.Installed of
       0:oFileItem.Installed:=1;
       1:oFileItem.Installed:=0;
    end;
   Local.Items[index].Files.ItemsEx[ListView1.Selected.Index].Installed:=oFileItem.Installed;
   Local.UpdateLocalXMLRegistry('saved_registry.xml');
   LoadPackageToListView(Local.Items[index],index);
  // oFileItem

end;

procedure TForm1.LoadPackageToListView(aPackageItem: TPackageItem;idx: integer);
var
  I: Integer;
  oListItem: TListItem;
  oFileItem: TFileItemEx;
begin
  ListView1.Items.Clear;
  for I := 0 to aPackageItem.Files.Count - 1 do
  begin
    oListItem:= ListView1.Items.Add;

//    oListItem:= ListView1.AddItem(aPackageItem.Files[i].FileName, aPackageItem.Files[i]);

    oListItem.Data:=aPackageItem.Files[i];
    oListItem.Caption:=aPackageItem.Files[i].FileName;
    oListItem.SubItems.Add(aPackageItem.Files[i].Author);
    oListItem.SubItems.Add(aPackageItem.Files[i].EMail);
    oListItem.SubItems.Add(DateToStr(aPackageItem.Files[i].DateModify));
    oFileItem:=local.items[idx].Files.ItemsEx[i];
    case oFileItem.Installed of
    0:begin oListItem.SubItems.Add(FloatToStr(aPackageItem.Files[i].Version)); oListItem.SubItems.Add('Not installed'); end;
    1:begin
         if oFileItem.update > 0 then
             oListItem.SubItems.Add(FloatToStr(oFileItem.version)+'<'+FloatToStr(aPackageItem.Files[i].Version))
             else
               oListItem.SubItems.Add(FloatToStr(oFileItem.version));
         oListItem.SubItems.Add('Installed');
       end;
    end;
    UpdateFileData(TFileItem(oListItem.Data));
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
  for I := 0 to Repository.Count - 1 do
    //TreeView1.Items.AddObject(nil, FConfig.Items[i].Name, FConfig.Items[i]);
  begin
     TempNode:=TreeView1.Items.Add(nil,Repository.Items[i].Name);
     TempNode.Data:=Repository.Items[i];
  end;
  Index:=0;
  LoadPackageToListView(TPackageItem(Repository.Items[0]),0);
end;

procedure TForm1.UpdateFileData(aFileItem: TFileItem);
var
  I: Integer;
  sItem: TSubItem;
begin
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

