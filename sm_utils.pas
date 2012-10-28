unit sm_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
//equal 2 strings
function Eq(aValue1, aValue2: string): boolean;
function SM_StrToDate(str: string): TDateTime;
function GetPackageUrl(s: string):string;
function GetScriptName(s: string):string;
implementation
function Eq(aValue1, aValue2: string): boolean;
//--------------------------------------------------------
begin
  Result := AnsiCompareText(Trim(aValue1),Trim(aValue2))=0;
end;
function SM_StrToDate(str: string): TDateTime;
var frmstg: TFormatSettings;
begin
  //GetLocaleFormatSettings(0, frmstg);
  frmstg.DateSeparator := '.';
  frmstg.ShortDateFormat := 'yyyy.mm.dd';
  frmstg.TimeSeparator := '.';
  frmstg.LongTimeFormat := 'hh.nn';

  if not TryStrToDateTime(str, Result, frmstg) then
    Result := Now();
end;
function GetPackageUrl(s: string): string;
var
  c: char;
  i, k: Integer;
begin
  k := 0;
  SetLength(Result, Length(s));
  for i := 0 to Length(s) - 1 do
  begin
    c := s[i + 1];
    if c in [ 'a'..'z', 'A'..'Z' ] then
    begin
      Inc(k);
      Result[k] := c;
    end;
  end;
  SetLength(Result, k);
  result:=result+'.tar.bz2';
end;

function GetScriptName(s: string): string;
var
  c: char;
  i, k: Integer;
begin
  k := 0;
  SetLength(Result, Length(s));
  for i := 0 to Length(s) - 1 do
  begin
    c := s[i + 1];
    if c in [ 'a'..'z', 'A'..'Z' ] then
    begin
      Inc(k);
      Result[k] := c;
    end;
  end;
  SetLength(Result, k);
  result:=result+'.simba';
end;
end.

