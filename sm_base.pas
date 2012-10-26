unit sm_base;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants, DateUtils, XMLRead,XMLWrite,Dom,sm_types;

type
  //-------------------------------------------------------------------

  { TScriptStorage }

  TScriptStorage = class(TPackageList)
  //-------------------------------------------------------------------
 // private
  //  procedure ConvertFileItem(fItem: TFileItem;fItemEx: TFileItemEx);
  public
    procedure Compare(aConfig: TScriptStorage; aStrings: TStringList);
    procedure LoadFromXmlFile(aFileName: string);
    procedure LoadLocalXMLRegistry(aFileName: string);
    procedure SaveLocalXMLRegistry(aFileName: string);
    procedure UpdateLocalXMLRegistry(aFileName: string);
 //   procedure LoadTestDataFromDir(aDir: string);
  end;

implementation


//----------------------------------------------------------------
procedure TScriptStorage.Compare(aConfig: TScriptStorage; aStrings: TStringList);
//----------------------------------------------------------------
var
  I: Integer;
  j: Integer;
  k: Integer;
  oPackageItem1: TPackageItem;
  oPackageItem2: TPackageItem;

  oFileItem1: TFileItem;
  oFileItem2: TFileItem;
begin
  Assert(Assigned(aStrings));

  for I := 0 to Count - 1 do
  begin
    oPackageItem1:=Items[i];
    oPackageItem2:=TPackageItem(aConfig.FindItemID(i));

    if Assigned(oPackageItem2) then
      for j := 0 to oPackageItem1.Files.Count - 1 do
      begin
        oFileItem1:=oPackageItem1.Files[j];
        oFileItem2:=TFileItem(oPackageItem2.Files.FindItemID(j));

        if Assigned(oFileItem2) then
        begin
          k:=CompareDateTime (oFileItem1.DateModify, oFileItem2.DateModify);

          if k =-1 then
            aStrings.Add(oFileItem1.FileName);

        end;


      end;
  end;

end;

//-------------------------------------------------------------------
procedure TScriptStorage.LoadFromXmlFile(aFileName: string);
//-------------------------------------------------------------------

  procedure DoLoadFiles(aParentNode: TDOMNode; aPackageItem: TPackageItem);
  var
    I: Integer;
    j: Integer;
    oFileItem: TFileItem;
    oNode,oNode1: TDOMNode;
    s,p: string;
    sItem: TSubitem;
  begin
    for I := 0 to aParentNode.ChildNodes.Count - 1 do
    begin
      oFileItem:=aPackageItem.Files.AddItem;

      oNode:=aParentNode.ChildNodes[i];
      oFileItem.FileName:= VarToStr(oNode.Attributes.GetNamedItem('filename').NodeValue);
      oFileItem.Author  := VarToStr(oNode.Attributes.GetNamedItem('author').NodeValue);
      oFileItem.EMail   := VarToStr(oNode.Attributes.GetNamedItem('email').NodeValue);
      oFileItem.Version := StrToFloat(VarToStr(oNode.Attributes.GetNamedItem('version').NodeValue));

      s:=VarToStr(oNode.Attributes.GetNamedItem('date_modify').NodeValue);

      oFileItem.DateModify := StrToDateTime(s);

//      oFileItem.date_modify


      for j := 0 to oNode.ChildNodes.Count - 1 do
      begin
        oNode1:=oNode.ChildNodes[j];

        if LowerCase(oNode1.NodeName)='subfile' then
        begin
          sItem:=oFileItem.SubFiles.AddItem;
          sItem.FileName:=oNode1.Attributes.GetNamedItem('filename').NodeValue;
          sItem.UnpPath:=oNode1.Attributes.GetNamedItem('filepath').NodeValue;

         // sItem.Free;
        end else

        if LowerCase(oNode1.NodeName)='description' then
        begin
          oFileItem.Description:=oNode1.TextContent;
        end;

      end;

    end;
  end;


  procedure DoLoadPackages(aParentNode: TDOMNode);
  var
    I: Integer;
    oNode: TDOMNode;
    oPackageItem: TPackageItem;
  begin
    for I := 0 to aParentNode.ChildNodes.Count - 1 do
    begin
      oPackageItem:=AddItem;

      oNode:=aParentNode.ChildNodes[i];
      oPackageItem.Name:= oNode.Attributes.GetNamedItem('name').NodeValue;

      DoLoadFiles(oNode, oPackageItem);
    end;
  end;

var
  oXmlDocument: TXmlDocument;
begin
 // oXmlDocument:=TXmlDocument.Create(Application);
 // oXmlDocument.LoadFromFile(aFileName);
  ReadXMLFile(oXmlDocument,aFileName);

  DoLoadPackages (oXmlDocument.DocumentElement);

  FreeAndNil(oXmlDocument);
