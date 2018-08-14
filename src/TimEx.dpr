program TimEx;

{*******************************************************************************
*                                                                              *
* Author    :  Coenrad Fourie                                                  *
* Version   :  2.03.01                                                            *
* Date      :  August 2018                                                     *
* Copyright (c) 2016-2018 Coenrad Fourie                                       *
*                                                                              *
* Timing extractor and Verilog HDL file writer for SFQ logic cells.            *
* Developed originally under IARPA-BAA-14-03  (v1.0)                           *
* Improved by Stellenbosch University under IARPA-BAA-16-03 (v2.0)             *
*                                                                              *
* Last modification: 14 August 2018                                            *
*      Support for SDF timing files, vcd_assert and JoSIM added                *
*      Linux build improved                                                    *
*      Parameter sweeps, PTL interconnects and parameter functions added       *
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

{$IFDEF MSWINDOWS}
{$DEFINE Windows}
{$APPTYPE CONSOLE}
{$ENDIF MSWINDOWS}

{$R *.res}

uses
  {$IFDEF MSWINDOWS}
  System.SysUtils,
  System.Math,
  {$ELSE}
  SysUtils,
  Math,
  {$ENDIF }
  TX_FileIn in 'TX_FileIn.pas',
  TX_FileOut in 'TX_FileOut.pas',
  TX_Globals in 'TX_Globals.pas',
  TX_Math in 'TX_Math.pas',
  TX_Strings in 'TX_Strings.pas',
  TX_Tools in 'TX_Tools.pas',
  TX_Cycles in 'TX_Cycles.pas',
  TX_Utils in 'TX_Utils.pas';

{ -------------------------------- BlurbHelp --------------------------------- }
procedure BlurbHelp;

begin
  Writeln; WriteLn('TimeEx extracts timing parameters from an SFQ logic cell defined');
  WriteLn('in a JoSIM deck. It is assumed that the nominal circuit works correctly.');
  WriteLn('The first parameter MUST be the JoSIM file of the DUT (.js; .cir).');
  WriteLn;
  WriteLn(' Options: (Case senstive arguments.)');
  WriteLn('  -a              = Select JSIM_n as the simulation engine.');
  WriteLn('  -c              = Write self-contained Verilog module (no SDF files).');
  WriteLn('  -d filename.txt = Definition file.');
  WriteLn('  -e filename.js  = Circuit deck for source cell.');
  WriteLn('  -L filename.js  = Circuit deck for output load cell.');
  WriteLn('  -l filename.js  = Circuit deck for input load cell.');
  WriteLn('  -o filename.txt = Write state map to text file.');
  WriteLn('  -s filename.js  = Circuit deck for sink cell.');
  WriteLn('  -v              = Verbose mode on.');
  WriteLn('  -x              = Execute JoSIM/JSIM_n, iverilog, vvp and dot on output');
  WriteLn('                    files.');
  WriteLn; WriteLn('For more detail, see:');
  WriteLn('[1] L.C. Muller, and C.J. Fourie, Automated State Machine and timing');
  WriteLn('characteristic extraction for RSFQ circuits, IEEE Trans. Appl. Supercond.,');
  WriteLn('vol. 24, 1300110, 2014.');
  WriteLn('[2] C.J. Fourie, Extraction of SFQ circuit Verilog models through flux loop');
  WriteLn('analysis, IEEE Trans. Appl. Supercond., vol. 28, 1300811, 2018.');
  WriteLn;
  WriteLn; WriteLn('For user support, e-mail your questions to coenrad@sun.ac.za'); WriteLn;
end; // BlurbHelp
{ -------------------------------- Initiate ---------------------------------- }
procedure Initiate;
// Set variables at startup
var
  i1 : Integer;

begin
  FormatSettings.DecimalSeparator := '.';  // Make SURE that OS localization is overloaded with our default,
        // otherwise floating point numbers cannot be read from strings in France / Germany
  Randomize;
  defFileParam := 0; {loadFileParam := 0;} sinkFileParam := 0; sourceFileParam := 0;    // Initialize values.
  loadInFileParam := 0;
  loadOutFileParam := 0;
  stateMapFileParam := 0;
  SetLength(spiceDUTLines, 0);
  SetLength(spiceLoadInLines, 0);
  SetLength(spiceLoadOutLines, 0);
  SetLength(spiceSinkLines, 0);
  SetLength(spiceSourceLines, 0);
  SetLength(elements,0);
  SetLength(jjModels,0);
  SetLength(dutInput, 0);
  SetLength(dutOutput, 0);
  SetLength(sweeps, 0);
  SetLength(spiceVariables, 0);
  dutCellName := '';
  SetLength(cycleFlux,0);
  timeFirstStable := 10E-12;         // Default time at which startup state is investigated.
  waitForStateChange := 50E-12;      // Default time between inputs when state response to inputs are evaluated.
  sourceType := Current;             // Default input source type;
  slidingIntegratorLength := 10E-12; // Default time length of sliding window over which Integral(V.dt) is calculated to search for pulses
  pulseDetectThreshold := 0.5;       // Default integration threshold (as a fraction of Phi0) to indicate a detected pulse.
  ctDependencyThreshold := 0.1E-12;  // Default minimum threshold for Critical Timing Dependence (between two inputs)
  pulseFluxonFraction := 0.9;        // Default minimum integration area (as a fraction of Phi0) to validate a detected pulse.
  maxDelayChange := 1E-12;           // Default maximum time that in->out delay may shift from nominal when critical timing is approached. Beyond this, error condition flagged.
  maxSelfDelayChange := 1E-12;       // Default maximum time that in->out delay may shift from nominal when pulse repulsion time is approached on one input. Beyond this, error condition flagged.
  minSameInputSeparation := 5E-12;   // Default minimum time between test bench application of pulses to the same input if ioFullFluxon = false.
  verilogStableTime := 10E-12;       // Default verilog testbench simulation model time to first input in startup state.
  verilogWaitTime := 10E-12;         // Default verilog testbench simulation model time between inputs.
  inputChainDelay := 7E-12;          // Default delay of input chain (from JoSIM source input through load cell to DUT input) - used to match JSIM testbench to Verilog testbench
  ioFullFluxon := true;              // Default handles all input/output pulses as full fluxons. Set false for PTL-based I/O.
  applyRandom := false;              // Startup simulations - do not apply random variations.
  numSimsTol := 0;                   // Default is no tolerance simulations
  noiseTemp := -1;                   // Default is no noise simulations
  simTimeStep := 0.25E-12;           // Default JoSIM simulation time step
  useJSIM := false;                  // By default, JoSIM used. useJSIM overrides that.
  containedVerilog := false;         // By default, output will be to the format required by vcd_assert.
  runTB := False;
  verboseMode := false;
  AssignFile(OutFile,'out.txt');
  {$I-}
  Rewrite(OutFile);
  {$I+}
  if ioResult <> 0 then
  begin
    WriteLn('Error writing file ''out.txt''');
    Halt(1);
  end;
  EchoLn('TimEx v' + VersionNumber + ' ('+BuildDate+'). ' + CopyrightNotice);
  // Write License notice
  WriteLn;
  WriteLn('This program comes with ABSOLUTELY NO WARRANTY.');
  WriteLn;
  // Read Parameters
  if ParamCount < 1 then
  begin
    Writeln('Filename required, e.g.');
    Writeln('  timex and.js [-d definitions.txt] [-l gen_load.js] [-s gen_sink.js]');
    Writeln; WriteLn('  Type ''timex -h'' or ''timex /?'' or ''timex -?'' for help.'); Writeln; halt(0);
  end
  else
    if (ParamStr(1) = '-h') or (ParamStr(1) = '-?') or (ParamStr(1) = '/h') or (ParamStr(1) =  '/?') or (ParamStr(1) = '-H') or (ParamStr(1) = '/H') then
    begin
      BlurbHelp; halt(0);
    end;
  for i1 := 1 to ParamCount do
  begin
    if ParamStr(i1) = '-a' then useJSIM := True;
    if ParamStr(i1) = '-c' then containedVerilog := True;   
    if ParamStr(i1) = '-d' then defFileParam := i1+1;
    if ParamStr(i1) = '-e' then sourceFileParam := i1+1;
    if ParamStr(i1) = '-L' then loadInFileParam := i1+1;
    if ParamStr(i1) = '-l' then loadOutFileParam := i1+1;
    if ParamStr(i1) = '-o' then stateMapFileParam := i1+1;
    if ParamStr(i1) = '-s' then sinkFileParam := i1+1;
    if ParamStr(i1) = '-v' then verboseMode := True;    
    if ParamStr(i1) = '-x' then runTB := True; //  Run the testbench simulations
  end;
  if defFileParam < 1 then
    ExitWithHaltCode('No definition file specified.', 7);
  cellNameStr := ParamStr(1);
  if stateMapFileParam > 0 then
  begin
    if copy(ParamStr(stateMapFileParam),1,1) <> '-' then
      stateMapFileName := ParamStr(stateMapFileParam)
    else
      stateMapFileName := 'statemap.txt'; // Default name
  end;
  // Now cut out any subdirectories from name.
{$IFDEF MSWINDOWS}
  while pos('\',cellNameStr) > 0 do
    Delete(cellNameStr,1,pos('\',cellNameStr));
  cellNameStr := copy(cellNameStr,1,pos('.',cellNameStr)-1);
{$ELSE}
  while pos('/',cellNameStr) > 0 do
    Delete(cellNameStr,1,pos('/',cellNameStr));
  cellNameStr := copy(cellNameStr,1,pos('.',cellNameStr)-1);
{$ENDIF}
  engineName := 'josim';
  simResultFilename := '-o simout.csv';
  simResultFileSuffix := 'csv';
  if useJSIM then
  begin
    engineName := 'jsim_n';
    simResultFilename := '-m simout.dat';
    simResultFileSuffix := 'dat';
  end;
  ReadDefFile;
  // We require the first parameter to be the DUT spice/josim file, unless a call to HELP was fielded.
  ReadSpiceFileToMem(ParamStr(1),spiceDUTLines,'Deck for Device-Under-Test read.');
  if loadInFileParam > 0 then  // Override any default loaded from definition file, and read the input load directly from netlist
    ReadSpiceFileToMem(ParamStr(loadInFileParam),spiceLoadInLines,'Deck for Input Load read.');
  if loadOutFileParam > 0 then  // Override any default loaded from definition file, and read the output load directly from netlist
    ReadSpiceFileToMem(ParamStr(loadOutFileParam),spiceLoadOutLines,'Deck for Output Load read.');
  if sinkFileParam > 0 then  // Override any default loaded from definition file, and read the sink directly from netlist
    ReadSpiceFileToMem(ParamStr(sinkFileParam),spiceSinkLines,'Deck for Sink read.');
  if sourceFileParam > 0 then  // Override any default loaded from definition file, and read the source directly from netlist
    ReadSpiceFileToMem(ParamStr(sourceFileParam),spiceSourceLines,'Deck for Source read.');
  if (Length(spiceLoadInLines) > 0) and (Length(spiceLoadOutLines) = 0) then
    spiceLoadOutLines := spiceLoadInLines; // If output load not specified, then assume same as input load, and duplicate
  if (Length(spiceLoadOutLines) > 0) and (Length(spiceLoadInLines) = 0) then
    spiceLoadInLines := spiceLoadOutLines; // If input load not specified, then assume same as output load, and duplicate
  if (Length(spiceLoadInLines) = 0) or (Length(spiceLoadOutLines) = 0) then ExitWithHaltCode('No load deck specified.', 21);
  if Length(spiceSinkLines) = 0 then ExitWithHaltCode('No sink deck specified.', 22);
  if Length(spiceSourceLines) = 0 then ExitWithHaltCode('No source deck specified.', 23);
end; // Initiate
{ ------------------------------ FormatDecks --------------------------------- }
procedure FormatDecks;

var
  f1, f2 : Integer;
  fStr, fPortNameStr, fPortNodeStr : String;
  fSubDetected : Boolean;

begin
  fSubDetected := False;
  for f1 := 0 to High(spiceLoadInLines) do
  begin
    if LowerCase(String(Copy(spiceLoadInLines[f1],1,8))) = '.subckt ' then
    begin
      if fSubDetected then
        ExitWithHaltCode('Multiple subcircuit definitions detected in input load netlist. This is not allowed.',30)
      else
        fSubDetected := True;
      fStr := ReadStrFromMany(2,String(spiceLoadInLines[f1]),' ');
      spiceLoadInLines[f1] := '.SUBCKT LOADINCELL '+copy(spiceLoadInLines[f1],pos(fStr,String(spiceLoadInLines[f1]))
                              +Length(fStr),Length(spiceLoadInLines[f1])-(pos(fStr,String(spiceLoadInLines[f1]))+Length(fStr))+1);
    end;
    if LowerCase(String(Copy(spiceLoadInLines[f1],1,6))) = '.ends ' then
      spiceLoadInLines[f1] := '.ENDS LOADINCELL';
  end;
  fSubDetected := False;
  for f1 := 0 to High(spiceLoadOutLines) do
  begin
    if LowerCase(String(Copy(spiceLoadOutLines[f1],1,8))) = '.subckt ' then
    begin
      if fSubDetected then
        ExitWithHaltCode('Multiple subcircuit definitions detected in output load netlist. This is not allowed.',30)
      else
        fSubDetected := True;
      fStr := ReadStrFromMany(2,String(spiceLoadOutLines[f1]),' ');
      spiceLoadOutLines[f1] := '.SUBCKT LOADOUTCELL '+copy(spiceLoadOutLines[f1],pos(fStr,String(spiceLoadOutLines[f1]))
                               +Length(fStr),Length(spiceLoadOutLines[f1])-(pos(fStr,String(spiceLoadOutLines[f1]))+Length(fStr))+1);
    end;
    if LowerCase(String(Copy(spiceLoadOutLines[f1],1,6))) = '.ends ' then
      spiceLoadOutLines[f1] := '.ENDS LOADOUTCELL';
  end;
  fSubDetected := False;
  for f1 := 0 to High(spiceSinkLines) do
  begin
    if LowerCase(String(Copy(spiceSinkLines[f1],1,8))) = '.subckt ' then
    begin
      if fSubDetected then
        ExitWithHaltCode('Multiple subcircuit definitions detected in sink netlist. This is not allowed.',31)
      else
        fSubDetected := True;
      fStr := ReadStrFromMany(2,String(spiceSinkLines[f1]),' ');
      spiceSinkLines[f1] := '.SUBCKT SINKCELL '+copy(spiceSinkLines[f1],pos(fStr,String(spiceSinkLines[f1]))
                            +Length(fStr),Length(spiceSinkLines[f1])-(pos(fStr,String(spiceSinkLines[f1]))+Length(fStr))+1);
    end;
    if LowerCase(String(Copy(spiceSinkLines[f1],1,6))) = '.ends ' then
      spiceSinkLines[f1] := '.ENDS SINKCELL';
  end;
  fSubDetected := False;
  for f1 := 0 to High(spiceSourceLines) do
    begin
      if LowerCase(String(Copy(spiceSourceLines[f1],1,8))) = '.subckt ' then
        begin
          if fSubDetected then
            ExitWithHaltCode('Multiple subcircuit definitions detected in source netlist. This is not allowed.',32)
            else fSubDetected := True;
          fStr := ReadStrFromMany(2,String(spiceSourceLines[f1]),' ');
          spiceSourceLines[f1] := '.SUBCKT SOURCECELL '+copy(spiceSourceLines[f1],pos(fStr,String(spiceSourceLines[f1]))
                                  +Length(fStr),Length(spiceSourceLines[f1])-(pos(fStr,String(spiceSourceLines[f1]))+Length(fStr))+1);
        end;
      if LowerCase(Copy(String(spiceSourceLines[f1]),1,6)) = '.ends ' then
        spiceSourceLines[f1] := '.ENDS SOURCECELL';
    end;
  fSubDetected := False;
  for f1 := 0 to High(spiceDUTLines) do
  begin
    if LowerCase(Copy(String(spiceDUTLines[f1]),1,8)) = '.subckt ' then
    begin
      if fSubDetected then
        ExitWithHaltCode('Multiple subcircuit definitions detected in DUT netlist. This is not allowed.',33)
      else
        fSubDetected := True;
      dutCellName := ReadStrFromMany(2,String(spiceDUTLines[f1]),' ');    // We need the DUT subcircuit name for later
      fStr := LowerCase(String(spiceDUTLines[f1])); // Keep a copy of this line
    end;
  end;
  for f1 := 0 to High(spiceDUTLines) do                              // get the names and node identifiers (number/string) of all inputs and outputs to DUT
  begin
    if LowerCase(Copy(String(spiceDUTLines[f1]),1,7)) = '*$ports' then
    begin
      f2 := 2;
      repeat
        fPortNameStr := LowerCase(ReadStrFromMany(f2,String(spiceDUTLines[f1]),' '));
        fPortNodeStr := ReadStrFromMany(f2+1,fStr,' '); // The .SUBCKT line has two terms before the nodes start
        Inc(f2);
        if copy(fPortNameStr,1,3) = 'in_' then
        begin
          SetLength(dutInput,Length(dutInput)+1);
          dutInput[High(dutInput)].Name := ANSIString(copy(fPortNameStr,4,Length(fPortNameStr)-3));
          dutInput[High(dutInput)].Node := ANSIString(fPortNodeStr);
        end;
        if copy(fPortNameStr,1,4) = 'out_' then
        begin
          SetLength(dutOutput,Length(dutOutput)+1);
          dutOutput[High(dutOutput)].Name := ANSIString(copy(fPortNameStr,5,Length(fPortNameStr)-4));
          dutOutput[High(dutOutput)].Node := ANSIString(fPortNodeStr);
        end;
      until (fPortNameStr = ' ') or (f2 > 255);
      if f2 > 255 then
        ExitWithHaltCode('Too many ports read from DUT subcircuit definition (256). String processing error?',34);
    end;
  end;
  if Length(dutInput) = 0 then
    ExitWithHaltCode('No inputs defined in DUT netlist. Did you define "$ports"?',120);
  if Length(dutOutput) = 0 then
    ExitWithHaltCode('No outputs defined in DUT netlist. Did you define "$ports"?',121);
end; // FormatDecks
{ -------------------------- CalculateCycleFlux ------------------------------ }
procedure CalculateCycleFlux;

var
  cLoop, cEl, cRef : Integer;
  cStr : String;
  cMult, cAcc, cJJInductance, cIOverIC : Double;

begin
  SetLength(cycleFlux,Length(cycleList));
  for cLoop := 0 to High(cycleList) do
  begin
    cAcc := 0;  // zero the flux accumulater
    for cEl := 0 to High(cycleList[cLoop]) do
    begin
      cMult := 1;
      cStr := String(cycleList[cLoop,cEl]);
      if cStr[1] = '-' then
      begin
        cMult := -1;
        Delete(cStr,1,1); // Remove the "-"
      end;
      for cRef := 0 to High(elements) do
      begin
        if String(elements[cRef].Name) = cStr then // Aah, this is the element
        begin
          if elements[cRef].Name[1] = 'l' then // It is an inductor: multiply current with inductance.
            cAcc := cAcc + elements[cRef].Current*elements[cRef].Value*cMult;  // Add the flux contribution (signed) to the accumulated cycle total
          if elements[cRef].Name[1] = 'b' then  // It's a JJ - different kettle of fish
          begin
            //// This formula is widely available, but gives results up to 1.3 Phi0...
            ///  The reason, quite simply, is that this is the small-signal equivalent inductance; only appropriate for small-signal modelling
//            cJJPhase := arcsin(elements[cRef].Current/elements[cRef].Value);   // Get the phase
//            cJJInductance := PHI_0/(2*pi*elements[cRef].Value*cos(cJJPhase));  // Get the nonlinear inductance
            //// This formula used in Muller/Fourie paper - much better at about 0.99 Phi0. Find it on p.211 of Van Duzer and Turner, Superconductive
            ///  Devices and Circuits - it gives the total inductance LJt.
            if abs(elements[cRef].Current) < EPSILON then
              cJJInductance := PHI_0/(2*pi*elements[cRef].Value)
            else
            begin
              cIOverIC := elements[cRef].Current/elements[cRef].Value;
              if cIOverIC > (1-epsilon) then
                cIOverIC := (1-epsilon);
              if cIOverIC < (-1+epsilon) then
                cIOverIC := (-1+epsilon);
              cJJInductance := PHI_0/(2*pi*elements[cRef].Value)*arcsin(cIOverIC)/(cIOverIC);
            end;
            cAcc := cAcc + elements[cRef].Current*cJJInductance*cMult;  // Add the flux contribution (signed) to the accumulated cycle total
          end;
        end;
      end;
    end; // for cyclelist[cLoop]
    if verboseMode then
      EchoLn('Flux in cycle '+IntToStr(cLoop)+': '+FloatToStrF(cAcc/PHI_0, ffGeneral, 5, 5));
    cycleFlux[cLoop] := Round(cAcc/PHI_0);
  end; // for cycleList
end; // CalculateCycleFlux
{ --------------------------- CompareCycleFlux ------------------------------- }
function CompareCycleFlux(c1, c2 : cycleFluxArray) : Boolean;

var
  cc : Integer;
  cf : Boolean;

begin
  cf := True;
  if Length(c1) <> Length(c2) then   // Well, they won't match then, would they?
  begin
    CompareCycleFlux := False;
    exit;
  end;
  for cc := 0 to High(c1) do
    if c1[cc] <> c2[cc] then
      cf := False;
  CompareCycleFlux := cf;
end; // CompareCycleFlux
{ ------------------------------ FindAllStates ------------------------------- }
procedure FindAllStates;

var
  f1, f2, f3, fIn, fState : Integer;
  fTimeTotal, fTimeIn, fTimeOut, fTimeInFalse : Double;
  foundNewState, foundNewStateFlag : Boolean;
  fStr : string;

begin
  // Firstly, find base/zero state
  EchoLn('');
  EchoLn(ParamStr(1)+': Finding all states.');
  SetLength(inputTimes,Length(dutInput)); // array of zero length for each input.
  WriteSimDeck('simdeck.js', 2*timeFirstStable);
  ExecuteShellApp(engineName, simResultFilename+' simdeck.js');  // Run JoSIM/JSIM_n on nominal circuit with no inputs
  ReadCurrentValues('simout.'+simResultFileSuffix,TimeFirstStable);
  CalculateCycleFlux;
  SetLength(states,1); // Startup state
  states[0].time := TimeFirstStable;  // Time at which inputs to 0'th state
  SetLength(states[0].inputsToReach,Length(dutInput)); // Set length to number of inputs
  SetLength(states[0].inputResponse,Length(dutInput)); // Set length to number of inputs
  for fIn := 0 to High(dutInput) do
  begin
    SetLength(states[0].inputsToReach[fIn],1); // Only need one input to reach: 0
    states[0].inputsToReach[fIn,0] := -1; // Negative - no input
    SetLength(states[0].inputResponse[fIn].outTimes,Length(dutOutput)); // Each output needs to be in this array.
    for f1 := 0 to High(dutOutput) do
    begin
      SetLength(states[0].inputResponse[fIn].outTimes[f1],1);    
      states[0].inputResponse[fIn].outTimes[f1,0] := -1;  // Default no-output value.
      states[0].inputResponse[fIn].toState := -1; // Value of illegal state / undefined state (startup)
      states[0].inputResponse[fIn].isValid := True; // Assume all inputs are valid in this state
    end;
  end;
  SetLength(states[0].cycleFlux,Length(cycleList));
  for f1 := 0 to High(cycleList) do
    states[0].cycleFlux[f1] := cycleFlux[f1];
  fState := 0;

  foundNewState := True; // There is always a startup state...
  fTimeTotal := timeFirstStable+2*waitForStateChange;    // Set total simulation time default (as backup)
  while foundNewState do
  begin
    for fIn := 0 to High(dutInput) do
    begin
      for f1 := 0 to High(dutInput) do
      begin
        SetLength(inputTimes[f1],Length(states[fState].InputsToReach[f1])); // Copy the inputs required to get here into inputTimes
        for f2 := 0 to High(states[fState].InputsToReach[f1]) do
          InputTimes[f1,f2] := states[fState].InputsToReach[f1,f2];
        if f1 = fIn then
        begin
          SetLength(inputTimes[f1],Length(inputTimes[f1])+1); // Increase length
          inputTimes[f1,High(inputTimes[f1])] := states[fState].time; {fTime;} {TimeFirstStable;}
        end;
      end;
      for f1 := 0 to High(inputTimes) do
        if (inputTimes[f1,High(inputTimes[f1])] + 2*waitForStateChange) > fTimeTotal then  // largest time value at end of each inputTimes[input] array; sim time total should exceed by 2*waitForStateChange
          fTimeTotal := inputTimes[f1,High(inputTimes[f1])] + 2*waitForStateChange;
      WriteSimDeck('simdeck.js', fTimeTotal);
      ExecuteShellApp(engineName, simResultFilename+' simdeck.js');  // Run JoSIM/JSIM_n
      fTimeIn := FindFirstPulseTime('simout.'+simResultFileSuffix,states[fState].time,2+fIn);  // Index is 1+1+fIn (array_offset(0->1)+ time + fIn'th input)
      // Check for cells with no DMP (buffer junction) protection on inputs leading to storage loops. One clear alarm is a pulse appearing at another input
      for f1 := 0 to High(dutInput) do    // See if any outputs appear
        if f1 <> fIn then // Obviously there is a pulse at fIn...
        begin
          fTimeInFalse := FindFirstPulseTime('simout.'+simResultFileSuffix,states[fState].time,2+f1);  // Index is 1+1+f1 (array_offset(0->1)+ time + f1'th input)
          if (fTimeInFalse - fTimeIn) > 1e-20 then // Clearly, an output pulse at the f1'th input caused by the input at fIn. Not good.
          begin
            states[fState].inputResponse[fIn].isValid := False; // Shouldn't ever fire this input while in this state...
            EchoLn('State '+IntToStr(fState)+': Input "'+String(dutInput[fIn].Name)+'" disallowed; results in pulse at in "'+String(dutInput[f1].Name)+'".');
          end;
        end;
      if states[fState].inputResponse[fIn].isValid then
      for f1 := 0 to High(dutOutput) do    // See if any outputs appear
      begin
        WriteIntegrationTrace('simout.'+simResultFileSuffix,'trace_s'+IntToStr(fState)+'_i'+IntToStr(fIn)+'.txt',2+Length(dutInput)+f1);  // Index is 1+1+#inputs+f1 (array_offset(0->1)+time +#inputs + f1'th output)
        fTimeOut := FindFirstPulseTime('simout.'+simResultFileSuffix,states[fState].time,2+Length(dutInput)+f1);  // Index is 1+1+#inputs+f1 (array_offset(0->1)+time +#inputs + f1'th output)
        if (fTimeOut - fTimeIn) > 1e-20 then // Clearly, an output pulse caused by this input.
        begin
          states[fState].inputResponse[fIn].outTimes[f1,0] := (fTimeOut - fTimeIn);
          EchoLn('State '+IntToStr(fState)+': Input "'+String(dutInput[fIn].Name)+'" -> Output "'+String(dutOutput[f1].Name)+'" after '
                    +FloatToStrF(states[fState].inputResponse[fIn].outTimes[f1,0],ffGeneral,4,2)+' s.');
        end;
      end;
      ReadCurrentValues('simout.'+simResultFileSuffix,states[fState].time+WaitForStateChange);
      CalculateCycleFlux;
      if CompareCycleFlux(cycleFlux, states[fState].cycleFlux) then
      begin
        states[fState].inputResponse[fIn].toState := fState; // This input loops back to same state (or: leaves state unchanged)
      end
      else // Not this state. Is it new?
      begin
        foundNewStateFlag := True;  // Let's assume it is new.
        for f1 := 0 to High(states) do
          if CompareCycleFlux(cycleFlux, states[f1].cycleFlux) then   // So check cycle fluxes for all known states
          begin
            foundNewStateFlag := False;   // Nope, it exists already.
            states[fState].inputResponse[fIn].toState := f1;
          end;
        if foundNewStateFlag then
        begin
          SetLength(states,Length(states)+1); // Add a state
          states[High(states)].cycleFlux := cycleFlux; // Better save this now.
          states[fState].inputResponse[fIn].toState := High(states); // The input that we were evaulating precipitates the state that we just found...
          states[High(states)].time := states[fState].time + waitForStateChange;
          SetLength(states[High(states)].inputsToReach,Length(dutInput)); // Set length to number of inputs
          SetLength(states[High(states)].inputResponse,Length(dutInput)); // Set length to number of inputs
          for f2 := 0 to High(dutInput) do
          begin
//// HERE: Check all inputs needed to reach the state from which this one is found, and use those as base. Add correct input here at later time (stable)
            SetLength(states[High(states)].inputsToReach[f2],Length(states[fState].inputsToReach[f2]));
            for f3 := 0 to High(states[fState].inputsToReach[f2]) do
              states[High(states)].inputsToReach[f2,f3] := states[fState].inputsToReach[f2,f3]; // Copy inputs needed to reach state fState
            SetLength(states[High(states)].inputResponse[f2].outTimes,Length(dutOutput)); // Each output needs to be in this array.
            for f3 := 0 to High(dutOutput) do
            begin
              SetLength(states[High(states)].inputResponse[f2].outTimes[f3],1);
              states[High(states)].inputResponse[f2].outTimes[f3,0] := -1;  // Default no-output value.
              states[High(states)].inputResponse[f2].toState := -1; // Value of illegal state / undefined state (startup)
              states[High(states)].inputResponse[f2].isValid := True; // Assume all inputs are valid
            end;
          end;
          SetLength(states[High(states)].inputsToReach[fIn],Length(states[High(states)].inputsToReach[fIn])+1); // Increase the length of the input that sets this state.
          states[High(states)].inputsToReach[fIn, High(states[High(states)].inputsToReach[fIn])] := states[fState].time;
        end;
      end;  // if not CompareCycleFlux
    end;     // for fIn to High(dutInput)
    inc(fState); // Move on to explore next state
    if fState > High(states) then
      foundNewState := False
    else
      foundNewState := True;
  end;    //  while foundNewState
  EchoLn('States found: '+IntToStr(High(states)+1));
  if verboseMode then
  begin
    EchoLn('');
    EchoLn('Loop flux fingerprints.');
    for f1 := 0 to High(states) do
    begin
      fStr := 'State '+IntToStr(f1)+':';
      for f2 := 0 to High(states[f1].cycleFlux) do
      begin
        if states[f1].cycleFlux[f2] < 0 then
          fStr := fStr + ' ' + IntToStr(states[f1].cycleFlux[f2])
        else
          fStr := fStr + '  ' + IntToStr(states[f1].cycleFlux[f2])
      end;
      EchoLn(fStr);
    end;
  end;
end; // FindAllStates
{ ------------------------ CalculateCriticalTimings -------------------------- }
procedure CalculateCriticalTimings;
// This follows the first method in 'Muller LC and Fourie CJ, 2014, IEEE TAS (24) 1300110'
var
  cSweep, cSweepStep, cState, cIn, cOut, cIn2, cExpectedState, c1, c2, cCountIterations, cOutFailed, cNumSweepSteps : Integer;
  cTimeToIn2, cTimeToIn2LastWorking, cTimeToIn2LastFail, cTimeIn, cTimeIn2, cTimeOutFromIn: double;
  cTimeOutFromIn2, cSweepValue, cSweepStepValClosestToNom, cSweepNomVal : Double;
  foundCT, cUnaccountedOut, foundTBLimit, foundCircuitFail, functionalAtStep, ignorePulse : Boolean;
  cPulseRepulsionStr : string;

begin
  cTimeIn2 := 0;
  cSweepNomVal := 0;
  cSweepStepValClosestToNom := 0;
//  for cSweep := 0 to High(sweeps) do
  SetLength(sweepNominal,1);
  sweepNominal[0] := 1;
  for cSweep := 0 to 0 do // Currently, we limit the analysis to only one sweep (the first to be defined) due to the difficulty in creating parameters based on multiple parameters
  begin
    if Length(sweeps) > 0 then
    begin
      SetLength(sweepNominal,Length(sweeps));
      cNumSweepSteps := Trunc((sweeps[cSweep].Stop - sweeps[cSweep].Start) / (sweeps[cSweep].Inc *(1 - sqrt(EPSILON)))) + 1;
      sweepNominal[cSweep] := 1; // Assume at the start that the first step is the nominal value. We'll find the closest step later.
      SetLength(sweeps[cSweep].FunctionalAtStep,cNumSweepSteps+1); // For direct addressing, ignore the 0th element and set array one longer than number of sweep steps
      cSweepStepValClosestToNom := 1/EPSILON; // Start off big.
      cSweepNomVal := ReadSpiceVariableValue(String(sweeps[cSweep].SweepVar));
    end
    else
      cNumSweepSteps := 1; // No sweeps; only one step (nominal value)
    for cState := 0 to High(states) do
      for cIn := 0 to High(dutInput) do
      begin
        SetLength(states[cState].inputResponse[cIn].criticalInTimes, Length(dutInput)); // Make a critical timing variable (in dynamic array) for each input
        for c1 := 0 to High(dutInput) do
        begin
          SetLength(states[cState].inputResponse[cIn].criticalInTimes[c1], cNumSweepSteps);
          for c2 := 0 to (cNumSweepSteps-1) do
            states[cState].inputResponse[cIn].criticalInTimes[c1,c2] := -1;  // Set everything negative - indicates no relationship (default).
        end;
        for cOut := 0 to High(dutOutput) do
        begin
          SetLength(states[cState].inputResponse[cIn].outTimes[cOut],1+cNumSweepSteps); // [0] is nominal delay. Swept values from 1 -> Num
          for c2 := 1 to (cNumSweepSteps) do
          states[cState].inputResponse[cIn].outTimes[cOut,c2] := -1;
        end;
      end;

    for cSweepStep := 1 to cNumSweepSteps do
    begin
      functionalAtStep := true;
      if Length(sweeps) > 0 then
      begin
        cSweepValue := sweeps[cSweep].Start + (cSweepStep-1)*sweeps[cSweep].Inc;
        if cSweepStep = cNumSweepSteps then
          cSweepValue := sweeps[cSweep].Stop;
        // Record which sweep step has a value closest to the nominal value of the swept variable
        if abs(cSweepValue-cSweepNomVal) < cSweepStepValClosestToNom then
        begin
          cSweepStepValClosestToNom := abs(cSweepValue-cSweepNomVal);
          sweepNominal[cSweep] := cSweepStep;
        end;
        SetSpiceVariableValue(String(sweeps[cSweep].SweepVar),cSweepValue);
        EchoLn('');
        EchoLn(ParamStr(1)+': Sweep '+String(sweeps[cSweep].SweepVar)+' step '+IntToStr(cSweepStep)+'. Value = '+FloatToStrF(cSweepValue,ffGeneral,2,2));
        sweeps[cSweep].FunctionalAtStep[cSweepStep] := true; // Assume the circuit works at this step
      end;
      for cState := 0 to High(states) do     // for every state.
      begin
        for cIn := 0 to High(dutInput) do   // for every input
        begin
          if states[cState].inputResponse[cIn].isValid then
          begin
            for cIn2 := 0 to High(dutInput) do     // for every other input, find timing relationship to "input under test"
              if functionalAtStep and (states[states[cState].inputResponse[cIn].toState].inputResponse[cIn2].isValid) then
              begin
                // Instead of tracking state evolution, start with a blunt-force approach: is the end state correct?
                cExpectedState := states[states[cState].inputResponse[cIn].toState].inputResponse[cIn2].toState; // Assume everything OK if we end up in this state.
                cCountIterations := 0;
                cOutFailed := -1;
                for c1 := 0 to High(dutInput) do
                begin
                  SetLength(inputTimes[c1],Length(states[cState].InputsToReach[c1])); // Copy the inputs required to get here into inputTimes
                  for c2 := 0 to High(states[cState].InputsToReach[c1]) do
                    inputTimes[c1,c2] := states[cState].InputsToReach[c1,c2];
                end;
                SetLength(inputTimes[cIn],Length(inputTimes[cIn])+1); // Increase length
                inputTimes[cIn,High(inputTimes[cIn])] := states[cState].time; // Fire a pulse into input cIn.
                SetLength(inputTimes[cIn2],Length(inputTimes[cIn2])+1); // Increase length
                cTimeToIn2 := waitForStateChange;
                cTimeToIn2LastWorking := cTimeToIn2;
                cTimeToIn2LastFail := 0;
                cPulseRepulsionStr := '';
                foundTBLimit := false;
                foundCircuitFail := false;
                ignorePulse := false;
                repeat
                  foundCT := False; // Obviously we shouldn't have a critical timing dependency at 'waitForStateChange'. This is the input separation time that was used to find states in the first place...
                  inc(cCountIterations);
                  inputTimes[cIn2,High(inputTimes[cIn2])] := states[cState].time + cTimeToIn2; // Fire a pulse into input cIn2 at a variable time.
                  WriteSimDeck('simdeck.js', states[cState].time+2*waitForStateChange+cTimeToIn2);
                  ExecuteShellApp(engineName, simResultFilename+' simdeck.js');  // Run JSIM_n
                  ReadCurrentValues('simout.'+simResultFileSuffix,states[cState].time+cTimeToIn2+WaitForStateChange);
                  CalculateCycleFlux;
                  // NOTE: More than just checking the state - check output pulses (absent or shifted more than predefined percentage/time from nominal)
                  cTimeIn := FindFirstPulseTime('simout.'+simResultFileSuffix,states[cState].time,2+cIn);  // Index is 1+1+cIn (array_offset(0->1)+ time + cIn'th input)
                  if cTimeIn < EPSILON then
                  begin
                    if cIn <> cIn2 then
                    begin
                      EchoLn('Cannot find first input pulse on "'+UpperCase(String(dutInput[cIn].Name))+'". Could be: (a) Testbench failure, (b) too narrow a sliding integrator window,'
                            +' or a pulse on a PTL that is smaller than "PulseFluxonFraction".');
                      if (cState = states[cState].inputResponse[cIn].toState) and NoOutputs(cState,cIn,cSweepStep) then
                      begin
                        EchoLn('"'+UpperCase(String(dutInput[cIn].Name))+'" in state '+IntToStr(cState)+' does not alter state or cause outputs. Safely ignored.');
                        ignorePulse := true;
                      end
                      else
                        foundCircuitFail := true;
                    end
                    else
                    begin
                      EchoLn('Cannot find second input pulse on "'+UpperCase(String(dutInput[cIn].Name))+'". Could be: (a) Testbench failure, (b) too narrow a sliding integrator window,'
                            +' or a pulse on a PTL that is smaller than "PulseFluxonFraction". Ignoring pulse repulsion analysis.')  ;
                      ignorePulse := true;
                    end;
                  end;
                  if cIn2 <> cIn then
                    cTimeIn2 := FindFirstPulseTime('simout.'+simResultFileSuffix,states[cState].time,2+cIn2)  // Index is 1+1+cIn2 (array_offset(0->1)+ time + cIn2'th input)
                  else if not ignorePulse then
                  begin
                    if ioFullFluxon then
                      cTimeIn2 := FindSecondPulseTime('simout.'+simResultFileSuffix,states[cState].time,states[cState].time+1.8*waitForStateChange,2+cIn2)  // Index is 1+1+cIn2 (array_offset(0->1)+ time + cIn2'th input)
                    else
                      cTimeIn2 := FindFirstPulseTime('simout.'+simResultFileSuffix,states[cState].time{->}+minSameInputSeparation+(cTimeIn-states[cState].time){<-},2+cIn2);  // Index is 1+1+cIn2 (array_offset(0->1)+ time + cIn2'th input)
                    if (cTimeIn2 > EPSILON) and ((cTimeIn2 - cTimeIn) < (cTimeToIn2*0.75)) then
                    begin                  // There is a second input pulse - testbench works
                      EchoLn('WARNING: Input on '+UpperCase(String(dutInput[cIn].Name))+' where it was not fired: state '+IntToStr(cState)+' -> '+UpperCase(String(dutInput[cIn].Name))
                                                 +' -> state '+IntToStr(cExpectedState)+' -> '+UpperCase(String(dutInput[cIn2].Name))+', which indicates non-functional circuit.');
                      EchoLn('In1 at '+FloatToStrF(cTimeIn,ffGeneral,3,1)+', In2 at '+FloatToStrF(cTimeIn2,ffGeneral,3,1)+'.');
                      foundCircuitFail := True;
                    end;
                  end;
                  if not ignorePulse then
                  begin
                    cUnaccountedOut := False; // Assume that no output pulses appeared that were unaccounted for...
                    for c1 := 0 to High(dutOutput) do    // ...but now we must make sure: see if any outputs appear
                    begin
                      cTimeOutFromIn := FindFirstPulseTime('simout.'+simResultFileSuffix,states[cState].time,2+Length(dutInput)+c1);  // Index is 1+1+#inputs+c1 (array_offset(0->1)+time +#inputs + c1'th output)
                      if cIn2 <> CIn then
                        cTimeOutFromIn2 := FindFirstPulseTime('simout.'+simResultFileSuffix,states[cState].time,2+Length(dutInput)+c1)  // Index is 1+1+#inputs+c1 (array_offset(0->1)+time +#inputs + c1'th output)
                      else
                      begin
                        if ioFullFluxon then
                          cTimeOutFromIn2 := FindSecondPulseTime('simout.'+simResultFileSuffix,states[cState].time,states[cState].time+1.8*WaitForStateChange,2+Length(dutInput)+c1)  // Index is 1+1+#inputs+c1 (array_offset(0->1)+time +#inputs + c1'th output)
                        else
                          cTimeOutFromIn2 := FindFirstPulseTime('simout.'+simResultFileSuffix,states[cState].time{->}+minSameInputSeparation+(cTimeOutFromIn-states[cState].time){<-},2+Length(dutInput)+c1);  // Index is 1+1+#inputs+c1 (array_offset(0->1)+time +#inputs + c1'th output)
                        if FindNthPulseTime('simout.'+simResultFileSuffix,3,states[cState].time,states[cState].time+1.8*WaitForStateChange,2+Length(dutInput)+c1) > 0 then
                        begin
                          EchoLn('WARNING: Too many output pulses: '+UpperCase(String(dutInput[cIn].Name))+' -> state '+IntToStr(cState)+' -> '+UpperCase(String(dutInput[cIn2].Name))
                                   +', which indicates non-functional circuit.');
                          foundCircuitFail := True;
                        end;
                      end;
                      if (cTimeOutFromIn - states[cState].time) > 1e-20 then // There is an output pulse. Should it be there?
                      begin
                        cUnaccountedOut := True; // Remain true until we know this pulse is legal
                        if states[cState].inputResponse[cIn].outTimes[c1,0] > 0 then // Only check output as response to cIn if we expect an output
                        begin
                          if cTimeToIn2 > 0.99*waitForStateChange then   // First simulation - save this output time as the delay time for this sweep step if necessary
                            states[cState].inputResponse[cIn].outTimes[c1,cSweepStep] := (cTimeOutFromIn-cTimeIn);
                          cUnaccountedOut := False; // It is now accounted for
                          if abs(states[cState].inputResponse[cIn].outTimes[c1,cSweepStep]-(cTimeOutFromIn-cTimeIn)) > MaxDelayChange then // outside MaxDelayChange range.
                          begin
//                            cTimeFailed := states[cState].inputResponse[cIn].outTimes[c1,cSweepStep]-(cTimeOutFromIn-cTimeIn); // Value of time shift detected.
                            cOutFailed := c1;
                            foundCT := True; // We have just found a critical timing.
                          end;
                          if (cIn2 = cIn) and (states[cState].inputResponse[cIn].toState = cState) then // If this input results in same state AND output pulse
                          begin
                            if cTimeIn2 < EPSILON then
                            begin
                              cPulseRepulsionStr := '(testbench limit) ';
                              foundCT := True;
                            end
                            else
                              if abs(states[cState].inputResponse[cIn].outTimes[c1,cSweepStep]-(cTimeOutFromIn2-cTimeIn2)) > MaxSelfDelayChange then // outside MaxDelayChange range.
                              begin
//                                cTimeFailed := states[cState].inputResponse[cIn].outTimes[c1,cSweepStep]-(cTimeOutFromIn2-cTimeIn2); // Value of time shift detected.
                                cOutFailed := c1;
                                foundCT := True; // We have just found a critical timing from pulse repulsion.
                                cPulseRepulsionStr := '(pulse repulsion) ';
                              end;
                          end;
                        end;
                      end;
                      if ((cTimeOutFromIn2 - (states[cState].time + cTimeToIn2)) > 1e-20) and cUnaccountedOut then // There is an output pulse. Should it be there?
                      begin
                        if states[states[cState].inputResponse[cIn].toState].inputResponse[cIn2].outTimes[c1,cSweepStep] > 0 then // Only check output as response to cIn2 if we expect an output
                        begin
                          cUnaccountedOut := False; // It is now accounted for
                          if abs(states[states[cState].inputResponse[cIn].toState].inputResponse[cIn2].outTimes[c1,cSweepStep]-(cTimeOutFromIn2-cTimeIn2)) > MaxDelayChange then // outside MaxDelayChange range.
                          begin
//                            cTimeFailed := states[states[cState].inputResponse[cIn].toState].inputResponse[cIn2].outTimes[c1,cSweepStep]-(cTimeOutFromIn2-cTimeIn2); // Value of time shift detected.
                            cOutFailed := c1;
                            foundCT := True; // We have just found a critical timing.
                          end;
                        end;
                      end;
                    end;
                    if (not CompareCycleFlux(cycleFlux, states[cExpectedState].cycleFlux)) or (foundCT) then   // Expected state not reached
                    begin
                      if cTimeToIn2 > 0.99*waitForStateChange then   // Sanity check. If it does not work at waitForStateChange, then the state extraction part failed. Report!
                      begin
                        EchoLn('WARNING: Incorrect state or output at WaitForStateChange, which indicates non-functional circuit, or circuit that exceeds MaxSelfDelayChange.');
                        EchoLn('  Expected: State '+IntToStr(cState)+' -> '+UpperCase(String(dutInput[cIn].Name))+' -> '+ IntToStr(states[cState].inputResponse[cIn].toState)
                                 +' -> '+UpperCase(String(dutInput[cIn2].Name))+' -> '+IntToStr(cExpectedState)+'.');
                        if not CompareCycleFlux(cycleFlux, states[cExpectedState].cycleFlux) then
                          EchoLn('  End state different.');
                        foundCircuitFail := True;
                      end
                      else                                 // Binary search
                      begin
                        cTimeToIn2LastFail := cTimeToIn2;
                        cTimeToIn2 := (cTimeToIn2LastWorking+cTimeToIn2LastFail)/2;
                        EchoStr('x');
                      end;
                    end
                    else
                    begin
                      cTimeToIn2LastWorking := cTimeToIn2;
                      cTimeToIn2 := (cTimeToIn2LastWorking+cTimeToIn2LastFail)/2;
                      EchoStr('.');
                    end;
                    if cIn2 = cIn then
                      if cTimeToIn2 < ((sourceRiseTime+sourceFallTime)*1.01) then
                        foundTBLimit := true;
                  end;
                until ((cTimeToIn2LastWorking-cTimeToIn2LastFail) < ctDependencyThreshold) or foundTBLimit or foundCircuitFail or ignorePulse;
                if (cOutFailed > -1) and (not foundCircuitFail) then // Critical timing caused by excessive output pulse delay shift
                begin
                  EchoLn('State '+IntToStr(cState)+': Critical timing found '+cPulseRepulsionStr+String(dutInput[cIn].Name)+'->'+String(dutInput[cIn2].Name)+': '
                         +FloatToStrF(cTimeToIn2LastWorking,ffGeneral,4,2)+' s. (Pulse delay at '+String(dutOutput[cOutFailed].Name)+' exceeded MaxDelayChange.)');
                  states[cState].inputResponse[cIn].criticalInTimes[cIn2,cSweepStep-1] := cTimeToIn2LastWorking;
                end
                else
                begin
                  if (cTimeToIn2LastFail > 1e-20) or foundCT then  // Critical timing found
                  begin
                    EchoLn('State '+IntToStr(cState)+': Critical timing found '+cPulseRepulsionStr+String(dutInput[cIn].Name)
                            +'->'+String(dutInput[cIn2].Name)+': '+FloatToStrF(cTimeToIn2LastWorking,ffGeneral,4,2)+' s.' {('+IntToStr(cCountIterations)+' iterations.)'});
                    states[cState].inputResponse[cIn].criticalInTimes[cIn2,cSweepStep-1] := cTimeToIn2LastWorking;
                  end
                  else
                    EchoLn('State '+IntToStr(cState)+': No critical timing found '+String(dutInput[cIn].Name)
                           +'->'+String(dutInput[cIn2].Name)+'. ('+IntToStr(cCountIterations)+' iterations.)');
                  if foundCircuitFail then
                    begin
                      EchoLn('State '+IntToStr(cState)+': Circuit failure');
                      functionalAtStep := false;
                      if Length(sweeps) > 0 then
                        sweeps[cSweep].FunctionalAtStep[cSweepStep] := false;
                    end;
                end;
              end; // for cIn2
          end;
        end; // for cIn
      end; // for cState
    end; // for cSweepStep
  end; // for cSweep
end; // CalculateCriticalTimingsMethod1
{ --------------------------- RecalculateDelayTimes -------------------------- }
procedure RecalculateDelayTimes;
var
  r1, r2, r3, rIn, rState : Integer;
  rTimeTotal, rTimeIn, rTimeOut : Double;
  fStr : string;

begin
  if numSimsTol > 1 then
  begin
    if Length(sweeps) > 0 then
    begin
      EchoLn('');
      EchoLn('Sweeps override the calculation of tolerance-related delay times. No tolerance analysis done.');
    end
    else
    begin
      // Check every state
      EchoLn('');
      fStr := '';
      if noiseTemp > 0 then
        fStr := ' and noise at T='+FloatToStrF(noiseTemp,ffGeneral,3,1);
      EchoLn(ParamStr(1)+': Recalculating delay times for tolerance'+fStr+'.');
      rTimeTotal := timeFirstStable+2*waitForStateChange;    // Set total simulation time default (as backup)
      applyRandom := true;
      for rState := 0 to High(states) do
      begin
        for rIn := 0 to High(dutInput) do
        begin
          for r1 := 0 to High(dutOutput) do
          begin
            if states[rState].inputResponse[rIn].outTimes[r1,0] > 0 then
            begin
              for r2 := 0 to High(dutInput) do
              begin
                SetLength(inputTimes[r2],Length(states[rState].InputsToReach[r2])); // Copy the inputs required to get here into inputTimes
                for r3 := 0 to High(states[rState].InputsToReach[r2]) do
                  InputTimes[r2,r3] := states[rState].InputsToReach[r2,r3];
                if r2 = rIn then
                begin
                  SetLength(inputTimes[r2],Length(inputTimes[r2])+1); // Increase length
                  inputTimes[r2,High(inputTimes[r2])] := states[rState].time;
                end;
              end;
              for r2 := 0 to High(inputTimes) do
                if (inputTimes[r2,High(inputTimes[r2])] + 2*waitForStateChange) > rTimeTotal then  // largest time value at end of each inputTimes[input] array; sim time total should exceed by 2*waitForStateChange
                  rTimeTotal := inputTimes[r2,High(inputTimes[r2])] + 2*waitForStateChange;
              SetLength(states[rState].inputResponse[rIn].outTimes[r1],numSimsTol+1);
              for r2 := 1 to (numSimsTol) do
              begin
                ReadVariablesFromSpiceDeck(spiceDUTLines); // Rebuild parameters with random variations if applicable
                WriteSimDeck('simdeck.js', rTimeTotal);
                ExecuteShellApp(engineName, simResultFilename+' simdeck.js');  // Run JSIM_n
                rTimeIn := FindFirstPulseTime('simout.'+simResultFileSuffix,states[rState].time,2+rIn);  // Index is 1+1+rIn (array_offset(0->1)+ time + rIn'th input)
                rTimeOut := FindFirstPulseTime('simout.'+simResultFileSuffix,states[rState].time,2+Length(dutInput)+r1);  // Index is 1+1+#inputs+r1 (array_offset(0->1)+time +#inputs + r1'th output)
                if (rTimeOut - rTimeIn) > 1e-20 then // Clearly, an output pulse caused by this input.
                begin
                  states[rState].inputResponse[rIn].outTimes[r1,r2] := (rTimeOut - rTimeIn);
                  Write(' '+FloatToStrF(states[rState].inputResponse[rIn].outTimes[r1,r2],ffGeneral,4,2));
                end
                else
                begin
                  states[rState].inputResponse[rIn].outTimes[r1,r2] := states[rState].inputResponse[rIn].outTimes[r1,0]; // Nominal value
                  Write(' x');
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end; // RecalculateDelayTimes
{ ----------------------------- RunTBSimulations ----------------------------- }
procedure RunTBSimulations(tbsName : String);

begin
  EchoLn('');
  EchoLn('Executing testbench simulations.');
  if useJSIM then
    ExecuteShellApp('jsim_n', '-m tb_'+tbsName+'.dat tb_'+tbsName+'.js')  // Run JSIM_n
  else
    ExecuteShellApp('josim', '-o tb_'+tbsName+'.csv tb_'+tbsName+'.js');  // Run JSIM_n
  ExecuteShellApp('iverilog', '-gspecify -s tb_'+tbsName+' -o tb_'+tbsName+' '+tbsName+'.v tb_'+tbsName+'.v');  // Run iverilog
  ExecuteShellApp('vvp', 'tb_'+tbsName);  // Run VVP
  ExecuteShellApp('dot', '-Tpdf '+tbsName+'.gv -o '+tbsName+'.pdf'); // Run Dot to create a state diagram (Mealy FSM)
end; // RunTBSimulations

{ ================================== MAIN ==================================== }
begin
  try // General exception handler .
    Initiate;
    FormatDecks;
    EchoLn('');
    EchoLn('Finding all cycles.');
    Cycles;
    ReadElementValues;
    FindAllStates;
    // Now we have all the states and all input/output combinations
    WriteDotFile(cellNameStr);
    // WriteDotFile creates a Mealy state diagram for interpretation with GraphViz. If GraphViz is installed, the diagram should be generated already.
    // The next step is open for alteration: How to find the timing parameters. These methods are incomplete (not exhaustive yet), and can be altered.
    // We add some methods here as in IARPA-BAA-16-03 deliverable, but as understanding of timing parameters expands, these can (and should!) be updated.
    // The first method
    CalculateCriticalTimings;
    // CalculateCriticalTimings is the core of the application. It is robust for all cells connected directly with superconducting inductors.
    // However, pulses on Passive Transmission Lines are not full fluxons, and are not always easy to identify with a generic algorithm.
    // Several adjustable variables were introduced to allow designers to tweak the algorithm, with for instance IOFullFluxon and PulseFluxonFraction,
    // but extensive use on cells with PTL interconnects is bound to expose cases where pulses are misidentified.
    // One solution could be to identify the closest junction to every output and verify phase transition to mark existance of I/O pulses.
    // This could also be done at the driver/receiver junctions in the load cells, which is more reliable, but will require the algorithms to
    // account for possible PTL delay when JJ phase switching is matched with possible I/O pulses. This has not been implemented here yet.
    RecalculateDelayTimes;
    // RecalculateDelayTimes only acts if there are no sweeps, and "NumberSimsTolerance" or "NumberSimsNoise" > 1.
    // Here, only the delay times are calculated as element values are varied to simulate process tolerances, or due to noise.
    if containedVerilog then
      WriteContainedVerilogModule(cellNameStr)
    else
      WriteVerilogModule(cellNameStr);
    // What can be added with minimal effort:
    //   1. Load-dependent timing parameters. If the input and output loads (individual to each input/output!) are swopped with all other cells in a library,
    //      then load-dependent timing parameters can be calculated. How this would be propagated to large-scale Verilog simulations is not yet clear.
    //      Currently, this should be done by the user to generate multiple Verilog models for a DUT - one for each OUTPUT load of interest.
    //      Note that swopping out input loads is not as straightforward, because it is not trivial to automatically manipulate arbitrary cells
    //      to provide multiple inputs when required.
    if runTB then RunTBSimulations(cellNameStr);
    if stateMapFileParam > 0 then WriteStateMapFile(stateMapFileName);
    CloseFile(OutFile);
  except  // Some exception landed us here. See the error message.
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
