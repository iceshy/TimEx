unit TX_Globals;

{*******************************************************************************
*    Unit TX_Globals (for use with TimEx)                                      *
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
{$IFDEF Unix}
{$mode objfpc}{$H+}
{$ENDIF Unix}

interface

type
  {enumerated types, alphabetically}
  SourceTypeEnumerated = (Current,Voltage);
const
  VersionNumber = '2.05';
  CopyRightNotice = 'Copyright 2016-2020 Coenrad Fourie, Stellenbosch University.';
  BuildDate = '15 May 2020';
  SpiceDeckLineLengthMax = 255;  // Maximum allowable characters in JSIM deck file lines. (Delphi dynamic arrays are prone to crashing if unlimited strings are used.)
  PHI_0 = 2.067833758e-15;
  EPSILON = 1e-20; // Arbitrary small number to test divide-by-zero occurrence

type
  Str1 = string[1]; // for layer filmtype characters
  Str40 = String[40];
  Str50 = String[50];
  Str88 = String[88];
  Str255 = String[255];
  StrSpiceLineMax = String[SpiceDeckLineLengthMax];
  {record types}

  DUTPortsRecord = record
    Name : Str40;
    Node : Str40;
    Number : Integer;
  end;
  ElementRecord = record
    Name : Str40;
    Value, Current : Double;
  end;
  TSpiceDeckLine = array of StrSpiceLineMax;
  DUTPortsArray = array of DUTPortsRecord;
  CycleListArray = array of array of Str40;
  ElementArray = array of ElementRecord;
  CycleFluxArray = array of Integer;
  InputTimesArray = array of array of Double;
  TInputResponseRecord = record
    toState : Integer;
    isValid : Boolean;
    outTimes : array of array of Double;  // Time to pulse at each output. Make time negative for no output
    criticalInTimes : array of array of Double; // Critical Timing value to every input pulse. Make negative for no critical relationship.
  end;
  TInputResponseArray = array of TInputResponseRecord;
  TStatesRecord = record
    time : Double;
    inputsToReach : InputTimesArray;
    cycleFlux : CycleFluxArray;
    inputResponse : TInputResponseArray;
  end;
  TStatesRecordArray = array of TStatesRecord;
  TLinesArray = array of Str255;
  TSweepRecord = record
    SweepVar : Str40;
    Start, Inc, Stop, Nominal : double;
    FunctionalAtStep : array of boolean;
  end;
  TSweep = array of TSweepRecord;
  TSpiceVariableRecord = record
    Name : str40;
    Value : double;
  end;
  TSpiceVariable = array of TSpiceVariableRecord;

var
  defFileParam, loadInFileParam, loadOutFileParam, sinkFileParam, sourceFileParam, stateMapFileParam : Integer;
  outFile, spiceFile : TextFile;
  executeFile, engineName, dutCellName, cellNameStr, stateMapFileName, simResultFileName, simResultFileSuffix : String;
  spiceDUTLines, spiceLoadInLines, spiceLoadOutLines, spiceSinkLines, spiceSourceLines : TSpiceDeckLine;
  dutInput, dutOutput : DUTPortsArray;
  cycleList : cycleListArray;
  elements, jjModels : ElementArray;
  sourceType : SourceTypeEnumerated;
  sourceAmplitude, sourceRiseTime, sourceFallTime, timeFirstStable, waitForStateChange, slidingIntegratorLength, pulseDetectThreshold : Double;
  ctDependencyThreshold, maxDelayChange, maxSelfDelayChange, verilogStableTime, verilogWaitTime, inputChainDelay, pulseFluxonFraction : Double;
  minSameInputSeparation, noiseTemp, simTimeStep : double;
  numSimsTol : integer;
  ioFullFluxon : boolean;
  cycleFlux : CycleFluxArray;
  inputTimes : InputTimesArray;
  states : TStatesRecordArray;
  lines : tLinesArray;
  runTB : boolean;       // If True, runs the testbench simulations
  verboseMode : boolean;
  sweeps : TSweep;
  spiceVariables : TSpiceVariable;
  sweepNominal : array of integer;
  applyRandom : boolean; // If false, gauss(mean, stddev) evaluates to (mean) - used for nominal analysis
  useJSIM : boolean;
  containedVerilog : boolean;

implementation

end.

