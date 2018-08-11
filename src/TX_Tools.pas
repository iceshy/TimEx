unit TX_Tools;

{*******************************************************************************
*    Unit TX_Tools (for use with TimEx)                                        *
*    Copyright (c) 2016-2018 Coenrad Fourie                                    *
*                                                                              *
* This work was supported by the Office of the Director of National            *
* Intelligence (ODNI), Intelligence Advanced Research Projects Activity        *
* (IARPA), via the U.S. Army Research Office grant W911NF-17-1-0120.           *
*                                                                              *
* Permission is hereby granted, free of charge, to any person obtaining a copy *
* of this software and associated documentation files (the "Software"), to     *
* deal in the Software without restriction, including without limitation the   *
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or  *
* sell copies of the Software, and to permit persons to whom the Software is   *
* furnished to do so, subject to the following conditions:                     *
*                                                                              *
* The above copyright notice and this permission notice shall be included in   *
* all copies or substantial portions of the Software.                          *
*                                                                              *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS *
* IN THE SOFTWARE.                                                             *
********************************************************************************}

{$IFDEF Unix}
{$mode objfpc}{$H+}
{$ENDIF Unix}

interface

uses

  Classes, SysUtils,
{$IFDEF Unix}
  Process,
{$ENDIF Unix}
{$IFDEF MSWINDOWS}
  Windows, ShellAPI, Vcl.Forms,
{$ENDIF MSWINDOWS}
  TX_Globals, TX_FileOut;

procedure CrossPlatformDeleteFile(Filename: string);
procedure CrossPlatformRenameFile(oldFileName, newFileName: string);
function CurrentTime : double;
procedure ExecuteShellApp(esaName, esaParamStr : string);

implementation

var
  {$IFDEF MSWINDOWS}
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
  {$ENDIF MSWINDOWS}
  ExecuteShellFile, ParamString, StartInString : string;


{ ------------------------- CrossPlatformDeleteFile -------------------------- }
procedure CrossPlatformDeleteFile(Filename: string);

begin
{$IFDEF MSWINDOWS}
  DeleteFile(PChar(Filename));
{$ELSE}
  DeleteFile(Filename);
{$ENDIF}
end; //CrossPlatformDeleteFile
{ ------------------------- CrossPlatformRenameFile -------------------------- }
procedure CrossPlatformRenameFile(oldFileName, newFileName: string);

begin
{$IFDEF MSWINDOWS}
  DeleteFile(PChar(newFileName));
  RenameFile(oldFileName, newFileName);
{$ELSE}
  RenameFile(oldFileName, newFileName);
{$ENDIF}
end; //CrossPlatformRenameFile

{$IFDEF MSWINDOWS}
{ ------------------------- ExecuteShellAppBorland --------------------------- }
procedure ExecuteShellAppBorland;

begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  with SEInfo do begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := Application.Handle;
    lpFile := PChar(ExecuteShellFile);
    lpParameters := PChar(ParamString);
    lpDirectory := PChar(StartInString);
    nShow := SW_HIDE;
  end;
  if ShellExecuteEx(@SEInfo) then
  begin
    repeat
      while WaitForSingleObject(SEInfo.hProcess, 1) <> WAIT_OBJECT_0 do
        Application.ProcessMessages;
      GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE) or
	  Application.Terminated;
  end
  else ExitWithHaltCode('Shell application "' + ExecuteShellFile + ' ' + ParamString+'" did not execute.',8);
end; // ExecuteShellAppBorland

{$ELSE}
{ --------------------------- ExecuteShellAppFPC ----------------------------- }
procedure ExecuteShellAppFPC;

var
  SAProcess : TProcess;
begin
  SAProcess := TProcess.Create(nil);
  SAProcess.CommandLine := ExecuteShellFile + ' ' + ParamString;
  SAProcess.Options := SAProcess.Options + [poWaitOnExit];
  SAProcess.ShowWindow:= swoHide;
  try
    WriteLn('Executing '+ExecuteShellFile+' '+ParamString);
    SAProcess.Execute;
    SAProcess.Free;
  except
    begin
      SAProcess.Free;
      ExitWithHaltCode('Shell application "' + ExecuteShellFile + ' ' + ParamString+'" did not execute.',8);
    end;
  end;
end; // ExecuteShellAppFPC

{$ENDIF}
{ ---------------------------- ExecuteShellApp ------------------------------- }
procedure ExecuteShellApp(esaName, esaParamStr : string);

begin
  ParamString := esaParamStr; StartInString := '';
  ExecuteShellFile := 'Platform not recognised!';
{$IFDEF MSWINDOWS}
  ExecuteShellFile := esaName+'.exe';
  ExecuteShellAppBorland;
{$ENDIF}
{$IFDEF Unix}
  ExecuteShellFile := esaName;
  ExecuteShellAppFPC;
{$ENDIF}
end; // ExecuteShellApp
{ ------------------------------ CurrentTime --------------------------------- }
function CurrentTime : double;

begin
{$IFDEF MSWINDOWS}
  CurrentTime := GetTime
{$ELSE}
  CurrentTime := Time
{$ENDIF}
end; // CurrentTime

end.
