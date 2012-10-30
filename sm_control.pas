unit sm_control;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,FileUtil ,sm_types,sm_web,libtar,sm_utils;

function GetScript(Script: TFileItem): boolean;
implementation
function GetScript(Script: TFileItem): boolean;
var
 Downloader: TDownloader;
 ScriptTar: TMemoryStream;
 unppath,s:string;//just test variable
 TA: TTarArchive;
 DirRec : TTarDirRec;
 FS : TFileStream;
 i: integer;
begin
 result:=false;
 scriptTar:=TMemoryStream.Create;
 Downloader:=TDownloader.Create('http://localhost/'+GetPackageUrl(Script.filename));
 try
 ScriptTar:=Downloader.GetFile('http://localhost/'+GetPackageUrl(Script.filename));
    i:=0;
     scriptTar.Position:=0;
     TA:=TTarArchive.Create(scriptTar);
     TA.Reset;
     while TA.FindNext(DirRec) do
       begin
          if (DirRec.FileType = ftDirectory) then
            begin;
             if not DirectoryExists(unppath + DirRec.Name) and not CreateDir(unppath + DirRec.Name) then
            begin
           // Succ := false;
            break;
        end;
     end;
     if eq(DirRec.Name, GetScriptName(script.FileName)) then
            begin
             FS := TFileStream.Create(UTF8ToSys('C:/' +dirrec.name),fmCreate);
              TA.ReadFile(fs);
             FS.Free;
             result:=true;
            end;
     if (script.SubFiles.Count > 0) then
      if (i < script.SubFiles.Count) then
      begin
         if eq(DirRec.Name, script.SubFiles[i].FileName) then
           begin
             FS := TFileStream.Create(UTF8ToSys('J:/' +dirrec.name),fmCreate);
              TA.ReadFile(fs);
             FS.Free;
             result:=true;
             inc(i);
           end;
        end;
       end;
 finally
   downloader.Free;
   scriptTar.Free;
 end;

end;
end.

