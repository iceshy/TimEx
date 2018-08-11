unit TX_Utils;

{*******************************************************************************
*    Unit TX_Utils (for use with TimEx)                                       *
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

interface

uses
  SysUtils, Math, TX_Globals, TX_Math, TX_Strings, StrUtils;

procedure WriteIntegrationTrace(wDatFileName,wOutFileName : string; wTrace : integer);
procedure CloseWithHaltCode(EText : string; HCode : integer);
function NoOutputs(nState, nIn, nStep : integer) : boolean;

implementation

{ -------------------------- WriteIntegrationTrace --------------------------- }
procedure WriteIntegrationTrace(wDatFileName,wOutFileName : string; wTrace : integer);
var
  w1 : Integer;
  wTimeInFile, wTimeStep, wTimePrev, wAcc : Double;
  wText : String;
  wDone : Boolean;
  wSlidingWindow : array of Double;
  wDatFile, wOutFile : TextFile;
  wSeparator : String;

begin
  wTimeInFile := 0;
  wSeparator := ',';
  if useJSIM then
    wSeparator := ' ';
  AssignFile(wDatFile,wDatFileName);
  {$I-}
  Reset(wDatFile);
  {$I+}
  if IOResult <> 0 then        // problem with .dat file
    CloseWithHaltCode('Error while trying to open JSIM output file "'+wDatFileName+'". Abort.', 102);
  ReadLn(wDatFile,wText);  // First line of .dat file contains variable identifiers.

  wTimeStep := -1; // Startup
  wTimePrev := -1;
  repeat
    ReadLn(wDatFile,wText);
    if CheckIfReal(ReadStrFromMany(1,wText,wSeparator)) then
      wTimeInFile := StrToFloat(ReadStrFromMany(1,wText,wSeparator));
    if (wTimeInFile > 1e-20) and (wTimeStep < 0) then
      if wTimePrev < 0 then
      begin
        wTimePrev := wTimeInFile;
      end
      else
        wTimeStep := wTimeInFile-wTimePrev;
  until (wTimeStep > 0) or (eof(wDatFile));
  if (eof(wDatFile) or (wTimeStep < 1.1e-20)) then
    begin
      CloseFile(wDatFile);                               // Not good. Return 0.
      Exit;
    end;
  Reset(wDatFile);
  ReadLn(wDatFile,wText);
  AssignFile(wOutFile,wOutFileName);
  Rewrite(wOutFile);
//  fAcc := 0;
  wDone := False;
//  fThresholdTime := -1;
  SetLength(wSlidingWindow,round(slidingIntegratorLength/wTimeStep));
  for w1 := 0 to High(wSlidingWindow) do
    wSlidingWindow[w1] := 0;
  while not wDone do
  begin
    ReadLn(wDatFile,wText);
    if eof(wDatFile) then
    begin
      CloseFile(wDatFile);
      CloseFile(wOutFile);
      Exit;
    end;
    for w1 := 0 to (High(wSlidingWindow)-1) do  // Slide back
      wSlidingWindow[w1] := wSlidingWindow[w1+1];
//      if CheckIfReal(ReadStrFromMany(1,fText,' ')) then
    wTimeInFile := StrToFloat(ReadStrFromMany(1,wText,wSeparator));
    wSlidingWindow[High(wSlidingWindow)] := StrToFloat(ReadStrFromMany(wTrace,wText,wSeparator));
    wAcc := 0;
    for w1 := 1 to High(wSlidingWindow) do // Integrate
      wAcc := wAcc + (wSlidingWindow[w1]+wSLidingWindow[w1-1])/2*wTimeStep;
    WriteLn(wOutFile,FloatToStrF(wTimeInFile,ffGeneral,6,4)+' '+FloatToStrF(wAcc,ffGeneral,6,4)+' '+FloatToStrF(wSlidingWindow[High(wSlidingWindow)],ffGeneral,6,4));
  end;
  SetLength(wSlidingWindow,0);
  CloseFile(wDatFile);
  CloseFile(wOutFile);
end; // WriteIntegrationTrace
{ --------------------------- CloseWithHaltCode ------------------------------ }
procedure CloseWithHaltCode(EText : string; HCode : integer);
// Writes text to both the screen and an output file, then closes file and halts
begin
  WriteLn('('+IntToStr(HCode)+') '+EText);
  WriteLn(OutFile,'('+IntToStr(HCode)+') '+EText);
  CloseFile(OutFile);
  Halt(HCode);
end; // CloseWithHaltCode
{ ------------------------------- NoOutputs ---------------------------------- }
function NoOutputs(nState, nIn, nStep : integer) : boolean;
// Returns true of input "nIn" in state "nState" causes no outputs at sweep step "nStep"
var
  nResult : boolean;
  n1 : integer;
begin
  nResult := true;
  for n1 := 0 to High(dutOutput) do
    if states[nState].inputResponse[nIn].outTimes[n1,nStep] > 0 then
      nResult := False;
  NoOutputs := nResult;
end; // NoOutputs

end.
