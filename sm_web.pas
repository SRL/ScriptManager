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
  Unzipper : Tbzip2_decode_stream;
  a : array of Byte;
  ReadSize : cardinal;
  i,j: integer;
begin
  SetLength(a,BlockSize);
  try
    Unzipper.init(@input);
    repeat
            readsize:=4096;
            Unzipper.read(a[0],readsize);
            dec(readsize,Unzipper.short);
           res.write(a[0],readsize);
    until Unzipper.status<>0;
            Unzipper.done;
  finally
  end;
  end;



{
function TDownloader.UnTar(const Input: TStream): TStringArray;
var
  Tar : TTarArchive;
  DirRec : TTarDirRec;
  Len : integer;
begin;
  Tar := TTarArchive.Create(input);
  Tar.reset;
  Len := 0;
  while Tar.FindNext(DirRec) do
  begin
    inc(len);
    SetLength(result,len*2);
    result[len*2-2] := DirRec.Name;
    result[len*2-1] := Tar.ReadFile;
  end;
  Tar.Free;
end;

function TDownloader.UnTar(const Input: TStream; const outputdir: string;
  overwrite: boolean): boolean;
var
  Tar : TTarArchive;
  Succ : boolean;
  DirRec : TTarDirRec;
  FS : TFileStream;
begin;
  result := false;
  if not DirectoryExists(outputdir) then
    if not CreateDir(outputdir) then
      exit;
  Tar := TTarArchive.Create(input);
  Tar.reset;
  Succ := True;
  while Tar.FindNext(DirRec) do
  begin
    if (DirRec.FileType = ftDirectory) then
    begin;
      if not DirectoryExists(outputdir + DirRec.Name) and not CreateDir(outputdir + DirRec.Name) then
      begin
        Succ := false;
        break;
      end;
    end else if (DirRec.FileType = ftNormal) then
    begin;
      if FileExistsUTF8(outputdir + dirrec.name) and not overwrite then
        continue;
      try
        FS := TFileStream.Create(UTF8ToSys(outputdir +dirrec.name),fmCreate);
        tar.ReadFile(fs);
        FS.Free;
      except
        Succ := false;
        break;
      end;
    end else
   //   mDebugLn(format('Unknown filetype in archive. %s',[dirrec.name]));
  end;
  Tar.Free;
  Result := Succ;
end; }

destructor TDownloader.Destroy;
begin
  inherited Destroy;
end;

end.

