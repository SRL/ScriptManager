unit sm_web;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,HttpSend,sm_types,FileUtil,{remove it when we integrate that to simba}bzip2, bzip2comn,bzip2stream,libtar{mmisc};

Type

{ TDownloader }
TStringArray = array of string;
TDownloader = Class(TObject)
  private
    FUrl: string;
    //this is not useable variables
    FPath: string;//path to simba script folder
    FOwerwrite: boolean;//owerwrite file flag
    //end not useable block
  public
     procedure Download(var st: TFileStream);overload;
     procedure Download(var st: TMemoryStream);overload;
     procedure Download(var st: TStringStream);overload;
     function GetPage(URL: String): String;
     //remove that block when we integrate that to Simba
     procedure DecompressBZip2(const input : TStream;var res: TMemoryStream; const BlockSize : Cardinal = 4096);
    //
    function Decompress(const SourceFile: TStringStream;TargetFile: string): boolean;
    constructor Create(url: string);
    destructor Destroy; override;
    end;

implementation

{ TDownloader }

constructor TDownloader.Create(url: string);
begin
  inherited Create;
  FURl:=url;
end;

function TDownloader.GetPage(URL: String): String;
var
  HTTP : THTTPSend;
begin;
  HTTP := THTTPSend.Create;

  HTTP.UserAgent := 'Mozilla 4.0/ (compatible Synapse)';

  Result := '';
  try
    if HTTP.HTTPMethod('GET', URL) then
    begin
      SetLength(result,HTTP.Document.Size);
      HTTP.Document.Read(result[1],length(result));
    end;
  finally
    HTTP.Free;
  end;
end;

procedure TDownloader.Download(var st: TFileStream); overload;
var
  http: THttpSend;
begin
  http:=THttpSend.Create;
  try
    HttpGetBinary(FUrl,st);
  finally
  http.Free;
  end;
end;

procedure TDownloader.Download(var st: TMemoryStream); overload;
var
  http: THttpSend;
begin
  http:=THttpSend.Create;
  try
    HttpGetBinary(FUrl,st);
  finally
  http.Free;
  end;
end;
procedure TDownloader.Download(var st: TStringStream); overload;
var
  http: THttpSend;
  s: String;
begin
  http:=THttpSend.Create;
  try
    s:=GetPage(FUrl);
    st:=TStringStream.Create(s);
  finally
  http.Free;
  end;
end;

procedure TDownloader.DecompressBZip2(const input: TStream; var res: TMemoryStream;
  const BlockSize: Cardinal);
var
  Unzipper : TDecompressBzip2Stream;
  Blocks : array [0..4096] of Byte;
  ReadSize : cardinal;
  i,j: integer;
begin
 // SetLength(Blocks,BlockSize);
  try
    Unzipper := TDecompressBzip2Stream.Create(input);
  except
    on e : exception do
    begin;
  //    mDebugLn(e.message);
      exit;
    end;
  end;
  try
    repeat
      ReadSize := BlockSize;
      ReadSize := Unzipper.Read(blocks[0],readsize);  //Read ReadSize amount of bytes.
      Res.Write(Blocks[0],ReadSize);
    until readsize = 0;
  except
    on e : EBzip2 do
     if E.ErrCode <> bzip2_endoffile then
       raise Exception.CreateFmt('Decompression error: %s %d',[e.message,e.errcode]);
  end;
  Unzipper.Free;
end;
function TDownloader.Decompress(const SourceFile: TStringStream;TargetFile: string): boolean;
var
  Decompressed:TDecompressBzip2Stream;
  OutFile:TFileStream;
  Buffer: Pointer;
  i:integer;
const buffersize=$2000;
begin
  result:=false;
  try
    Decompressed:=TDecompressBzip2Stream.Create(SourceFile);
    OutFile:=TFileStream.Create(TargetFile, fmCreate);
    try
      GetMem(Buffer,BufferSize);
      repeat
        i:=Decompressed.Read(buffer^,BufferSize);
        if i>0 then
          OutFile.WriteBuffer(buffer^,i);
      until i<BufferSize;
      result:=true;
    finally
      Decompressed.Free;
      OutFile.Free;
    end;
  finally

  end;
end;

destructor TDownloader.Destroy;
begin
  inherited Destroy;
end;

end.

