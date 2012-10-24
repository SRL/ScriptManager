unit sm_web;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,HttpSend,sm_types;

Type

{ TDownloader }

TDownloader = Class(TObject)
  private
    FUrl: string;
    procedure Download(var st: TStream);
    procedure MakeURL(script: TPackageItem);
  public

    constructor Create();
    function InstallScript(script: TPackageItem): boolean;
    function UpdateScript(script: TPackageItem): boolean;
    destructor Destroy; override;
    end;

implementation

{ TDownloader }

constructor TDownloader.Create();
begin
  inherited Create;
end;

procedure TDownloader.Download(var st: TStream);
var
  http: THttpSend;
begin
  http:=THttpSend.Create;
  try

  finally

  end;

end;

procedure TDownloader.MakeURL(script: TPackageItem);
begin

end;

function TDownloader.InstallScript(script: TPackageItem): boolean;
begin

end;

function TDownloader.UpdateScript(script: TPackageItem): boolean;
begin

end;

destructor TDownloader.Destroy;
begin
  inherited Destroy;
end;

end.

