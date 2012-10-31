unit SM_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ExtCtrls, StdCtrls, sm_srv_base,sm_client_base, sm_types,sm_utils, sm_web,sm_settings, sm_control;

type

  { TForm1 }

  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    btns: TImageList;
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
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    TreeView1: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure InstallClick(Sender: TObject);
  private
    procedure LoadPackageToListView(aPackageItem: TPackageItem;idx: integer);
    procedure LoadToTreeView;
    procedure UpdateFileData(aFileItem: TFileItem);
    procedure UpdateStats();
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1;
  Repository: TServerStorage;
    Local: TClientStorage;
    Loader: TDownloader;
  ManagerPopup: TPopupMenu;
  Index: integer;//current selected category index
  option: TOption;//just test options system

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  XML: TMemoryStream;
  begin
SetOptionsPaths('http://localhost/','saved_registry.xml','C:/Simba_2/',option);
  XML:=TMemoryStream.Create;
  Loader:=Tdownloader.Create(option.XMLSrvDesc+'server.xml');
  loader.Download(XML);
  XML.Position:=0;
  Repository := TServerStorage.Create();
  Repository.LoadFromXmlStream(XML);
 // Repository.ToFileItemEx;
 // Repository.SaveLocalXMLRegistry('saved_registry.xml');
  Local := TClientStorage.Create();
  Local.LoadLocalXMLRegistry(option.XMLStorage);
  Local.CheckUpdates(Repository);
  UpdateStats;
  Local.UpdateLocalXMLRegistry(option.XMLStorage);
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
     if oFileItem.Update> 0 then
      ManagerPopup.Items[0].Caption:='Update';
     ManagerPopup.PopUp;
   end;
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  local.UpdateLocalXMLRegistry(option.XMLStorage);
  local.Free;
  repository.Free;
  loader.Free;
 Application.Terminate;
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
  loc: TFileItemEx;
   rep: TFileItem;
   sItem: TSubItem;
   i: integer;
begin
   rep:=Repository.Items[index].Files.Items[ListView1.Selected.Index];
   loc:= Local.Items[index].Files.ItemsEx[ListView1.Selected.Index];
  // getScript(rep,option);
   //ShowMessage(GetPackageUrl(oFileItem.filename));  //just function testing
   case  loc.Installed of
       0:begin loc.Installed:=1; getScript(rep,option);  end;
       1:begin loc.Installed:=0; RemoveScript(rep,option); end;
    end;
    loc.Version:=rep.Version;
    loc.DateModify:=rep.DateModify;
 {
   if rep.SubFiles.Count > 0 then
    begin
    oFileItem.SubFiles.Clear;
     for i:=0 to rep.SubFiles.Count-1 do
      begin
        sItem:=oFileItem.SubFiles.AddItem;
        sItem.FileName:=rep.SubFiles[i].FileName;
        sItem.UnpPath:=rep.SubFiles[i].UnpPath;
      end;
    end else
    begin
    oFileItem.SubFiles.Clear;
    for i:=0 to rep.SubFiles.Count-1 do
      begin
        sItem:=oFileItem.SubFiles.AddItem;
        sItem.FileName:=rep.SubFiles[i].FileName;
        sItem.UnpPath:=rep.SubFiles[i].UnpPath;
      end;
    end;  }
    loc.Author:=rep.Author;
    loc.EMail:=rep.EMail;
    loc.FileName:=rep.FileName;
   UpdateStats;
   Local.UpdateLocalXMLRegistry('saved_registry.xml');
   LoadPackageToListView(Repository.Items[index],index);
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
    UpdateFileData(aPackageItem.Files[i]);
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

procedure TForm1.UpdateStats();
procedure UpdateStatusBar(category ,scripts, installed, updates: integer);
begin
 with StatusBar1 do
  begin
   Panels[0].Text:='Categories:'+#13+IntToStr(category);
   Panels[1].Text:='Scripts:'+#13+IntToStr(scripts);
   Panels[2].Text:='Installed:'+#13+IntToStr(installed);
   Panels[3].Text:='Available updates:'+#13+IntToStr(updates);
  end;
end;
var
  i,j: integer;
  installed,updates: integer;
  catcount, scriptcount: integer;
  CatItem: TPackageItem;
  ExItem: TFileItemEx;
begin
  Local.CheckStorage(Repository);
  catcount:=Repository.Count;
  scriptcount:=0;
  installed:=0;
  updates:=0;
  for i:=0 to Repository.Count -1 do
   begin
     CatItem:=Repository.Items[i];
     scriptcount:=scriptcount+CatItem.Files.Count;
   end;
  for i:=0 to local.Count-1 do
    begin
      for j:=0 to local.Items[i].Files.Count-1 do
        begin
          ExItem:=local.Items[i].Files.ItemsEx[j];
          if ExItem.Installed > 0 then inc(installed);
          if ExItem.Update > 0 then inc(updates);
        end;
    end;
  UpdateStatusBar(catcount,scriptcount,installed,updates);
end;

end.