end;

procedure TScriptStorage.LoadLocalXMLRegistry(aFileName: string);
  procedure DoLoadFiles(aParentNode: TDOMNode; aPackageItem: TPackageItem);
  var
    I: Integer;
    j: Integer;
    oFileItem: TFileItemEx;
    oNode,oNode1: TDOMNode;
    s,p: string;
    sItem: TSubitem;
  begin
    for I := 0 to aParentNode.ChildNodes.Count - 1 do
    begin
      oFileItem:=aPackageItem.Files.AddItemEx;

      oNode:=aParentNode.ChildNodes[i];


      oFileItem.FileName:= VarToStr(oNode.Attributes.GetNamedItem('filename').NodeValue);
      oFileItem.Author  := VarToStr(oNode.Attributes.GetNamedItem('author').NodeValue);
      oFileItem.EMail   := VarToStr(oNode.Attributes.GetNamedItem('email').NodeValue);
      oFileItem.Version := StrToFloat(VarToStr(oNode.Attributes.GetNamedItem('version').NodeValue));
      oFileItem.Installed:=StrToInt(VarToStr(oNode.Attributes.GetNamedItem('installed').NodeValue));

      s:=VarToStr(oNode.Attributes.GetNamedItem('date_modify').NodeValue);

      oFileItem.DateModify := StrToDateTime(s);

//      oFileItem.date_modify


      for j := 0 to oNode.ChildNodes.Count - 1 do
      begin
        oNode1:=oNode.ChildNodes[j];

        if LowerCase(oNode1.NodeName)='subfile' then
        begin
          sItem:=oFileItem.SubFiles.AddItem;
          sItem.FileName:=oNode1.Attributes.GetNamedItem('filename').NodeValue;
          sItem.UnpPath:=oNode1.Attributes.GetNamedItem('filepath').NodeValue;

         // sItem.Free;
        end else

        if LowerCase(oNode1.NodeName)='description' then
        begin
          oFileItem.Description:=oNode1.TextContent;
        end;

      end;

    end;
  end;


  procedure DoLoadPackages(aParentNode: TDOMNode);
  var
    I: Integer;
    oNode: TDOMNode;
    oPackageItem: TPackageItem;
  begin
    for I := 0 to aParentNode.ChildNodes.Count - 1 do
    begin
      oPackageItem:=AddItem;

      oNode:=aParentNode.ChildNodes[i];
      oPackageItem.Name:= oNode.Attributes.GetNamedItem('name').NodeValue;

      DoLoadFiles(oNode, oPackageItem);
    end;
  end;

var
  oXmlDocument: TXmlDocument;
begin
 // oXmlDocument:=TXmlDocument.Create(Application);
 // oXmlDocument.LoadFromFile(aFileName);
  ReadXMLFile(oXmlDocument,aFileName);

  DoLoadPackages (oXmlDocument.DocumentElement);

  FreeAndNil(oXmlDocument);
end;

procedure TScriptStorage.SaveLocalXMLRegistry(aFileName: string);
var
  oXmlDocument: TXmlDocument;
  vRoot,ParentNode,PackageNode,TempNode,Description,FileItemNode,SubFileNode: TDOMNode;
  i,d,j: integer;
  s: string;
  oFileItem: TFileItem;
begin
  oXmlDocument:=TXmlDocument.Create;
  oXmlDocument.Encoding:='UTF-8';
  vRoot:=oXmlDocument.CreateElement('Document');
  oXmlDocument.AppendChild(vroot);
  vRoot:=oXMLDocument.DocumentElement;
  for i:=0 to count -1 do
     begin
       PackageNode:=oXmlDocument.CreateElement('structure');
       TDOMElement(PackageNode).SetAttribute('name',Items[i].Name);
         for d:=0 to Items[i].Files.Count - 1 do
            begin
              oFileItem:=Items[i].Files.Items[d];
              FileItemNode:=oXMLDocument.CreateElement('file');
              TDOMElement(FileItemNode).SetAttribute('filename',oFileItem.FileName);
              TDOMElement(FileItemNode).SetAttribute('author',oFileItem.Author);
              TDOMElement(FileItemNode).SetAttribute('email',oFileItem.EMail);
              TDOMElement(FileItemNode).SetAttribute('version',FloatToStr(oFileItem.Version));
              TDOMElement(FileItemNode).SetAttribute('installed',IntToStr(0));
              s:=DateTimeToStr(oFileItem.DateModify);
              TDOMElement(FileItemNode).SetAttribute('date_modify',s);
                if oFileItem.description<>'' then
                 begin
                   TempNode:=oXMLDocument.CreateElement('description');
                   Description:=oXMLDocument.CreateTextNode(oFileItem.description);
                   TempNode.AppendChild(Description);
                   FileItemNode.AppendChild(TempNode);
                   end;
              for j := 0 to oFileItem.SubFiles.Count - 1 do
                begin
                   SubFileNode:=oXMLDocument.CreateElement('subfile');
                   TDOMElement(SubFileNode).SetAttribute('filename',oFileItem.SubFiles[j].FileName);
                   TDOMElement(SubFileNode).SetAttribute('filepath',oFileItem.SubFiles[j].UnpPath);
                   FileItemNode.AppendChild(SubFileNode);
                end;
             PackageNode.AppendChild(FileItemNode);
            end;
       vRoot.AppendChild(PackageNode);
     end;
  WriteXMLFile (oXmlDocument,aFileName);
  FreeAndNil(oXmlDocument);
