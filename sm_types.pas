unit sm_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Variants;

type
  TFileItem = class(TCollectionItem)
  public
    FileName: string;
    Author: string;
    EMail: string;
    DateModify : TDateTime;
    Description: string;

    SubFiles: TStringList;

    constructor Create(Col: TCollection); override;
    destructor Destroy; override;
  end;

  TFileItemList = class(TCollection)
  private
    function GetItems(Index: Integer): TFileItem;
  public
    function AddItem: TFileItem;

    constructor Create;

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

{ TFileItem }

constructor TFileItem.Create(Col: TCollection);
begin
  inherited Create(Col);

  SubFiles := TStringList.Create();
end;

destructor TFileItem.Destroy;
begin
  FreeAndNil(SubFiles);
  
  inherited Destroy;
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
