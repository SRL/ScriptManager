unit sm_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants;

type

  { TSubItem }

  TSubItem = class(TCollectionItem)
  public
    FileName: string;
    UnpPath: string;
    constructor Create(Col: TCollection); override;
    destructor Destroy; override;
  end;

  { TSubitemList }

  TSubitemList = class(TCollection)
  private
    function GetItems(Index: Integer): TSubItem;
  public
    function AddItem: TSubItem;

    constructor Create;

    property Items[Index: Integer]: TSubItem read GetItems; default;
  end;

  TFileItem = class(TCollectionItem)
  public
    FileName: string;
    Author: string;
    EMail: string;
    DateModify : TDateTime;
    Version: extended;
    Description: string;

    SubFiles: TSubitemList;

    constructor Create(Col: TCollection); override;
    destructor Destroy; override;
  end;
  TFileItemEx = class(TFileItem)
    public
    Installed: integer;
  end;

  TFileItemList = class(TCollection)
  private
    function GetItems(Index: Integer): TFileItem;
    function GetItemsEx(Index: Integer): TFileItemEx;
  public
    function AddItem: TFileItem;
    function AddItemEx: TFileItemEx;

    constructor Create;
    property ItemsEx[Index: Integer]: TFileItemEx read GetItemsEx;
    property Items[Index: Integer]: TFileItem read GetItems; default;
  end;

  TPackageItem = class(TCollectionItem)
  public
    Name: string;
    Files: TFileItemList;

    constructor Create(Col: TCollection); override;
    destructor Destroy; override;
  end;


  TPackageList = class(TCollection)
  private
    function GetItems(Index: Integer): TPackageItem;
  public
    function AddItem: TPackageItem;
    
    constructor Create;

    property Items[Index: Integer]: TPackageItem read GetItems; default;
  end;

implementation

constructor TSubItem.Create(Col: TCollection);
begin
  inherited Create(Col);
end;

destructor TSubItem.Destroy;
begin
  inherited Destroy;
end;

{ TSubitemList }

function TSubitemList.GetItems(Index: Integer): TSubItem;
begin
  Result := TSubItem(inherited Items[Index]);
end;

function TSubitemList.AddItem: TSubItem;
begin
  Result := TSubItem(inherited Add());
end;

constructor TSubitemList.Create;
begin
  inherited Create(TSubItem);
end;

{ TFileItem }

constructor TFileItem.Create(Col: TCollection);
begin
  inherited Create(Col);
  SubFiles:=TSubitemList.Create;
 // SubFiles := TList.Create();
end;

destructor TFileItem.Destroy;
begin
  FreeAndNil(SubFiles);
  
 // inherited Destroy;
end;

{ TFileItemList }

function TFileItemList.AddItem: TFileItem;
begin
  Result := TFileItem(inherited Add());
end;

function TFileItemList.GetItems(Index: Integer): TFileItem;
begin
  Result := TFileItem(inherited Items[Index]);
end;

function TFileItemList.AddItemEx: TFileItemEx;
begin
  Result := TFileItemEx(inherited Add());
end;

function TFileItemList.GetItemsEx(Index: Integer): TFileItemEx;
begin
  Result := TFileItemEx(inherited Items[Index]);
end;

constructor TFileItemList.Create;
begin
  inherited Create(TFileItem);
end;

{ TPackageItem }

constructor TPackageItem.Create(Col: TCollection);
begin
  inherited Create(Col);
  
  Files := TFileItemList.Create();
end;

destructor TPackageItem.Destroy;
begin
  FreeAndNil(Files);
  
  inherited Destroy;
end;

{ TPackageList }

function TPackageList.AddItem: TPackageItem;
begin
  Result := TPackageItem(inherited Add());
end;

function TPackageList.GetItems(Index: Integer): TPackageItem;
begin
  Result := TPackageItem(inherited Items[Index]);
end;

constructor TPackageList.Create;
begin
  inherited Create(TPackageItem);
end;

end.
