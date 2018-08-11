unit TX_FileOut;

{*******************************************************************************
*    Unit TX_FileOut (for use with TimEx)                                       *
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
  SysUtils, Math, TX_Globals, TX_Math, TX_Strings;
  
procedure EchoLn(EText : string); // writes text to both the screen and file SolFile
procedure EchoStr(EText : string);
procedure CleanMemory;
procedure ExitWithHaltCode(EText : string; HCode : integer);
procedure WriteSimDeck(deckName : String; stopTime : Double);
procedure WriteDotFile(dfName : String);
procedure WriteVerilogModule(vmName : String);
procedure WriteContainedVerilogModule(vmName : String);
procedure WriteStateMapFile(smName : String);

implementation

{ --------------------------------- EchoLn ----------------------------------- }
procedure EchoLn(EText : string);
// writes text to both the screen and an output file
begin
  WriteLn(EText);
  WriteLn(OutFile,EText);
end; // EchoLn
{ -------------------------------- EchoStr ----------------------------------- }
procedure EchoStr(EText : string);
// writes text to both the screen and an output file (no CR/LF)
begin
  Write(EText);
  Write(OutFile,EText);
end; // EchoStr
{ ------------------------------ CleanMemory --------------------------------- }
procedure CleanMemory;
// Deallocate dynamic arrays and close files
begin
  states := nil;
  sweeps := nil;
end;
{ ---------------------------- ExitWithHaltCode ------------------------------ }
procedure ExitWithHaltCode(EText : string; HCode : integer);
// Writes text to both the screen and an output file, then closes file and halts
begin
  EchoLn('('+IntToStr(HCode)+') '+EText);
  CloseFile(OutFile);
  CleanMemory;
  Halt(HCode);
end; // ExitWithHaltCode
{ ------------------------------ WriteSimDeck -------------------------------- }
procedure WriteSimDeck(deckName : String; stopTime : Double);
// Writes a JSIM deck for simulation.
var
  sd1, sdNode, sdNodePos, sdNodeNeg, sdTime : Integer;
  deckFile : TextFile;
  sdStr : String;

begin
  AssignFile(deckFile, deckName);
  {$I-}
  Rewrite(deckFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file ''simdeck.js''', 3);
  WriteLn(deckFile,'* JSIM deck file generated with TimEx');
  WriteLn(deckFile,'* === DEVICE-UNDER-TEST ===');
  for sd1 := 0 to High(spiceDUTLines) do
//    WriteLn(deckFile,SynthesizeSpiceCard(spiceDUTLines[sd1]));
    SynthesizeSpiceCardNoise(string(spiceDUTLines[sd1]),deckFile);
  WriteLn(deckFile,'* === SOURCE DEFINITION ===');
  for sd1 := 0 to High(spiceSourceLines) do
    WriteLn(deckFile,spiceSourceLines[sd1]);
  WriteLn(deckFile,'* === INPUT LOAD DEFINITION ===');
  for sd1 := 0 to High(spiceLoadInLines) do
    WriteLn(deckFile,spiceLoadInLines[sd1]);
  WriteLn(deckFile,'* === OUTPUT LOAD DEFINITION ===');
  for sd1 := 0 to High(spiceLoadOutLines) do
    WriteLn(deckFile,spiceLoadOutLines[sd1]);
  WriteLn(deckFile,'* === SINK DEFINITION ===');
  for sd1 := 0 to High(spiceSinkLines) do
    WriteLn(deckFile,spiceSinkLines[sd1]);
  WriteLn(deckFile,'* ===== MAIN =====');
  sdNode := 1;  // First node;
  if sourceType = Current then sdStr := 'I';
  if sourceType = Voltage then sdStr := 'V';
  for sd1 := 0 to High(dutInput) do
  begin
    sdNodePos := sdNode;   sdNodeNeg := 0;
    if sourceType = Current then
      IntSwop(sdNodePos, sdNodeNeg);
    Write(deckFile,sdStr+'_'+string(dutInput[sd1].Name)+' '+IntToStr(sdNodePos)+' '+IntToStr(sdNodeNeg)+' pwl(0 0 5p 0');
    if Length(inputTimes[sd1]) > 0 then
      for sdTime := 0 to High(inputTimes[sd1]) do
        if inputTimes[sd1,sdTime] > 5e-12 then
          Write(deckFile,' '+FloatToStrF(inputTimes[sd1,sdTime],ffGeneral,4,2)+' 0 '
              +FloatToStrF(inputTimes[sd1,sdTime]+sourceRiseTime,ffGeneral,4,2)+' '+FloatToStrF(sourceAmplitude,ffGeneral,4,2)+' '
              +FloatToStrF(inputTimes[sd1,sdTime]+sourceRiseTime+sourceFallTime,ffGeneral,4,2)+' 0');
    WriteLn(deckFile,')');
    inc(sdNode);
    WriteLn(deckFile,'XSOURCEIN'+String(dutInput[sd1].Name)+' SOURCECELL '+string(IntToStr(sdNode-1))+' '+IntToStr(sdNode));
    WriteLn(deckFile,'XLOADIN'+String(dutInput[sd1].Name)+' LOADINCELL '+IntToStr(sdNode)+' '+IntToStr(sdNode+1));
    inc(sdNode);
    dutInput[sd1].Number := sdNode;  // This is the node number at this input to the DUT.
    inc(sdNode);
  end;
  for sd1 := 0 to High(dutOutput) do
  begin
    WriteLn(deckFile,'XLOADOUT'+String(dutOutput[sd1].Name)+' LOADOUTCELL '+IntToStr(sdNode)+' '+IntToStr(sdNode+1));
    dutOutput[sd1].Number := sdNode;  // This is the node number at this output from the DUT.
    inc(sdNode);
    WriteLn(deckFile,'XSINKOUT'+String(dutOutput[sd1].Name)+' SINKCELL '+IntToStr(sdNode));
    inc(sdNode);
  end;
  sdStr := 'XDUT'+' '+dutCellName;
  for sd1 := 0 to High(dutInput) do
    sdStr := sdStr + ' ' + IntToStr(dutInput[sd1].Number);
  for sd1 := 0 to High(dutOutput) do
    sdStr := sdStr + ' ' + IntToStr(dutOutput[sd1].Number);
  WriteLn(deckFile,sdStr);
  WriteLn(deckFile,'.tran '+FloatToStrF(simTimeStep,ffGeneral,5,2)+' '+FloatToStrF(stopTime,ffGeneral,5,2)+' 0 '
           +FloatToStrF(simTimeStep,ffGeneral,5,2)); // Transient analysis setup
  for sd1 := 0 to High(dutInput) do                                            // Print all I/O nodevoltages for pulse detection
    WriteLn(deckFile,'.PRINT NODEV '+IntToStr(dutInput[sd1].Number)+' 0');
  for sd1 := 0 to High(dutOutput) do
    WriteLn(deckFile,'.PRINT NODEV '+IntToStr(dutOutput[sd1].Number)+' 0');
  for sd1 := 0 to High(elements) do
    WriteLn(deckFile,'.PRINT DEVI XDUT_'+UpperCase(String(elements[sd1].Name)));
//  for sd1 := 0 to High(elements) do
//    if elements[sd1].Name[1] = 'b' then
//      WriteLn(deckFile,'.PRINT PHASE XDUT_'+UpperCase(elements[sd1].Name));
  WriteLn(deckFile,'.end');
  CloseFile(deckFile);
end; // WriteSimDeck
{ ------------------------------ WriteDotFile -------------------------------- }
procedure WriteDotFile(dfName : String);

var
  df1, df2, dfOut : Integer;
  dfStr : String;
  dfFile : TextFile;

begin
  AssignFile(dfFile,dfName+'.gv');
  {$I-}
  Rewrite(dfFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file '''+dfName+'.gv''.', 3);
  WriteLn(dfFile,'digraph '+dfName+' {');
  WriteLn(dfFile,'  node [shape = circle];');
  for df1 := 0 to High(states) do
  begin
    for df2 := 0 to High(states[df1].inputResponse) do
    begin
      dfStr := '';
      if states[df1].inputResponse[df2].isValid then
      begin
        for dfOut := 0 to High(states[df1].inputResponse[df2].outTimes) do
          if states[df1].inputResponse[df2].outTimes[dfOut,0] > 0 then
            dfStr := dfStr+'\n'+UpperCase(String(dutOutput[dfOut].Name));         // Write output names in UPPERCASE below input name if pulses generated
        if dfStr <> '' then  // Well then, we had outputs...
          WriteLn(dfFile,'  State'+IntToStr(df1)+' -> State'+IntToStr(states[df1].inputResponse[df2].toState)
                          +' [label="'+String(dutInput[df2].Name)+dfStr+'",arrowhead=normalnonedot];')
        else
          WriteLn(dfFile,'  State'+IntToStr(df1)+' -> State'+IntToStr(states[df1].inputResponse[df2].toState)
                          +' [label="'+String(dutInput[df2].Name)+'"];');
      end
      else      // error state
        WriteLn(dfFile,'  State'+IntToStr(df1)+' -> error [label="'+String(dutInput[df2].Name)+'"];');
    end;
    WriteLn(dfFile,'  State'+IntToStr(df1)+' [label="'+IntToStr(df1)+'"];');
  end;
  WriteLn(dfFile,'}');
  CloseFile(dfFile)
end; // WriteDotFile
{ --------------------------- WriteVerilogModule ----------------------------- }
procedure WriteVerilogModule(vmName : String);
// New implementation (v2.02) to support vcd_assert
type
  TestSetRecord = record
                    stateTested : Boolean;
                    inputsFired : array of Boolean;
                  end;
  TestSetType = array of TestSetRecord;
var
  vm1, vmState, vmIn, vmIn2, vmOut, vmStateNow, vmWait, vmTotalTime, vmFirstTime : Integer;
  vmMaxDelay : double;
  vmBool : Boolean;
  vmStr : String;
  vmFile : TextFile;
  testSet : TestSetType;

begin
  EchoLn('');
  EchoLn('Writing Verilog and testbench files.');
  vmTotalTime := Round(verilogStableTime/1e-12);
  vmWait := Round(verilogWaitTime/1e-12);
  for vm1 := 0 to High(dutInput) do
    SetLength(inputTimes[vm1],0);
  SetLength(testSet,Length(states));
  for vmState := 0 to High(states) do
  begin
    testSet[vmState].stateTested := False;
    SetLength(testSet[vmState].inputsFired,Length(dutInput));
    for vmIn := 0 to High(dutInput) do
      testSet[vmState].inputsFired[vmIn] := False;
  end;
  // Firstly, write the cell module
  AssignFile(vmFile,vmName+'.v');
  {$I-}
  Rewrite(vmFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file '''+vmName+'.v''.', 3);
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'// Automatically extracted verilog file, created with TimEx v'+versionNumber);
  WriteLn(vmFile,'// Timing description and structural design for IARPA-BAA-14-03 via');
  WriteLn(vmFile,'// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and');
  WriteLn(vmFile,'// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.');
  WriteLn(vmFile,'// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za');
  WriteLn(vmFile,'// (c) 2016-2018 Stellenbosch University');
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'`ifndef begin_time');
  WriteLn(vmFile,'`define begin_time 8');
  WriteLn(vmFile,'`endif');
  WriteLn(vmFile,'`timescale 1ps/100fs');
  WriteLn(vmFile);
  WriteLn(vmFile,'`celldefine');
  vmStr := '';
  for vm1 := 0 to High(dutInput) do
    vmStr := vmStr+String(dutInput[vm1].Name)+', ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+');';
  WriteLn(vmFile,'module '+vmName+' #(parameter begin_time = `begin_time) ('+vmStr);   WriteLn(vmFile);
  WriteLn(vmFile,'// Define inputs');
  WriteLn(vmFile,'input');
  vmStr := '  ';
  for vm1 := 0 to High(dutInput) do
    if vm1 < High(dutInput) then
      vmStr := vmStr+String(dutInput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutInput[vm1].Name)+';';
  WriteLn(vmFile,vmStr);    WriteLn(vmFile);
  WriteLn(vmFile,'// Define outputs');
  WriteLn(vmFile,'output');
  vmStr := '  ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+';';
  WriteLn(vmFile,vmStr);   WriteLn(vmFile);
  WriteLn(vmFile,'// Define internal output variables');
  WriteLn(vmFile,'reg');
  vmStr := '  ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+'internal_'+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+'internal_'+String(dutOutput[vm1].Name)+';';
  WriteLn(vmFile,vmStr);
  for vm1 := 0 to High(dutOutput) do
    WriteLn(vmFile,'assign '+String(dutOutput[vm1].Name)+' = internal_'+String(dutOutput[vm1].Name)+';');
  WriteLn(vmFile);

  if High(states) = 0 then
    WriteLn(vmFile,'// Single state')
  else
  begin
    WriteLn(vmFile,'// Define state');
    WriteLn(vmFile,'integer state;');
    WriteLn(vmFile);
    WriteLn(vmFile,'wire');
    vmStr := '  ';
    for vmState := 0 to High(states) do
      if vmState < High(states) then
        vmStr := vmStr+'internal_state_'+IntToStr(vmState)+', '
    else
      vmStr := vmStr+'internal_state_'+IntToStr(vmState)+';';
    WriteLn(vmFile,vmStr);
    WriteLn(vmFile);
    for vmState := 0 to High(states) do
      WriteLn(vmFile,'assign internal_state_'+IntToStr(vmState)+' = state === '+IntToStr(vmState)+';');
  end;

  WriteLn(vmFile);
  WriteLn(vmFile,'specify');
  // Write in->out delay values
  SetLength(lines,0);
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmOut := 0 to High(dutOutput) do
      begin
        if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          vmMaxDelay := states[vmState].inputResponse[vmIn].outTimes[vmOut,0];
          if applyRandom then
          begin
            lines[High(lines)] := ANSIString('  specparam delay_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'
             +String(dutOutput[vmOut].Name)+' = ('+FloatToStrF(MinValue(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,1)
             +':'+FloatToStrF(Mean(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,1)
             +':'+FloatToStrF(MaxValue(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,1)+');'
             +'  // Mean = '+FloatToStrF(Mean(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,3)
             +'  StdDev = '+FloatToStrF(StdDev(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,3));
          end
          else
            lines[High(lines)] := ANSIString('  specparam delay_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'
             +String(dutOutput[vmOut].Name)+' = '+FloatToStrF(vmMaxDelay/1e-12,ffFixed,5,1)+';');
        end;
      end;
  SetLength(lines,Length(lines)+1);
  // Write in1->in2 critical timing parameters
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmIn2 := 0 to High(dutInput) do
      begin
        if states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          lines[High(lines)] := ANSIString('  specparam ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'+String(dutInput[vmIn2].Name)+' = '
            +FloatToStrF(states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1]/1e-12,ffFixed,5,1)+';');
        end;
      end;
  SetLength(lines,Length(lines)+1);
  // Define delays
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmOut := 0 to High(dutOutput) do
      begin
        if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          lines[High(lines)] := ANSIString('  if (internal_state_'+IntToStr(vmState)+') ('+String(dutInput[vmIn].Name)+' => '
             +String(dutOutput[vmOut].Name)+') = delay_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'
             +String(dutOutput[vmOut].Name)+';');
        end;
      end;
  SetLength(lines,Length(lines)+1);
  // Define critical timings assertions
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmIn2 := 0 to High(dutInput) do
      begin
        if states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          lines[High(lines)] := ANSIString('  $hold( posedge '+String(dutInput[vmIn].Name)+' &&& internal_state_'
            +IntToStr(vmState)+', '+String(dutInput[vmIn2].Name)+', ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)
            +'_'+String(dutInput[vmIn2].Name)+');');
          SetLength(lines,Length(lines)+1);
          lines[High(lines)] := ANSIString('  $hold( negedge '+String(dutInput[vmIn].Name)+' &&& internal_state_'
            +IntToStr(vmState)+', '+String(dutInput[vmIn2].Name)+', ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)
            +'_'+String(dutInput[vmIn2].Name)+');');
        end;
      end;

  for vm1 := 0 to (High(lines)-1) do
    WriteLn(vmFile,lines[vm1]);
  if Length(lines) > 0 then
    WriteLn(vmFile,String(lines[High(lines)]));
  WriteLn(vmFile,'endspecify');
  WriteLn(vmFile);

  if High(states) > 0 then
    WriteLn(vmFile,'// Set initial state');
  WriteLn(vmFile,'initial begin');
  if High(states) > 0 then
    WriteLn(vmFile,'   state = 1''bX;');
  for vmOut := 0 to High(dutOutput) do
    WriteLn(vmFile,'   internal_'+dutOutput[vmOut].Name+' = 0; // All outputs start at 0');    
  if High(states) > 0 then
    WriteLn(vmFile,'   #begin_time state = 0;');
  WriteLn(vmFile,'   end');  WriteLn(vmFile);

  // Now for every input
  for vmIn := 0 to High(dutInput) do
  begin
    WriteLn(vmFile,'always @(posedge '+String(dutInput[vmIn].Name)+' or negedge '+String(dutInput[vmIn].Name)+')');
    WriteLn(vmFile,'case (state)');
    for vmState := 0 to High(states) do
    begin
      WriteLn(vmFile,'   '+IntToStr(vmState)+': begin');
      if states[vmState].inputResponse[vmIn].isValid then
      begin
        for vmOut := 0 to High(dutOutput) do
          if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
            WriteLn(vmFile,'      internal_'+String(dutOutput[vmOut].Name)+' = !internal_'+String(dutOutput[vmOut].Name)+';');
        if states[vmState].inputResponse[vmIn].toState <> vmState then
          WriteLn(vmFile,'      state = '+IntToStr(states[vmState].inputResponse[vmIn].toState)+';');
      end
      else
      begin
        WriteLn(vmFile,'      // Input leads to invalid state;');
        WriteLn(vmFile,'      state = 1''bX;');        
        for vmOut := 0 to High(dutOutput) do
          WriteLn(vmFile,'      internal_'+dutOutput[vmOut].Name+' = 1''bX;');
      end;
      WriteLn(vmFile,'   end');
    end;
    WriteLn(vmFile,'endcase');
  end;
  WriteLn(vmFile);
  WriteLn(vmFile,'endmodule');
  WriteLn(vmFile,'`endcelldefine');
  CloseFile(vmFile);

  // Secondly, write a testbench
  AssignFile(vmFile,'tb_'+vmName+'.v');
  {$I-}
  Rewrite(vmFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file ''tb_'+vmName+'.v''.', 3);
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'// Verilog testbench file, created with TimEx v'+versionNumber);
  WriteLn(vmFile,'// Timing description and structural design for IARPA-BAA-14-03 via');
  WriteLn(vmFile,'// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and');
  WriteLn(vmFile,'// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.');
  WriteLn(vmFile,'// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za');
  WriteLn(vmFile,'// (c) 2016-2018 Stellenbosch University');
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'`timescale 1ps/100fs');
  WriteLn(vmFile,'module tb_'+vmName+';');
  for vmIn := 0 to High(dutInput) do
    WriteLn(vmFile,'   reg '+String(dutInput[vmIn].Name)+' = 0;');
  if Length(sweeps) > 0 then
  begin
    SetLength(lines,0);
    WriteLn(vmFile,'parameter');
    // Write externally controlled parameter if sweep exists
    vmStr := '  ';
    for vm1 := 0 to {High(sweeps)} 0 do
    begin
      SetLength(lines,Length(lines)+1);
      lines[High(lines)] := ANSIString(vmStr+String(sweeps[vm1].SweepVar)+' = '+FloatToStrF(sweeps[vm1].Nominal,ffFixed,5,1));
    end;
    for vm1 := 0 to (High(lines)-1) do
      WriteLn(vmFile,lines[vm1]+',');
    WriteLn(vmFile,lines[High(lines)]+';');    WriteLn(vmFile);
  end;

  WriteLn(vmFile,'   initial');
  WriteLn(vmFile,'      begin');
  WriteLn(vmFile,'         $dumpfile("tb_'+vmName+'.vcd");');
  WriteLn(vmFile,'         $dumpvars;');

  // Test all states
  // Startup state
  vmStateNow := 0;
  vmFirstTime := vmTotalTime;
  repeat
    WriteLn(vmFile,'         // Now in state '+IntToStr(vmStateNow));
    testSet[vmStateNow].stateTested := True;
    vmIn := 0;
    vmBool := False;
    repeat
      if testSet[vmStateNow].inputsFired[vmIn] then
        inc(vmIn)
      else
        vmBool := True;
    until (vmIn > High(dutInput)) or vmBool;
    if vmBool then  // We're done of vmBool is False (exhausted the input possibilities)
      if states[vmStateNow].inputResponse[vmIn].isValid then
      begin
         WriteLn(vmFile,'         #'+IntToStr(vmWait+vmFirstTime)+' '+String(dutInput[vmIn].Name)+' = !'+String(dutInput[vmIn].Name)+';');
         vmFirstTime := 0;
         testSet[vmStateNow].inputsFired[vmIn] := True;
         vmStateNow := states[vmStateNow].inputResponse[vmIn].toState;
         vmTotalTime := vmTotalTime + vmWait;
         SetLength(inputTimes[vmIn], Length(inputTimes[vmIn])+1);
         inputTimes[vmIn,High(inputTimes[vmIn])] := vmTotalTime*1e-12 - inputChainDelay;
      end
      else
      begin
        testSet[vmStateNow].inputsFired[vmIn] := True; // We didn't really fire it, but cross it off the list - it is illegal and will send the FSM straight into the error state
        WriteLn(vmFile,'         // Input "'+dutInput[vmIn].Name+'" leads to error state; not fired.');
      end;
  until (not vmBool);
  WriteLn(vmFile,'      end');  WriteLn(vmFile);
  WriteLn(vmFile,'   initial');
  WriteLn(vmFile,'      begin');
  vmStr := '\t\ttime';
  for vmIn := 0 to High(dutInput) do
    vmStr := vmStr+',\t'+String(dutInput[vmIn].Name);
  for vmOut := 0 to High(dutOutput) do
    vmStr := vmStr+',\t'+String(dutOutput[vmOut].Name);
  WriteLn(vmFile,'         $display("'+vmStr+'");');

  vmStr := '"%d';
  for vmIn := 0 to High(dutInput) do
    vmStr := vmStr+',\t%b';
  for vmOut := 0 to High(dutOutput) do
    vmStr := vmStr+',\t%b';
  vmStr := vmStr+'",$time';
  for vmIn := 0 to High(dutInput) do
    vmStr := vmStr+','+String(dutInput[vmIn].Name);
  for vmOut := 0 to High(dutOutput) do
    vmStr := vmStr+','+String(dutOutput[vmOut].Name);
  WriteLn(vmFile,'         $monitor('+vmStr+');');
  WriteLn(vmFile,'      end'); WriteLn(vmFile);
  vmStr := '';
  for vm1 := 0 to High(dutInput) do
    vmStr := vmStr+String(dutInput[vm1].Name)+', ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+');';
  if length(sweeps) > 0 then
    WriteLn(vmFile,'   '+vmName+' #('+String(sweeps[0].SweepVar)+') DUT ('+vmStr)
  else
    WriteLn(vmFile,'   '+vmName+' DUT ('+vmStr);
  WriteLn(vmFile);
  WriteLn(vmFile,'   initial');
  WriteLn(vmFile,'      #'+IntToStr(vmTotalTime+vmWait)+' $finish;');
  WriteLn(vmFile,'endmodule');
  CloseFile(vmFile);
  // Now, for good measure, build a JSIM file to match the Verilog testbench (although with a static offset from input source through load cell...
  WriteSimDeck('tb_'+vmName+'.js', (vmTotalTime+vmWait)*1e-12);

  // Lastlyt, write the SDF file
  AssignFile(vmFile,vmName+'.sdf');
  {$I-}
  Rewrite(vmFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file '''+vmName+'.sdf''.', 3);
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'// Standard Delay Format file, (IEEE Std 1497-2001) created with');
  WriteLn(vmFile,'// TimEx v'+versionNumber);
  WriteLn(vmFile,'// Timing description and structural design for IARPA-BAA-14-03 via');
  WriteLn(vmFile,'// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and');
  WriteLn(vmFile,'// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.');
  WriteLn(vmFile,'// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za');
  WriteLn(vmFile,'// (c) 2016-2018 Stellenbosch University');
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'(DELAYFILE');
  WriteLn(vmFile,'    (SDFVERSION "4.0")');
  WriteLn(vmFile,'    (DESIGN "tb_'+vmName+'")');
  WriteLn(vmFile,'    (DATE "'+DateTimeToStr(Now)+'")');
  WriteLn(vmFile,'    (VENDOR "ColdFlux")');
  WriteLn(vmFile,'    (PROGRAM "TimEx")');
  WriteLn(vmFile,'    (VERSION "'+versionNumber+'")');
  WriteLn(vmFile,'    (DIVIDER .)');
  WriteLn(vmFile,'    (PROCESS "typical")         // For documentation purposes only.');
  WriteLn(vmFile,'    (TEMPERATURE 4:1:5)');
  WriteLn(vmFile,'    (TIMESCALE 100fs)');
  WriteLn(vmFile,'    (CELL');
  WriteLn(vmFile,'        (CELLTYPE "'+vmName+'")');
  WriteLn(vmFile,'        (INSTANCE *)');
  WriteLn(vmFile,'        (DELAY');
  WriteLn(vmFile,'            (ABSOLUTE');
  WriteLn(vmFile,'                /*Conditional delays not supported by iverilog */');
  // Define delays
  for vmState := 0 to High(states) do
  begin
    SetLength(lines,0);
    for vmIn := 0 to High(dutInput) do
      for vmOut := 0 to High(dutOutput) do
      begin
        if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          lines[High(lines)] := ANSIString('                    (IOPATH '+String(dutInput[vmIn].Name)+' '
             +String(dutOutput[vmOut].Name)+' ('
             +IntToStr(Round(MinValue(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-13))
             +':'+IntToStr(Round(Mean(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-13))
             +':'+IntToStr(Round(MaxValue(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-13))+'))');
        end;
      end;
    if Length(lines) > 0 then
    begin
      WriteLn(vmFile,'                (COND internal_state_'+IntToStr(vmState));
      for vm1 := 0 to High(lines) do
        WriteLn(vmFile,lines[vm1]);
      WriteLn(vmFile,'                )');
    end;
  end;
  WriteLn(vmFile,'            )');
  WriteLn(vmFile,'        )');
  WriteLn(vmFile,'        /* iVerilog does not support built-in timing checks (yet) */ ');
  WriteLn(vmFile,'        (TIMINGCHECK');
  // Define critical timings assertions
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmIn2 := 0 to High(dutInput) do
      begin
        if states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1] > 0 then
        begin
          vmStr := '            (HOLD '+String(dutInput[vmIn2].Name)+' (COND internal_state_'+IntToStr(vmState)+' (';
          WriteLn(vmFile,vmStr+'posedge '+String(dutInput[vmIn].Name)+')) ('
                   +IntToStr(Round(states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1]/1e-13))+'))');
          WriteLn(vmFile,vmStr+'negedge '+String(dutInput[vmIn].Name)+')) ('
                  +IntToStr(Round(states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1]/1e-13))+'))');
        end;
      end;
  WriteLn(vmFile,'        )');
  WriteLn(vmFile,'    )');
  WriteLn(vmFile,')');
  CloseFile(vmFile);


