unit sm_web;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,HttpSend,sm_types,FileUtil,{remove it when we integrate that to simba}bzip2, bzip2comn,bzip2stream, libtar{mmisc};

Type

{ TDownloader }
TStringArray = array of string;
TDownloader = Class(TObject)
  private
    FUrl: string;
    FBaseUrl: string;
    //this is not useable variables
    FPath: string;//path to simba script folder
    FOwerwrite: boolean;//owerwrite file flag
    //end not useable block
    procedure Download(var st: TMemoryStream);
    procedure MakeURL(script: TFileItem);
    //remove that block when we integrate that to Simba
     function DecompressBZip2(const input : TStream; const BlockSize : Cardinal = 4096) : TMemoryStream;
     function UnTar(const Input : TStream) : TStringArray;overload;
     function UnTar(const Input : TStream;const outputdir : string; overwrite : boolean): boolean;overload;
    //
  public

    constructor Create(url: string);
    function InstallScript(script: TFileItem): boolean;
    function UpdateScript(script: TFileItem): boolean;
    function UpdateAllScript(FileList: TFileItemList): boolean;
    destructor Destroy; override;
    end;

implementation

{ TDownloader }

constructor TDownloader.Create(url: string);
begin
  inherited Create;
  FbaseURl:=url;
end;

procedure TDownloader.Download(var st: TMemoryStream);
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

procedure TDownloader.MakeURL(script: TFileItem);
begin

  FUrl:=FBaseUrl+script.FileName+'.tar.bz2';
end;

function TDownloader.DecompressBZip2(const input: TStream;
  const BlockSize: Cardinal): TMemoryStream;
var
  Unzipper : TDecompressBzip2Stream;
  Blocks : array of Byte;
  ReadSize : cardinal;
begin
  SetLength(Blocks,BlockSize);
  try
    Unzipper := TDecompressBzip2Stream.Create(input);
  except
    on e : exception do
    begin;
     // mDebugLn(e.message);
      exit;
    end;
  end;
  Result := TMemoryStream.Create;
  try
    repeat
      ReadSize := BlockSize;
      ReadSize := Unzipper.read(blocks[0],readsize);  //Read ReadSize amount of bytes.
      Result.Write(Blocks[0],ReadSize);
    until readsize = 0;
  except
    on e : EBzip2 do
     if E.ErrCode <> bzip2_endoffile then
       raise Exception.CreateFmt('Decompression error: %s %d',[e.message,e.errcode]);
  end;
  Unzipper.Free;
end;



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
end;

function TDownloader.InstallScript(script: TFileItem): boolean;
var
  ScriptPackage,UnpackedScript: TMemoryStream;
begin
  result:=false;
  ScriptPackage:=TMemoryStream.Create;
  UnpackedScript:=TMemoryStream.Create;
  try
  MakeUrl(script);
  Download(ScriptPackage);
  if ScriptPackage.Size>0 then
    begin
     UnpackedScript:=DecompressBZip2(ScriptPackage);
      if UnpackedScript = nil then exit;
      if not Untar(UnpackedScript,FPath,FOwerwrite) then exit;
      result:=true;
    end;
  finally
  UnpackedScript.Free;
  ScriptPackage.Free;
  end;
end;

function TDownloader.UpdateScript(script: TFileItem): boolean;
var
  ScriptPackage,UnpackedScript: TMemoryStream;
begin
  Result:=false;
  ScriptPackage:=TMemoryStream.Create;
  UnpackedScript:=TMemoryStream.Create;
  try
  MakeUrl(script);
  Download(ScriptPackage);
  if ScriptPackage.Size>0 then
    begin
     UnpackedScript:=DecompressBZip2(ScriptPackage);
      if UnpackedScript = nil then exit;
      if not Untar(UnpackedScript,FPath,FOwerwrite) then exit;
      result:=true;
    end;
  finally
  UnpackedScript.Free;
  ScriptPackage.Free;
  end;
end;

function TDownloader.UpdateAllScript(FileList: TFileItemList): boolean;
var
  i: integer;
begin
  for i:=0 to FileList.Count -1 do
   begin
     UpdateScript(FileList.Items[i]);
   end;
end;

destructor TDownloader.Destroy;
begin
  inherited Destroy;
end;

end.

