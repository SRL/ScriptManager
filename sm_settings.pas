unit sm_settings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 
type TOption = record
    XMLSrvDesc: string;//host for server side description file
    XMLStorage: string;//local path for local script storage
    Autoupdate: boolean;//autoupdate -> yes\no
    Simba_Scripts: string;//path to simba scripts folder
    Simba_SRL: string;//path to simba srl folder
    Simba_SPS:string;//path to Simba sps folder
    Simba_Fonts: string;//path to Simba fonts folder
    Simba_Plugins: string;//path to Simba plugins folder
    Simba: string;//path to Simba folder
    Simba_include: string;//path to Simba include folder
  end;
implementation

end.

