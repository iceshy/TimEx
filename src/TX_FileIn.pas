unit TX_FileIn;

{*******************************************************************************
*    Unit TX_FileIn (for use with TimEx)                                       *
*    Copyright (c) 2016-2020 Coenrad Fourie                                    *
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
{$IFDEF Unix}
  Process,
{$ENDIF Unix}
  SysUtils, TX_FileOut, TX_Math, TX_Globals, TX_Strings;

procedure Swop(var i1, i2 : integer);
procedure LnTABreplace(var rLnText : string);
procedure ReadCleanLn(var rcFile : TextFile; var cleanLine : string);
procedure ReadElementValues;
procedure ReadCurrentValues(rFileName : String; rTime : Double);
procedure ReadVariablesFromSpiceDeck(var rvDeckLines : TSpiceDeckLine);
procedure ReadSweepFromControl(rsText : string);
procedure ReadDefFile;
procedure ReadSpiceFileToMem(rsFileName : string; var rsMemLines : TSpiceDeckLine; rsMessage : string);
function FindFirstPulseTime(fFileName : String; fStartTime : Double; fIndex : Integer) : Double;
function FindSecondPulseTime(fFileName : String; fStartTime, fStopTime : Double; fIndex : Integer) : Double;
function FindNthPulseTime(fFileName : String; fPulseNumber : integer; fStartTime, fStopTime : Double; fIndex : Integer) : Double;

implementation

{ ---------------------------------- Swop ------------------------------------ }
procedure Swop(var i1, i2 : integer);
var            // Swops two integers;
  ii : integer;
begin
  ii := i1;
  i1 := i2;
  i2 := ii;
end; // Swop
{ ------------------------------ LnTABreplace -------------------------------- }
procedure LnTABreplace(var rLnText : string);
var
  rLnFNText : string;
begin
  if rLnText <> '' then rLnFNtext := StringReplace(rLnText,#9,' ',[rfReplaceAll])
    else rLnFNtext := ' ';
  rLnText := lowercase(rLnFNText);
end; // ReadLnTABreplace
{ ------------------------------- ReadCleanLn -------------------------------- }
procedure ReadCleanLn(var rcFile : TextFile; var cleanLine : string);
// Strip out comments and remove empty lines.
// Also convert TAB to space, and strip start and end whitespace.
var
  rcStr : string;
  foundLine : boolean;
begin
  repeat
    foundLine := true;
    ReadLn(rcFile, rcStr);
    if rcStr = '' then
      foundLine := false
    else
    begin
      if (rcStr[1] = '*') or (pos('//',rcStr) = 1) then
        foundLine := false;    // Line is only a comment
      if foundLine then
      begin
        if pos('//',rcStr) > 1 then
          rcStr := copy(rcStr,1,pos('//',rcStr)-1);
        rcStr := lowercase(StringReplace(rcStr,#9,' ',[rfReplaceAll]));
        rcStr := StripSpaces(rcStr);
        if rcStr = '' then
          foundLine := false;
      end;
    end;
  until foundLine or eof(rcFile);
  cleanLine := rcStr;
end; // ReadCleanLn
{ --------------------------- ReadElementValues ------------------------------ }
procedure ReadElementValues;

var
  rev1, rev2, rev3 : Integer;
  revText, revStr : String;
  revValue, revCrit : Double;
  rSuccess : boolean;

begin
  // Firstly, get the JJ models.
  for rev1 := 0 to High(SpiceDUTLines) do
  begin
    if LowerCase(copy(String(spiceDUTLines[rev1]),1,6)) = '.model' then
      if LowerCase(copy(ReadStrFromMany(3,String(spiceDUTLines[rev1]),' '),1,2)) = 'jj' then // JJ model
      begin
        SetLength(jjModels,Length(jjModels)+1);
        jjModels[High(jjModels)].Name := ANSIString(LowerCase(ReadStrFromMany(2,String(spiceDUTLines[rev1]),' ')));
        revStr := ReadValueAfterEqualSign(LowerCase(String(spiceDUTLines[rev1])),'icrit');
//        jjModels[High(jjModels)].Value := StringToDouble(revStr);
        jjModels[High(jjModels)].Value := ConvertToValue(revStr,rSuccess);
      end;
  end;
  for rev1 := 0 to High(elements) do
  begin
    for rev2 := 0 to High(spiceDUTLines) do
    begin
      revText := ReadStrFromMany(1,String(spiceDUTLines[rev2]),' ');
      if revText = String(elements[rev1].Name) then
      begin
        if elements[rev1].Name[1] = 'l' then  // inductor
        begin
          revStr := ReadStrFromMany(4,String(spiceDUTLines[rev2]),' '); // Read the value
          elements[rev1].Value := ConvertToValue(revStr,rSuccess);
        end;
        if elements[rev1].Name[1] = 'b' then  // junction
        begin
          revStr := ReadValueAfterEqualSign(LowerCase(String(spiceDUTLines[rev2])),'area');  // Read the junction area
          if revStr <> '' then
            revValue := ConvertToValue(revStr,rSuccess)
          else
            revValue := 1.0; // default
          revStr := LowerCase(ReadStrFromMany(4,String(spiceDUTLines[rev2]),' ')); // Read the JJ model name
          revCrit := 0;
          for rev3 := 0 to High(jjModels) do
            if String(jjModels[rev3].Name) = revStr then
          revCrit := jjModels[rev3].Value;
          if revCrit = 0 then
            ExitWithHaltCode('No Ic read for Josephson junction in DUT card "'+String(SpiceDUTLines[rev2])+'".',101);
          elements[rev1].Value := revValue*revCrit;
        end;
      end;
    end;
  end;
end; // ReadElementValues
{ --------------------------- ReadCurrentValues ------------------------------ }
procedure ReadCurrentValues(rFileName : String; rTime : Double);
// Reads the value of current for every element from the simulation output file
var
  r1, r2 : Integer;
  rText, rTextPrev, rVarName : String;
  timeFound : Boolean;
  rTimeInFile, rTimeInFilePrev : Double;
  rFile : TextFile;
  rCrossRef : Array of Integer;
  rSeparator : String;

begin
  rSeparator := ',';
  if useJSIM then
    rSeparator := ' ';
  AssignFile(rFile,rFileName);
  {$I-}
  Reset(rFile);
  {$I+}
  if IOResult <> 0 then        // problem with .dat file
    ExitWithHaltCode('Error while trying to open JSIM output file "'+rFileName+'". Abort.', 102);
  ReadLn(rFile,rText);  // First line of .dat file contains variable identifiers. First of those MUST be time.
  rText := LowerCase(rText);
  if not (ReadStrFromMany(1,rText,rSeparator) = 'time') then
    ExitWithHaltCode('Time is not the first variable in '+rFileName+'. Simulation error?',103);
  SetLength(rCrossRef,Length(elements)); // rCrossRef[n] holds the column number of the nth element's current
  for r1 := 0 to High(rCrossRef) do
    rCrossRef[r1] := -1;  // Value to indicate unindexed
  for r1 := 2 to CountSubstrings(rText,rSeparator) do
  begin
    rVarName := ReadStrFromMany(r1,rText,rSeparator);
    if useJSIM then
    begin
      if Pos('xdut_',rVarName) > 0 then
        Delete(rVarName,1,5);  // Delete "XDUT_" from every variable name
      if Pos('_i',rVarName) > 0 then    // delete the "_I" a the end, otherwise the names don't match elements. Also, this tests if it IS CURRENT.
      begin
        Delete(rVarName,pos('_i',rVarName),Length(rVarName)-2);
        for r2 := 0 to High(elements) do
          if elements[r2].Name = ANSIString(rVarName) then
            rCrossRef[r2] := r1; // Link to column in .dat file
      end;
    end
    else // JoSIM writes the variable names differently
    begin
      if Pos('i(',rVarName) > 0 then
        Delete(rVarName,1,3);  // Delete "I( " from every variable name
      if Pos('|xdut',rVarName) > 0 then    // delete the "_xdut" a the end, otherwise the names don't match elements.
      begin
        rVarname := copy(rVarName,1,pos('|xdut',rVarName)-1);
        for r2 := 0 to High(elements) do
          if elements[r2].Name = ANSIString(rVarName) then
            rCrossRef[r2] := r1; // Link to column in .dat file
      end;
    end;
  end;
  for r1 := 0 to High(rCrossRef) do
    if rCrossRef[r1] = -1 then  // No link to column. Then we can't continue!
      ExitWithHaltCode('No current vector in '+rFileName+' for element '+UpperCase(String(elements[r1].Name))+'.',104);
  timeFound := False;
  rTextPrev := rText;  rTimeInFile := 0; rTimeInFilePrev := -1;
  repeat
    rTextPrev := rText;
    ReadLn(rFile,rText);
    if CheckIfReal(ReadStrFromMany(1,rText,rSeparator)) then
      rTimeInFile := StrToFloat(ReadStrFromMany(1,rText,rSeparator));
    if abs(rTime-rTimeInFile) > abs(rTime-rTimeInFilePrev) then // So, previous was minimum time;
      timeFound := True
    else
      rTimeInFilePrev := rTimeInFile;  // Shift counters along.
  until eof(rFile) or timeFound;
  for r1 := 0 to High(elements) do
  begin
    elements[r1].Current := 0;
    if CheckIfReal(ReadStrFromMany(rCrossRef[r1],rTextPrev,rSeparator)) then        // The closest string to the right time is in rTextPrev. Use this.
      elements[r1].Current := StrToFloat(ReadStrFromMany(rCrossRef[r1],rTextPrev,rSeparator));
  end;
  CloseFile(rFile);
end; // ReadCurrentValues
{ ----------------------- ReadVariablesFromSpiceDeck ------------------------- }
procedure ReadVariablesFromSpiceDeck(var rvDeckLines : TSpiceDeckLine);

var
  rv1, rv2, rvV, rvNum, rvParamsUnknownLast, rvParamsUnknown : integer;
  rvStr, rvPar : string;
  rvValue : double;
  evaluatedOK : boolean;

begin
  rvParamsUnknown := 0;
  rvParamsUnknownLast := 0;
  repeat // Until no unknown paramaters
    rvParamsUnknownLast := rvParamsUnknown;
    rvParamsUnknown := 0;
    rv1 := 0;
    repeat
      rvStr := String(rvDeckLines[rv1]);
      inc(rv1);
      rvPar := ReadStrFromMany(1, rvStr, ' ');
      evaluatedOK := true;
      if rvPar = '.param' then
      begin
        Delete(rvStr,1,Length(rvPar)+1);
        StripSpaces(rvStr);
        // Now support only one parameter entry per line, without braces
        rvPar := LowerCase(ReadStrFromMany(1,rvStr,'='));
        rvValue := EvaluateSpiceExpression(StripSpaces(ReadStrFromMany(2,rvStr,'=')),1,evaluatedOK);
        if Length(rvPar) > 0 then
          if evaluatedOK then
          begin
            rvNum := -1;
            for rvV := 0 to High(spiceVariables) do
              if spiceVariables[rvV].Name = ANSIString(rvPar) then
                rvNum := rvV;
            if rvNum = -1 then
            begin
              SetLength(spiceVariables,Length(spiceVariables)+1);
              rvNum := High(spiceVariables);
            end;
            with spiceVariables[rvNum] do
            begin
              Name := ANSIString(rvPar);
              Value := rvValue;
            end;
            for rv2 := 0 to High(sweeps) do
            begin
              if LowerCase(String(sweeps[rv2].SweepVar)) = rvPar then
                sweeps[rv2].Nominal := spiceVariables[rvNum].Value; // Store the nominal value
            end;
          end
          else
             inc(rvParamsUnknown);


(*      repeat  // read all parameters in the line
        // Firstly, evaluate expressions if there are any
        repeat
          noExpressions := true;
          if (pos('{',rvStr) > 0) then
          begin
            if (pos('}',rvStr) > 0) and (pos('}',rvStr) > pos('{',rvStr)) then
            begin
              rvLeft := copy(rvStr,1,pos('{',rvStr)-1);
              if pos('}',rvStr) < Length(rvStr) then
                rvRight := copy(rvStr,pos('}',rvStr)+1,Length(rvStr)-pos('}',rvStr))
              else
                rvRight := '';
              rvSnippet := copy(rvStr,pos('{',rvStr)+1,pos('}',rvStr) - pos('{',rvStr)-1);
              rvValue := EvaluateSpiceExpression(rvSnippet,1);
              rvSnippet := FloatToStrF(rvValue,ffGeneral,6,4);
              rvStr := rvLeft + rvSnippet + rvRight;
              noExpressions := false;
            end;
          end;
        until noExpressions;

        if pos(',',rvStr) > 0 then
        begin
          rvSubStr := StripSpaces(copy(rvStr,1,pos(',',rvStr)-1));
          Delete(rvStr,1,pos(',',rvStr));
          rvStr := StripSpaces(rvStr);
        end
        else
        begin
          rvSubStr := rvStr;
          rvStr := '';
        end;
        rvPar := LowerCase(ReadStrFromMany(1,rvSubStr,'='));
        if Length(rvPar) > 0 then
          begin
            rvNum := -1;
            for rvV := 0 to High(spiceVariables) do
              if spiceVariables[rvV].Name = ANSIString(rvPar) then
                rvNum := rvV;
            if rvNum = -1 then
            begin
              SetLength(spiceVariables,Length(spiceVariables)+1);
              rvNum := High(spiceVariables);
            end;
            with spiceVariables[rvNum] do
            begin
              Name := ANSIString(rvPar);
              Value := ConvertToValue(rvSubStr);
            end;
            for rv2 := 0 to High(sweeps) do
            begin
              if LowerCase(String(sweeps[rv2].SweepVar)) = rvPar then
                sweeps[rv2].Nominal := spiceVariables[rvNum].Value; // Store the nominal value
            end;
          end;
      until rvStr = '';   // of Parameter block
*)
      end;
    until (rv1 >= High(rvDeckLines));
    if (rvParamsUnknown = rvParamsUnknownLast) and (rvParamsUnknown > 0) then
      ExitWithHaltCode('Cannot resolve all .param statements in netlist '+String(rvDeckLines[0]),1);
  until (rvParamsUnknown = rvParamsUnknownLast) or (rvParamsUnknown = 0);
end; // ReadVariablesFromSpiceDeck
{ --------------------------- ReadSweepFromControl --------------------------- }
procedure ReadSweepFromControl(rsText : string);

var
  rsFoundSweep : Boolean;
  rsStart, rsInc, rsStop : double;
  rsVariable : string;

begin
  rsStop := 0;
  rsStart := 0;
  rsInc := 0;
  rsFoundSweep := True;
  if Length(ReadStrFromMany(2,rsText,' ')) < 41 then
    rsVariable := ReadStrFromMany(2,rsText,' ')
  else
  begin
    EchoLn('Sweep variable name limited to 40 characters. '+rsVariable+' ignored.');
    rsFoundSweep := False;
  end;
  if CheckIfReal(ReadStrFromMany(3,rsText,' ')) then
    rsStart := StrToFloat(ReadStrFromMany(3,rsText,' '))
  else
  begin
    rsFoundSweep := False;
    EchoLn(ReadStrFromMany(3,rsText,' ')+' is not a real number in sweep statement. Sweep ignored.');
  end;
  if CheckIfReal(ReadStrFromMany(4,rsText,' ')) then
    rsInc := StrToFloat(ReadStrFromMany(4,rsText,' '))
  else
  begin
    rsFoundSweep := False;
    EchoLn(ReadStrFromMany(4,rsText,' ')+' is not a real number in sweep statement. Sweep ignored.');
  end;
  if CheckIfReal(ReadStrFromMany(5,rsText,' ')) then
    rsStop := StrToFloat(ReadStrFromMany(5,rsText,' '))
  else
  begin
    rsFoundSweep := False;
    EchoLn(ReadStrFromMany(5,rsText,' ')+' is not a real number in sweep statement. Sweep ignored.');
  end;
  if (rsStop > rsStart) and (rsInc < 0) then
    begin
      rsFoundSweep := FALSE; // Can't allow increments that move away from STOP value...
      EchoLn('SWEEP increment is negative, but stop > start.');
    end;
  if (rsStop < rsStart) and (rsInc > 0) then
    begin
      rsFoundSweep := FALSE; // Can't allow increments that move away from STOP value...
      EchoLn('SWEEP increment is positive, but stop < start.');
    end;
  if rsFoundSweep then
  begin
    SetLength(sweeps,Length(sweeps)+1);
    with sweeps[High(sweeps)] do
    begin
      SweepVar := ANSIString(rsVariable);
      Start := rsStart;
      Inc := rsInc;
      Stop := rsStop;
      SetLength(FunctionalAtStep,0);
    end;
  end;
end; // ReadSweepFromControl
{ ------------------------------ ReadDefFile --------------------------------- }
procedure ReadDefFile;

var
  dText, dPar, dParBlock : String;
  dReadBlock : Boolean;
  defFile : TextFile;

{ --- internal procedure --- }
procedure ReadSpiceBlockInDefFile(var rsDeckLines : TSpiceDeckLine);

begin
  dReadBlock := True;
  repeat
    ReadCleanLn(defFile, dText);
    if dText <> '' then
      if copy(dText,1,1) <> '$' then
      begin
        if ANSIChar(dText[1]) in ['l','b'] then
          dText := StringReplace(dText,'_','u',[rfReplaceAll]);
        SetLength(rsDeckLines, Length(rsDeckLines)+1);
        rsDeckLines[High(rsDeckLines)] := ANSIString(dText);
      end;
  until StripSpaces(LowerCase(dText)) = '$end';
  ReadVariablesFromSpiceDeck(rsDeckLines);
end;
{ -------------------------- }
begin
  AssignFile(defFile, ParamStr(defFileParam));
  {$I-}
  Reset(defFile);
  {$I+}
  if IOResult <> 0 then        // problem with definitions file
    ExitWithHaltCode('Error while trying to open definitions file. Check if '+ParamStr(defFileParam)+' exists. Abort.', 20);
  repeat
    ReadCleanLn(defFile, dtext);  // start sifting through definitions file
    dParBlock := ReadStrFromMany(1, dText, ' ');
    if dText[1] = '$' then
    begin
      dReadBlock := False;
      if dParBlock = '$parameters' then   // Read parameters;
      begin
        dReadBlock := True;
        repeat  // read parameter block in definitions file
          ReadCleanLn(defFile,dText);
          dPar := ReadStrFromMany(1, dText, '=');
          if dPar = 'sourcetype' then
          begin
            if ReadStrFromText(dText) = 'current' then sourceType := Current;
            if ReadStrFromText(dText) = 'voltage' then sourceType := Voltage;
          end;
          if dPar = 'sourceamplitude' then
            sourceAmplitude := ReadRealFromText(dText,0,'Error reading "SourceAmplitude" from '+ParamStr(defFileParam)+'.');
          if dPar = 'sourcerisetime' then sourceRiseTime := ReadRealFromText(dText,1E-12,'Error reading "SourceRistTime" from '+ParamStr(defFileParam)+'.');
          if dPar = 'sourcefalltime' then sourceFallTime := ReadRealFromText(dText,1E-12,'Error reading "SourceFallTime" from '+ParamStr(defFileParam)+'.');
          if dPar = 'timefirststable' then timeFirstStable := ReadRealFromText(dText,10E-12,'Error reading "TimeFirstStable" from '+ParamStr(defFileParam)+'.');
          if dPar = 'waitforstatechange' then waitForStateChange := ReadRealFromText(dText,50E-12,'Error reading "WaitForStateChange" from '+ParamStr(defFileParam)+'.');
          if dPar = 'slidingintegratorlength' then slidingIntegratorLength := ReadRealFromText(dText,10E-12,'Error reading "SlidingIntegratorLength" from '+ParamStr(defFileParam)+'.');
          if dPar = 'pulsedetectthreshold' then pulseDetectThreshold := ReadRealFromText(dText,0.5,'Error reading "pulseDetectThreshold" from '+ParamStr(defFileParam)+'.');
          if dPar = 'pulsefluxonfraction' then pulseFluxonFraction := ReadRealFromText(dText,0.9,'Error reading "pulseFluxonFraction" from '+ParamStr(defFileParam)+'.');
          if dPar = 'ctdependencythreshold' then ctDependencyThreshold := ReadRealFromText(dText,0.1E-12,'Error reading "CTDependencyThreshold" from '+ParamStr(defFileParam)+'.');
          if dPar = 'maxdelaychange' then maxDelayChange := ReadRealFromText(dText,1E-12,'Error reading "MaxDelayChange" from '+ParamStr(defFileParam)+'.');
          if dPar = 'maxselfdelaychange' then maxSelfDelayChange := ReadRealFromText(dText,1E-12,'Error reading "MaxSelfDelayChange" from '+ParamStr(defFileParam)+'.');
          if dPar = 'minsameinputseparation' then minSameInputSeparation := ReadRealFromText(dText,5E-12,'Error reading "MinSameInputSeparation" from '+ParamStr(defFileParam)+'.');
          if dPar = 'verilogstabletime' then verilogStableTime := ReadRealFromText(dText,10E-12,'Error reading "VerilogStableTime" from '+ParamStr(defFileParam)+'.');
          if dPar = 'verilogwaittime' then verilogWaitTime := ReadRealFromText(dText,10E-12,'Error reading "VerilogWaitTime" from '+ParamStr(defFileParam)+'.');
          if dPar = 'inputchaindelay' then inputChainDelay := ReadRealFromText(dText,7E-12,'Error reading "InputChainDelay" from '+ParamStr(defFileParam)+'.');
          if dPar = 'numbersimstolerance' then numSimsTol := ReadIntFromText(dText,0,'Error reading "NumberSimsTolerance" from '+ParamStr(defFileParam)+'.');
          if dPar = 'noisetemperature' then noiseTemp := ReadRealFromText(dText,-1,'Error reading "NoiseTemperature" from '+ParamStr(defFileParam)+'.');
          if dPar = 'simtimestep' then simTimeStep := ReadRealFromText(dText,0.25E-12,'Error reading "SimTimeStep" from '+ParamStr(defFileParam)+'.');
          if dPar = 'iofullfluxon' then
            if ReadStrFromText(dtext) = 'false' then ioFullFluxon := False;
        until dPar = '$end';   // of Parameter block
      end;
      if dParBlock = '$control' then   // Read parameters;
      begin
        dReadBlock := True;
        repeat  // read parameter block in definitions file
          ReadCleanLn(defFile,dText);
          dPar := ReadStrFromMany(1, dText, ' ');
          if dPar = 'sweep' then
            if containedVerilog then
            begin
              ReadSweepFromControl(dText);
            end
            else
              EchoLn('Swept parameters not supported with SDF file. "'+dText+'" ignored.');
        until dPar = '$end';   // of Control block
      end;
      if dParBlock = '$defaultloadin' then   // Read input load block;
        ReadSpiceBlockInDefFile(spiceLoadInLines);
      if dParBlock = '$defaultloadout' then   // Read output load block;
        ReadSpiceBlockInDefFile(spiceLoadOutLines);
      if dParBlock = '$defaultsink' then   // Read sink block;
        ReadSpiceBlockInDefFile(spiceSinkLines);
      if dParBlock = '$defaultsource' then   // Read source block;
        ReadSpiceBlockInDefFile(spiceSourceLines);
      if not dReadBlock then
        ExitWithHaltCode('Block identifier '+dParBlock+' in '+ParamStr(defFileParam)+' not recognised. Halted.',0);
    end;
  until eof(defFile);
  if pulseDetectThreshold > 0.95 then
  begin
    EchoLn('Pulse detection threshold too large; limited to 0.90*Phi0.');
    pulseDetectThreshold := 0.9;
  end;
  if pulseDetectThreshold < 0.1 then
  begin
    EchoLn('Pulse detection threshold too low; limited to 0.10*Phi0.');
    pulseDetectThreshold := 0.1;
  end;
  EchoLn('Definition file read.');
end; // ReadDefFile
{ --------------------------- ReadSpiceFileToMem ----------------------------- }
procedure ReadSpiceFileToMem(rsFileName : string; var rsMemLines : TSpiceDeckLine; rsMessage : string);

var
  rsFile : TextFile;
  rsTextLine : string;

begin
  SetLength(rsMemLines,0); // Reset the dynamic array to zero, in case it was read from definition file.
  AssignFile(rsFile,rsFileName);
  {$I-}
  reset(rsFile);
  {$I+}
  if IOResult <> 0 then        // problem with .cir or .js spice file
    ExitWithHaltCode('Error while trying to open netlist for load deck. Check if '+rsFileName+' exists. Abort.', 8);
  while not eof(rsFile) do
  begin
    ReadLn(rsFile, rsTextLine);
    rsTextLine := StringReplace(rsTextLine,#9,' ',[rfReplaceAll]); // Replace TAB characters with spaces
    if length(rsTextLine) > 1 then
    begin
      if ANSIChar(rsTextLine[1]) in ['l','L','b','B'] then
        // Replace underscore characters in L/B element names with 'u' - otherwise the print command fails for subcircuit elements
        rsTextLine := StringReplace(rsTextLine,'_','u',[rfReplaceAll]);
      SetLength(rsMemLines, Length(rsMemLines)+1);       // Increase length of dynamic array.
      rsMemLines[High(rsMemLines)] := ANSIString(rsTextLine);         // Write rsTextLine to memory.
    end;
  end;
  ReadVariablesFromSpiceDeck(rsMemLines);
  EchoLn(rsMessage);
  CloseFile(rsFile);
end; // ReadSpiceFileToMem
{ --------------------------- FindFirstPulseTime ----------------------------- }
function FindFirstPulseTime(fFileName : String; fStartTime : Double; fIndex : Integer) : Double;

var
  f1 : Integer;
  fTimeInFile, fTimeStep, fTimePrev, fThresholdTime, fAcc : Double;
  fText : String;
  fDone : Boolean;
  fSlidingWindow : array of Double;
  fFile : TextFile;
  fSeparator : String;

begin
  fTimeInFile := 0;
  fSeparator := ',';
  if useJSIM then
    fSeparator := ' ';
  AssignFile(fFile,fFileName);
  {$I-}
  Reset(fFile);
  {$I+}
  if IOResult <> 0 then        // problem with .dat file
    ExitWithHaltCode('Error while trying to open JSIM output file "'+fFileName+'". Abort.', 102);
  ReadLn(fFile,fText);  // First line of .csv or .dat file contains variable identifiers.
  fTimeStep := -1; // Startup
  fTimePrev := -1;
  repeat
    ReadLn(fFile,fText);
    if CheckIfReal(ReadStrFromMany(1,fText,fSeparator)) then
      fTimeInFile := StrToFloat(ReadStrFromMany(1,fText,fSeparator));
    if (fTimeInFile > 1e-20) and (fTimeStep < 0) then
      if fTimePrev < 0 then
      begin
        fTimePrev := fTimeInFile;
      end
      else
        fTimeStep := fTimeInFile-fTimePrev;
  until (fTimeInFile > fStartTime) or (eof(fFile));
  if (eof(fFile) or (fTimeStep < 1.1e-20)) then
  begin
    CloseFile(fFile);                               // Not good. Return 0.
    FindFirstPulseTime := 0;
    Exit;
  end;
  fDone := False;
  fThresholdTime := -1;
  SetLength(fSlidingWindow,round(slidingIntegratorLength/fTimeStep));
  for f1 := 0 to High(fSlidingWindow) do
    fSlidingWindow[f1] := 0;
  while not fDone do
  begin
    ReadLn(fFile,fText);
    if eof(fFile) then
    begin
      CloseFile(fFile);
      FindFirstPulseTime := 0;
      Exit;
    end;
    for f1 := 0 to (High(fSlidingWindow)-1) do  // Slide back
      fSlidingWindow[f1] := fSlidingWindow[f1+1];
    fTimeInFile := StrToFloat(ReadStrFromMany(1,fText,fSeparator));
    fSlidingWindow[High(fSlidingWindow)] := StrToFloat(ReadStrFromMany(fIndex,fText,fSeparator));
    fAcc := 0;
    for f1 := 1 to High(fSlidingWindow) do // Integrate
      fAcc := fAcc + (fSlidingWindow[f1]+fSLidingWindow[f1-1])/2*fTimeStep;
    if (fThresholdTime < 0) and (fAcc > (pulseDetectThreshold*pulseFluxonFraction)*PHI_0) then
      fThresholdTime := fTimeInFile;
    if (fAcc > pulseFluxonFraction*PHI_0) and ((fTimeInFile - fThresholdTime) < slidingIntegratorLength)  then
      fDone := True;                           // Pulse is valid
  end;
  SetLength(fSlidingWindow,0);
  FindFirstPulseTime := fThresholdTime;
  CloseFile(fFile);
end; // FindFirstPulseTime
{ --------------------------- FindSecondPulseTime ---------------------------- }
function FindSecondPulseTime(fFileName : String; fStartTime, fStopTime : Double; fIndex : Integer) : Double;

var
  f1 : Integer;
  fTimeInFile, fTimeStep, fTimePrev, fThresholdTime, fAcc : Double;
  fText : String;
  fDone : Boolean;
  fSlidingWindow : array of Double;
  fFile : TextFile;
  fSeparator : String;

begin
  fTimeInFile := 0;
  fSeparator := ',';
  if useJSIM then
    fSeparator := ' ';
  AssignFile(fFile,fFileName);
  {$I-}
  Reset(fFile);
  {$I+}
  if IOResult <> 0 then        // problem with .dat file
    ExitWithHaltCode('Error while trying to open JSIM output file "'+fFileName+'". Abort.', 102);
  ReadLn(fFile,fText);  // First line of .dat file contains variable identifiers.
  fTimeStep := -1; // Startup
  fTimePrev := -1;
  repeat
    ReadLn(fFile,fText);
    if CheckIfReal(ReadStrFromMany(1,fText,fSeparator)) then
      fTimeInFile := StrToFloat(ReadStrFromMany(1,fText,fSeparator));
    if (fTimeInFile > 1e-20) and (fTimeStep < 0) then
      if fTimePrev < 0 then
      begin
        fTimePrev := fTimeInFile;
      end
      else
        fTimeStep := fTimeInFile-fTimePrev;
  until (fTimeInFile > fStartTime) or (eof(fFile));
  if (eof(fFile) or (fTimeStep < 1.1e-20)) then
  begin
    CloseFile(fFile);                               // Not good. Return 0.
    FindSecondPulseTime := 0;
    Exit;
  end;
  fDone := False;
  fThresholdTime := -1;
  SetLength(fSlidingWindow,round((fStopTime-fStartTime)/fTimeStep));
  for f1 := 0 to High(fSlidingWindow) do
    fSlidingWindow[f1] := 0;
  while not fDone do
  begin
    ReadLn(fFile,fText);
    if eof(fFile) then
    begin
      CloseFile(fFile);
      FindSecondPulseTime := 0;
      Exit;
    end;
    for f1 := 0 to (High(fSlidingWindow)-1) do  // Slide back
      fSlidingWindow[f1] := fSlidingWindow[f1+1];
    fTimeInFile := StrToFloat(ReadStrFromMany(1,fText,fSeparator));
    fSlidingWindow[High(fSlidingWindow)] := StrToFloat(ReadStrFromMany(fIndex,fText,fSeparator));
    fAcc := 0;
    for f1 := 1 to High(fSlidingWindow) do // Integrate
      fAcc := fAcc + (fSlidingWindow[f1]+fSLidingWindow[f1-1])/2*fTimeStep;
//    if (fThresholdTime < 0) and (fAcc > (pulseDetectThreshold*PHI_0 + PHI_0)) then
    if (fThresholdTime < 0) and (fAcc > (pulseDetectThreshold*pulseFluxonFraction*PHI_0 + pulseFluxonFraction*PHI_0)) then
      fThresholdTime := fTimeInFile;
    if fAcc > (pulseFluxonFraction*(PHI_0 + PHI_0))  then
      fDone := True;                           // Pulse is valid
  end;
  SetLength(fSlidingWindow,0);
  FindSecondPulseTime := fThresholdTime;
  CloseFile(fFile);
end; // FindSecondPulseTime
{ --------------------------- FindSecondPulseTime ---------------------------- }
function FindNthPulseTime(fFileName : String; fPulseNumber : integer; fStartTime, fStopTime : Double; fIndex : Integer) : Double;

var
  f1 : Integer;
  fTimeInFile, fTimeStep, fTimePrev, fThresholdTime, fAcc : Double;
  fText : String;
  fDone : Boolean;
  fSlidingWindow : array of Double;
  fFile : TextFile;
  fSeparator : String;

begin
  fTimeInFile := 0;
  fSeparator := ',';
  if useJSIM then
    fSeparator := ' ';
  AssignFile(fFile,fFileName);
  {$I-}
  Reset(fFile);
  {$I+}
  if IOResult <> 0 then        // problem with .dat file
    ExitWithHaltCode('Error while trying to open JSIM output file "'+fFileName+'". Abort.', 102);
  ReadLn(fFile,fText);  // First line of .dat file contains variable identifiers.
  fTimeStep := -1; // Startup
  fTimePrev := -1;
  repeat
    ReadLn(fFile,fText);
    if CheckIfReal(ReadStrFromMany(1,fText,fSeparator)) then
      fTimeInFile := StrToFloat(ReadStrFromMany(1,fText,fSeparator));
    if (fTimeInFile > 1e-20) and (fTimeStep < 0) then
      if fTimePrev < 0 then
      begin
        fTimePrev := fTimeInFile;
      end
      else
        fTimeStep := fTimeInFile-fTimePrev;
  until (fTimeInFile > fStartTime) or (eof(fFile));
  if (eof(fFile) or (fTimeStep < 1.1e-20)) then
  begin
    CloseFile(fFile);                               // Not good. Return 0.
    FindNthPulseTime := 0;
    Exit;
  end;
  fDone := False;
  fThresholdTime := -1;
  SetLength(fSlidingWindow,round((fStopTime-fStartTime)/fTimeStep));
  for f1 := 0 to High(fSlidingWindow) do
    fSlidingWindow[f1] := 0;
  while not fDone do
  begin
    ReadLn(fFile,fText);
    if eof(fFile) then
    begin
      CloseFile(fFile);
      FindNthPulseTime := 0;
      Exit;
    end;
    for f1 := 0 to (High(fSlidingWindow)-1) do  // Slide back
      fSlidingWindow[f1] := fSlidingWindow[f1+1];
    fTimeInFile := StrToFloat(ReadStrFromMany(1,fText,fSeparator));
    fSlidingWindow[High(fSlidingWindow)] := StrToFloat(ReadStrFromMany(fIndex,fText,fSeparator));
    fAcc := 0;
    for f1 := 1 to High(fSlidingWindow) do // Integrate
      fAcc := fAcc + (fSlidingWindow[f1]+fSLidingWindow[f1-1])/2*fTimeStep;
    if (fThresholdTime < 0) and (fAcc > (pulseDetectThreshold*PHI_0 + (fPulseNumber-1)*PHI_0)) then
      fThresholdTime := fTimeInFile;
    if fAcc > (pulseFluxonFraction*PHI_0 + (fPulseNumber-1)*PHI_0)  then
      fDone := True;                           // Pulse is valid
  end;
  SetLength(fSlidingWindow,0);
  FindNthPulseTime := fThresholdTime;
  CloseFile(fFile);
end; // FindNthPulseTime



end.