end;

procedure TScriptStorage.UpdateLocalXMLRegistry(aFileName: string);
var
  oXmlDocument: TXmlDocument;
  vRoot,ParentNode,PackageNode,TempNode,Description,FileItemNode,SubFileNode: TDOMNode;
  i,d,j: integer;
  s: string;
  oFileItem: TFileItemEx;
begin
  oXmlDocument:=TXmlDocument.Create;
  oXmlDocument.Encoding:='UTF-8';
  vRoot:=oXmlDocument.CreateElement('Document');
  oXmlDocument.AppendChild(vroot);
  vRoot:=oXMLDocument.DocumentElement;
  for i:=0 to count -1 do
     begin
       PackageNode:=oXmlDocument.CreateElement('structure');
       TDOMElement(PackageNode).SetAttribute('name',Items[i].Name);
         for d:=0 to Items[i].Files.Count - 1 do
            begin
              oFileItem:=Items[i].Files.ItemsEx[d];
              FileItemNode:=oXMLDocument.CreateElement('file');
              TDOMElement(FileItemNode).SetAttribute('filename',oFileItem.FileName);
              TDOMElement(FileItemNode).SetAttribute('author',oFileItem.Author);
              TDOMElement(FileItemNode).SetAttribute('email',oFileItem.EMail);
              TDOMElement(FileItemNode).SetAttribute('version',FloatToStr(oFileItem.Version));
              TDOMElement(FileItemNode).SetAttribute('installed',IntToStr(oFileItem.Installed));
              s:=DateTimeToStr(oFileItem.DateModify);
              TDOMElement(FileItemNode).SetAttribute('date_modify',s);
                if oFileItem.description<>'' then
                 begin
                   TempNode:=oXMLDocument.CreateElement('description');
                   Description:=oXMLDocument.CreateTextNode(oFileItem.description);
                   TempNode.AppendChild(Description);
                   FileItemNode.AppendChild(TempNode);
                   end;
              for j := 0 to oFileItem.SubFiles.Count - 1 do
                begin
                   SubFileNode:=oXMLDocument.CreateElement('subfile');
                   TDOMElement(SubFileNode).SetAttribute('filename',oFileItem.SubFiles[j].FileName);
                   TDOMElement(SubFileNode).SetAttribute('filepath',oFileItem.SubFiles[j].UnpPath);
                   FileItemNode.AppendChild(SubFileNode);
                end;
             PackageNode.AppendChild(FileItemNode);
            end;
       vRoot.AppendChild(PackageNode);
     end;
  WriteXMLFile (oXmlDocument,aFileName);
  FreeAndNil(oXmlDocument);
  end;




{
procedure TConfig.LoadTestDataFromDir(aDir: string);
var
  sr: TSearchRec;
  FileAttrs: Integer;

  oPackageItem: TPackageItem;
  oFileItem: TFileItem;
begin
  aDir:=IncludeTrailingBackslash(aDir);


  oPackageItem:=AddItem;
  oPackageItem.Name:='test structure';


  if FindFirst(aDir + '*.*', FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and FileAttrs) = sr.Attr then
      begin
        oFileItem:=oPackageItem.Files.AddItem;

        oFileItem.FileName:=sr.Name;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

end;
}

 {
procedure Test();
var
  oConfig_local: TConfig;
  oConfig_server: TConfig;

  oStrings: TStringList;

begin
  ShortDateFormat:='dd.mm.yyyy';
  ShortTimeFormat:='h:mm';


  oStrings:=TStringList.Create;

  oConfig_server:=TConfig.Create;
  oConfig_server.LoadFromXmlFile('j:\server.xml');

  oConfig_local:=TConfig.Create;
  oConfig_local.LoadFromXmlFile('j:\local.xml');

  oConfig_local.Compare(oConfig_server, oStrings);

end;
   }


begin
  ShortDateFormat:='dd.mm.yyyy';
  ShortTimeFormat:='h:mm';

  {Test; }

end.