end; // WriteVerilogModule
{ ----------------------- WriteContainedVerilogModule ------------------------ }
procedure WriteContainedVerilogModule(vmName : String);
// This was the first type supported (fully self-contained timing verification)
type
  TestSetRecord = record
                    stateTested : Boolean;
                    inputsFired : array of Boolean;
                  end;
  TestSetType = array of TestSetRecord;
var
  vm1, vmState, vmIn, vmIn2, vmOut, vmStateNow, vmWait, vmTotalTime, vmFirstTime : Integer;
  vmNumSweepSteps, vmSweepStep : integer;
  vmSweepValue, vmSweepValueNext, vmMaxDelay : double;
  vmBool : Boolean;
  vmStr, vmCompareCharLow, vmCompareCharHigh : String;
  vmFile : TextFile;
  testSet : TestSetType;

begin
  EchoLn('');
  EchoLn('Writing Verilog and testbench files.');
  vmTotalTime := Round(verilogStableTime/1e-12);
  vmWait := Round(verilogWaitTime/1e-12);
  for vm1 := 0 to High(dutInput) do
    SetLength(inputTimes[vm1],0);
  SetLength(testSet,Length(states));
  for vmState := 0 to High(states) do
  begin
    testSet[vmState].stateTested := False;
    SetLength(testSet[vmState].inputsFired,Length(dutInput));
    for vmIn := 0 to High(dutInput) do
      testSet[vmState].inputsFired[vmIn] := False;
  end;
  // Firstly, write the cell module
  AssignFile(vmFile,vmName+'.v');
  {$I-}
  Rewrite(vmFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file '''+vmName+'.v''.', 3);
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'// Automatically extracted verilog file, created with TimEx v'+versionNumber);
  WriteLn(vmFile,'// Timing description and structural design for IARPA-BAA-14-03 via');
  WriteLn(vmFile,'// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and');
  WriteLn(vmFile,'// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.');
  WriteLn(vmFile,'// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za');
  WriteLn(vmFile,'// (c) 2016-2018 Stellenbosch University');
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'`timescale 1ps/100fs');
  vmStr := '';
  for vm1 := 0 to High(dutInput) do
    vmStr := vmStr+String(dutInput[vm1].Name)+', ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+');';
  WriteLn(vmFile,'module '+vmName+' ('+vmStr);   WriteLn(vmFile);
  WriteLn(vmFile,'input');
  vmStr := '  ';
  for vm1 := 0 to High(dutInput) do
    if vm1 < High(dutInput) then
      vmStr := vmStr+String(dutInput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutInput[vm1].Name)+';';
  WriteLn(vmFile,vmStr);    WriteLn(vmFile);
  WriteLn(vmFile,'output');
  vmStr := '  ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+';';
  WriteLn(vmFile,vmStr);   WriteLn(vmFile);
  WriteLn(vmFile,'reg');
  vmStr := '  ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+';';
  WriteLn(vmFile,vmStr);     WriteLn(vmFile);

  if Length(sweeps) > 0 then
  begin
    SetLength(lines,0);
    WriteLn(vmFile,'parameter');
    // Write externally controlled parameter if sweep exists
    vmStr := '  ';
    for vm1 := 0 to High(sweeps) do
    begin
      SetLength(lines,Length(lines)+1);
      lines[High(lines)] := ANSIString(vmStr)+sweeps[vm1].SweepVar+' = '+ANSIString(FloatToStrF(sweeps[vm1].Nominal,ffFixed,5,1));
    end;
    for vm1 := 0 to (High(lines)-1) do
      WriteLn(vmFile,lines[vm1]+',');
    WriteLn(vmFile,lines[High(lines)]+';');    WriteLn(vmFile);
  end;

  WriteLn(vmFile,'real');
  // Write in->out delay values
  SetLength(lines,0);
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmOut := 0 to High(dutOutput) do
      begin
        if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          vmMaxDelay := states[vmState].inputResponse[vmIn].outTimes[vmOut,0];
          if applyRandom then
          begin
            for vm1 := 1 to High(states[vmState].inputResponse[vmIn].outTimes[vmOut]) do
              if states[vmState].inputResponse[vmIn].outTimes[vmOut,vm1] > vmMaxDelay then
                vmMaxDelay := states[vmState].inputResponse[vmIn].outTimes[vmOut,vm1];
          end;
          lines[High(lines)] := ANSIString('  delay_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'
             +String(dutOutput[vmOut].Name)+' = '+FloatToStrF(vmMaxDelay/1e-12,ffFixed,5,1)+',');
          if applyRandom then
            lines[High(lines)] := lines[High(lines)] + ANSIString(
             '  // Mean = '+FloatToStrF(Mean(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,3)
             +'  StdDev = '+FloatToStrF(StdDev(states[vmState].inputResponse[vmIn].outTimes[vmOut])/1e-12,ffFixed,5,3));
        end;
      end;
  // Write in1->in2 critical timing parameters
  for vmState := 0 to High(states) do
    for vmIn := 0 to High(dutInput) do
      for vmIn2 := 0 to High(dutInput) do
      begin
        if states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1] > 0 then
        begin
          SetLength(lines,Length(lines)+1);
          lines[High(lines)] := ANSIString('  ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'+String(dutInput[vmIn2].Name)+' = '
            +FloatToStrF(states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1]/1e-12,ffFixed,5,1)+',');
        end;
      end;
  for vm1 := 0 to (High(lines)-1) do
    WriteLn(vmFile,lines[vm1]);
  if Length(lines) > 0 then
    WriteLn(vmFile,StringReplace(String(lines[High(lines)]),',',';',[rfReplaceAll]));
  WriteLn(vmFile);

  WriteLn(vmFile,'reg');
  // Make an error signal for each input
  for vmIn := 0 to (High(dutInput)-1) do
    WriteLn(vmFile,'   errorsignal_'+dutInput[vmIn].Name+',');
  WriteLn(vmFile,'   errorsignal_'+dutInput[High(dutInput)].Name+';');    WriteLn(vmFile);

  WriteLn(vmFile,'integer');
  WriteLn(vmFile,'   outfile,');
  // State variable
  WriteLn(vmFile,'   cell_state; // internal state of the cell');     WriteLn(vmFile);

  WriteLn(vmFile,'initial');
  WriteLn(vmFile,'   begin');
  for vmIn := 0 to High(dutInput) do
    WriteLn(vmFile,'      errorsignal_'+dutInput[vmIn].Name+' = 0;');
  WriteLn(vmFile,'      cell_state = 0; // Startup state');
  for vmOut := 0 to High(dutOutput) do
    WriteLn(vmFile,'      '+dutOutput[vmOut].Name+' = 0; // All outputs start at 0');
  if Length(sweeps) > 0 then
  begin
    
    vmNumSweepSteps := Trunc((sweeps[0].Stop - sweeps[0].Start) / (sweeps[0].Inc *(1 - sqrt(EPSILON)))) + 1;
    if sweeps[0].Start < sweeps[0].Stop then
    begin
      vmCompareCharLow := '>';
      vmCompareCharHigh := '<';
    end
    else
    begin
      vmCompareCharLow := '<';
      vmCompareCharHigh := '>';
    end;
    WriteLn(vmFile,'    if ('+String(sweeps[0].SweepVar)+' '+vmCompareCharHigh + ' '+FloatToStrF(sweeps[0].Start,ffGeneral,5,1)+')');
    WriteLn(vmFile,'      begin');
    for vmOut := 0 to High(dutOutput) do
      WriteLn(vmFile,'        '+String(dutOutput[vmOut].Name)+' <= 1''bX;');
    WriteLn(vmFile,'      end');
    for vmSweepStep := 1 to (vmNumSweepSteps-1) do
    begin
      vmSweepValue := sweeps[0].Start + (vmSweepStep-1)*sweeps[0].Inc;
      vmSweepValueNext := sweeps[0].Start + (vmSweepStep)*sweeps[0].Inc;
      if vmSweepStep = (vmNumSweepSteps-1) then
        vmSweepValueNext := sweeps[0].Stop;
      if vmSweepStep < (vmNumSweepSteps-1) then
        WriteLn(vmFile,'    if (('+String(sweeps[0].SweepVar)+' '+vmCompareCharLow + '= '+FloatToStrF(vmSweepValue,ffGeneral,5,1)+') && ('
                          +String(sweeps[0].SweepVar)+' '+vmCompareCharHigh+' '+FloatToStrF(vmSweepValueNext,ffGeneral,5,1)+'))')
      else
        WriteLn(vmFile,'    if (('+String(sweeps[0].SweepVar)+' '+vmCompareCharLow + '= '+FloatToStrF(vmSweepValue,ffGeneral,5,1)+') && ('
                          +String(sweeps[0].SweepVar)+' '+vmCompareCharHigh+'= '+FloatToStrF(vmSweepValueNext,ffGeneral,5,1)+'))');
      WriteLn(vmFile,'      begin');

      if sweeps[0].FunctionalAtStep[vmSweepStep] and sweeps[0].FunctionalAtStep[vmSweepStep+1] then
      begin
        // Now define each characteristic time.
        // Write in->out delay values
        SetLength(lines,0);
        for vmState := 0 to High(states) do
          for vmIn := 0 to High(dutInput) do
            for vmOut := 0 to High(dutOutput) do
            begin
              if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
                WriteLn(vmFile,'        delay_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'+String(dutOutput[vmOut].Name)+' = '
                  +FloatToStrF(states[vmState].inputResponse[vmIn].outTimes[vmOut,vmSweepStep]/1e-12,ffFixed,5,1)+' + ('
                  +FloatToStrF((states[vmState].inputResponse[vmIn].outTimes[vmOut,vmSweepStep+1]-states[vmState].inputResponse[vmIn].outTimes[vmOut,vmSweepStep])/1e-12,ffFixed,5,1)+'/'
                  +FloatToStrF((vmSweepValueNext-vmSweepValue),ffFixed,5,1)+')*('+String(sweeps[0].SweepVar)+'-'
                  +FloatToStrF(vmSweepValue,ffFixed,5,1)+');');
            end;
        // Write in1->in2 critical timing parameters
        for vmState := 0 to High(states) do
          for vmIn := 0 to High(dutInput) do
            for vmIn2 := 0 to High(dutInput) do
              if states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1] > 0 then
              begin
                if (states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1] > 0) and
                   (states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep] > 0) then
                  WriteLn(vmFile,'        ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'+String(dutInput[vmIn2].Name)+' = '
                    +FloatToStrF(states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1]/1e-12,ffFixed,5,1)+' + ('
                    +FloatToStrF((states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep]-states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1])/1e-12,ffFixed,5,1)+'/'
                    +FloatToStrF((vmSweepValueNext-vmSweepValue),ffFixed,5,1)+')*('+String(sweeps[0].SweepVar)+'-'
                    +FloatToStrF(vmSweepValue,ffFixed,5,1)+');')
                else if (states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1] > 0) and
                        (states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep] < 0) then
                  WriteLn(vmFile,'        ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'+String(dutInput[vmIn2].Name)+' = '
                    +FloatToStrF(states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1]/1e-12,ffFixed,5,1)+' + ('
                    +FloatToStrF((-states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1])/1e-12,ffFixed,5,1)+'/'
                    +FloatToStrF((vmSweepValueNext-vmSweepValue),ffFixed,5,1)+')*('+String(sweeps[0].SweepVar)+'-'
                    +FloatToStrF(vmSweepValue,ffFixed,5,1)+');')
                else if (states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep-1] < 0) and
                        (states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep] > 0) then
                  WriteLn(vmFile,'        ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'+String(dutInput[vmIn2].Name)+' = ('
                    +FloatToStrF((states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,vmSweepStep])/1e-12,ffFixed,5,1)+'/'
                    +FloatToStrF((vmSweepValueNext-vmSweepValue),ffFixed,5,1)+')*('+String(sweeps[0].SweepVar)+'-'
                    +FloatToStrF(vmSweepValue,ffFixed,5,1)+');');
              end;
      end
      else
      begin
        for vmOut := 0 to High(dutOutput) do
          WriteLn(vmFile,'        '+String(dutOutput[vmOut].Name)+' <= 1''bX;');
      end;
      WriteLn(vmFile,'      end');
    end;
    WriteLn(vmFile,'    if ('+String(sweeps[0].SweepVar)+' '+vmCompareCharLow+' '+FloatToStrF(sweeps[0].Stop,ffGeneral,5,1)+')');
    WriteLn(vmFile,'      begin');
    for vmOut := 0 to High(dutOutput) do
      WriteLn(vmFile,'        '+String(dutOutput[vmOut].Name)+' <= 1''bX;');
    WriteLn(vmFile,'      end');


  end;
  WriteLn(vmFile,'   end');  WriteLn(vmFile);

  // Now for every input
  for vmIn := 0 to High(dutInput) do
  begin
    WriteLn(vmFile,'always @(posedge '+String(dutInput[vmIn].Name)+' or negedge '+String(dutInput[vmIn].Name)+') // execute at positive and negative edges of input');
    WriteLn(vmFile,'   begin');
    WriteLn(vmFile,'      if ($time>4) // arbitrary steady-state time)');
    WriteLn(vmFile,'         begin');
    WriteLn(vmFile,'            if (errorsignal_'+String(dutInput[vmIn].Name)+' == 1''b1)  // A critical timing is active for this input');
    WriteLn(vmFile,'               begin');
    WriteLn(vmFile,'                  outfile = $fopen("errors.txt", "a");');
    WriteLn(vmFile,'                  $fdisplay(outfile, "Violation of critical timing in module %m; %0d ps.\n", $stime);');
    WriteLn(vmFile,'                  $fclose(outfile);');
    for vmOut := 0 to High(dutOutput) do
      WriteLn(vmFile,'                  '+String(dutOutput[vmOut].Name)+' <= 1''bX;  // Set all outputs to unknown');
    WriteLn(vmFile,'               end');
    WriteLn(vmFile,'            if (errorsignal_'+String(dutInput[vmIn].Name)+' == 0)');
    WriteLn(vmFile,'               begin');
    WriteLn(vmFile,'                  case (cell_state)');
    for vmState := 0 to High(states) do
    begin
//      WriteLn(vmFile,'                  if (cell_state == '+IntToStr(vmState)+')');
      WriteLn(vmFile,'                     '+IntToStr(vmState)+': begin');
      if states[vmState].inputResponse[vmIn].isValid then
      begin
        for vmOut := 0 to High(dutOutput) do
          if states[vmState].inputResponse[vmIn].outTimes[vmOut,0] > 0 then
            WriteLn(vmFile,'                           '+String(dutOutput[vmOut].Name)+' <= #(delay_state'+IntToStr(vmState)+'_'
                            +String(dutInput[vmIn].Name)+'_'+String(dutOutput[vmOut].Name)+') !'
                            +String(dutOutput[vmOut].Name)+';');
        if states[vmState].inputResponse[vmIn].toState <> vmState then
          WriteLn(vmFile,'                           cell_state = '+IntToStr(states[vmState].inputResponse[vmIn].toState)+';  // Blocking statement -- immediately');
        for vmIn2 := 0 to High(dutInput) do
          if states[vmState].inputResponse[vmIn].criticalInTimes[vmIn2,sweepNominal[0]-1] > 0 then
          begin
            WriteLn(vmFile,'                           errorsignal_'+String(dutInput[vmIn2].Name)+' = 1;  // Critical timing on this input; assign immediately');
            WriteLn(vmFile,'                           errorsignal_'+String(dutInput[vmIn2].Name)+' <= #(ct_state'+IntToStr(vmState)+'_'+String(dutInput[vmIn].Name)+'_'
                            +String(dutInput[vmIn2].Name)+') 0;  // Clear error signal after critical timing expires');
          end;
      end
      else
      begin
        WriteLn(vmFile,'                           outfile = $fopen("errors.txt", "a");');
        WriteLn(vmFile,'                           $fdisplay(outfile, "Illegal '+dutInput[vmIn].Name+' input in state %0d of module %m; %0d ps.\n", cell_state, $stime);');
        WriteLn(vmFile,'                           $fclose(outfile);');
        for vmOut := 0 to High(dutOutput) do
          WriteLn(vmFile,'                           '+dutOutput[vmOut].Name+' <= 1''bX;  // Set all outputs to unknown');
      end;
      WriteLn(vmFile,'                        end');
    end;
    WriteLn(vmFile,'                  endcase');
    WriteLn(vmFile,'               end');
    WriteLn(vmFile,'         end');
    WriteLn(vmFile,'   end');
    WriteLn(vmFile);
  end;
  WriteLn(vmFile,'endmodule');
  CloseFile(vmFile);

  // Secondly, write a testbench
  AssignFile(vmFile,'tb_'+vmName+'.v');
  {$I-}
  Rewrite(vmFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file ''tb_'+vmName+'.v''.', 3);
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'// Verilog testbench file, created with TimEx v'+versionNumber);
  WriteLn(vmFile,'// Timing description and structural design for IARPA-BAA-14-03 via');
  WriteLn(vmFile,'// U.S. Air Force Research Laboratory contract FA8750-15-C-0203 and');
  WriteLn(vmFile,'// IARPA-BAA-16-03 via U.S. Army Research Office grant W911NF-17-1-0120.');
  WriteLn(vmFile,'// For questions about TimEx, contact CJ Fourie, coenrad@sun.ac.za');
  WriteLn(vmFile,'// (c) 2016-2018 Stellenbosch University');
  WriteLn(vmFile,'// ---------------------------------------------------------------------------');
  WriteLn(vmFile,'`timescale 1ps/100fs');
  WriteLn(vmFile,'module tb_'+vmName+';');
  for vmIn := 0 to High(dutInput) do
    WriteLn(vmFile,'   reg '+String(dutInput[vmIn].Name)+' = 0;');
  if Length(sweeps) > 0 then
  begin
    SetLength(lines,0);
    WriteLn(vmFile,'parameter');
    // Write externally controlled parameter if sweep exists
    vmStr := '  ';
    for vm1 := 0 to {High(sweeps)} 0 do
    begin
      SetLength(lines,Length(lines)+1);
      lines[High(lines)] := ANSIString(vmStr+String(sweeps[vm1].SweepVar)+' = '+FloatToStrF(sweeps[vm1].Nominal,ffFixed,5,1));
    end;
    for vm1 := 0 to (High(lines)-1) do
      WriteLn(vmFile,lines[vm1]+',');
    WriteLn(vmFile,lines[High(lines)]+';');    WriteLn(vmFile);
  end;

  WriteLn(vmFile,'   initial');
  WriteLn(vmFile,'      begin');
  WriteLn(vmFile,'         $dumpfile("tb_'+vmName+'.vcd");');
  WriteLn(vmFile,'         $dumpvars;');

  // Test all states
  // Startup state
  vmStateNow := 0;
  vmFirstTime := vmTotalTime;
  repeat
    WriteLn(vmFile,'         // Now in state '+IntToStr(vmStateNow));
    testSet[vmStateNow].stateTested := True;
    vmIn := 0;
    vmBool := False;
    repeat
      if testSet[vmStateNow].inputsFired[vmIn] then
        inc(vmIn)
      else
        vmBool := True;
    until (vmIn > High(dutInput)) or vmBool;
    if vmBool then  // We're done of vmBool is False (exhausted the input possibilities)
      if states[vmStateNow].inputResponse[vmIn].isValid then
      begin
         WriteLn(vmFile,'         #'+IntToStr(vmWait+vmFirstTime)+' '+String(dutInput[vmIn].Name)+' = !'+String(dutInput[vmIn].Name)+';');
         vmFirstTime := 0;
         testSet[vmStateNow].inputsFired[vmIn] := True;
         vmStateNow := states[vmStateNow].inputResponse[vmIn].toState;
         vmTotalTime := vmTotalTime + vmWait;
         SetLength(inputTimes[vmIn], Length(inputTimes[vmIn])+1);
         inputTimes[vmIn,High(inputTimes[vmIn])] := vmTotalTime*1e-12 - inputChainDelay;
      end
      else
      begin
        testSet[vmStateNow].inputsFired[vmIn] := True; // We didn't really fire it, but cross it off the list - it is illegal and will send the FSM straight into the error state
        WriteLn(vmFile,'         // Input "'+dutInput[vmIn].Name+'" leads to error state; not fired.');
      end;
  until (not vmBool);
  WriteLn(vmFile,'      end');  WriteLn(vmFile);
  WriteLn(vmFile,'   initial');
  WriteLn(vmFile,'      begin');
  vmStr := '\t\ttime';
  for vmIn := 0 to High(dutInput) do
    vmStr := vmStr+',\t'+String(dutInput[vmIn].Name);
  for vmOut := 0 to High(dutOutput) do
    vmStr := vmStr+',\t'+String(dutOutput[vmOut].Name);
  WriteLn(vmFile,'         $display("'+vmStr+'");');

  vmStr := '"%d';
  for vmIn := 0 to High(dutInput) do
    vmStr := vmStr+',\t%b';
  for vmOut := 0 to High(dutOutput) do
    vmStr := vmStr+',\t%b';
  vmStr := vmStr+'",$time';
  for vmIn := 0 to High(dutInput) do
    vmStr := vmStr+','+String(dutInput[vmIn].Name);
  for vmOut := 0 to High(dutOutput) do
    vmStr := vmStr+','+String(dutOutput[vmOut].Name);
  WriteLn(vmFile,'         $monitor('+vmStr+');');
  WriteLn(vmFile,'      end'); WriteLn(vmFile);
  vmStr := '';
  for vm1 := 0 to High(dutInput) do
    vmStr := vmStr+String(dutInput[vm1].Name)+', ';
  for vm1 := 0 to High(dutOutput) do
    if vm1 < High(dutOutput) then
      vmStr := vmStr+String(dutOutput[vm1].Name)+', '
    else
      vmStr := vmStr+String(dutOutput[vm1].Name)+');';
  if length(sweeps) > 0 then
    WriteLn(vmFile,'   '+vmName+' #('+String(sweeps[0].SweepVar)+') DUT ('+vmStr)
  else
    WriteLn(vmFile,'   '+vmName+' DUT ('+vmStr);
  WriteLn(vmFile);
  WriteLn(vmFile,'   initial');
  WriteLn(vmFile,'      #'+IntToStr(vmTotalTime+vmWait)+' $finish;');
  WriteLn(vmFile,'endmodule');
  CloseFile(vmFile);
  // Now, for good measure, build a JSIM file to match the Verilog testbench (although with a static offset from input source through load cell...
  WriteSimDeck('tb_'+vmName+'.js', (vmTotalTime+vmWait)*1e-12);
end; // WriteContainedVerilogModule
{ ---------------------------- WriteStateMapFile ----------------------------- }
procedure WriteStateMapFile(smName : String);

var
  smState, smInput, smOut, smCT : integer;
  smFile : TextFile;
  smStr : string;

begin
  EchoLn('');
  EchoLn('Writing state map file.');
  AssignFile(smFile,smName);
  {$I-}
  Rewrite(smFile);
  {$I+}
  if ioResult <> 0 then
    ExitWithHaltCode('Error writing file '''+smName+'''.', 4);
  WriteLn(smFile,'* State map for '+cellNameStr+', created with TimEx v'+versionNumber);
  WriteLn(smFile,'* State Input NewState [Array of delays to all outputs] [Array of critical timings for all inputs]');
  smStr := '* State Input NewState [';
  for smOut := 0 to High(dutOutput) do
  begin
    smStr := smStr + String(dutOutput[smOut].Name);
    if smOut < High(dutOutput) then
      smStr := smStr + ' '
    else
      smStr := smStr + '] ['
  end;
  for smInput := 0 to High(dutInput) do
  begin
    smStr := smStr + String(dutInput[smInput].Name);
    if smInput < High(dutInput) then
      smStr := smStr + ' '
    else
      smStr := smStr + ']'
  end;
  WriteLn(smFile,smStr);
  for smState := 0 to High(states) do
  begin
    for smInput := 0 to High(states[smState].inputResponse) do
    begin
      smStr := IntToStr(smState)+' '+IntToStr(smInput)+' '+IntToStr(states[smState].inputResponse[smInput].toState)+' [';
      for smOut := 0 to High(states[smState].inputResponse[smInput].outTimes) do
      begin
        smStr := smStr + FloatToStrF(states[smState].inputResponse[smInput].outTimes[smOut,0],ffGeneral,5,3);
        if smOut < High(states[smState].inputResponse[smInput].outTimes) then
          smStr := smStr + ' '
        else
          smStr := smStr + '] [';
      end;
      for smCT := 0 to High(states[smState].inputResponse[smInput].criticalInTimes) do
      begin
        smStr := smStr + FloatToStrF(states[smState].inputResponse[smInput].criticalInTimes[smCT,0],ffGeneral,5,3);
        if smCT < High(states[smState].inputResponse[smInput].criticalInTimes) then
          smStr := smStr + ' '
        else
          smStr := smStr + ']';
      end;
      WriteLn(smFile,smStr);
    end;
  end;
  CloseFile(smFile);
end; // WriteStateMapFile

end.
