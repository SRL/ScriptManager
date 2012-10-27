unit sm_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
//equal 2 strings
function Eq(aValue1, aValue2: string): boolean;
implementation
function Eq(aValue1, aValue2: string): boolean;
//--------------------------------------------------------
begin
  Result := AnsiCompareText(Trim(aValue1),Trim(aValue2))=0;
end;
end.

