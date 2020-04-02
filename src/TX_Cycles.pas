unit TX_Cycles;

{*******************************************************************************
*                                                                              *
* Author    :  Coenrad Fourie                                                  *
* Version   :  2.04                                                            *
* Copyright (c) 2016-2020 Coenrad Fourie                                       *
*                                                                              *
* Developed by Stellenbosch University under IARPA-BAA-16-03 (v2.0)            *
*                                                                              *
* Last modification: 1 April 2020                                              *
*      JoSIM support improved                                                  *
*                                                                              *
* This work was supported by the Office of the Director of National            *
* Intelligence (ODNI), Intelligence Advanced Research Projects Activity        *
* (IARPA), via the U.S. Army Research Office grant W911NF-17-1-0120.           *
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
  SysUtils, TX_FileIn, TX_FileOut, TX_Strings, TX_Globals;

function GetCycleCount : integer;
procedure CycleStoreFile;
procedure Cycles;

implementation

const
  MAX_NAME_LENGTH = 20;
  HRN : integer = 10000;

type
  Str50 = String[50];
  IntArrayType = array of integer;
  StrName = string[MAX_NAME_LENGTH];
  NameListType = array of StrName;
  DoubleIntArrayType = array of array of integer;
  StrArrayType = array of Str50;
  DoubleStrArrayType = array of array of Str50;

var
  ck, componentTotal, portTotal, maxI, maxJ : integer;
  portList : StrArrayType;
  nameList : nameListType;
  lookup_ports, adj, cOut : DoubleIntArrayType;
  origi_ports : DoubleStrArrayType;

{ -------------------------------- Str50Swop --------------------------------- }
procedure Str50Swop(var str1, str2 : Str50);

var
  ss1 : Str50;

begin
  ss1 := str1;
  str1 := str2;
  str2 := ss1;
end; // Str50Swop
{ ------------------------------ GetCycleCount ------------------------------- }
function GetCycleCount : integer;

var
  cCount, ci : integer;
  cText : string;

begin
  cCount := 0;
  for ci := 0 to High(spiceDUTLines) do
  begin
    cText := LowerCase(String(spiceDUTLines[ci]));
    if (ANSIChar(cText[1]) in ['l','b']) then
      inc(cCount);
  end;
  GetCycleCount := cCount;
end; // GetCycleCount
{ ---------------------------- CycleStoreFile -------------------------------- }
procedure CycleStoreFile;

var
  sfj, sfc, sfComp_nr, sfm, sfn,  sf1, sf2 : integer;
  sfText : String;

begin
  sfj := 0; sfc := 0;
  sfComp_nr := 0;
  for sf1 := 0 to High(spiceDUTLines) do
  begin
    sfText := String(spiceDUTLines[sf1]);
    LnTABReplace(sfText);
    if (ANSIChar(sfText[1]) in ['l','b']) then
    begin
      sfText := StringReplace(sfText,#9,' ',[rfReplaceAll]);
      nameList[sfc] := ANSIString(ReadStrFromMany(1,sfText,' '));
      portList[sfj] := ANSIString(ReadStrFromMany(2,sfText,' '));
      origi_ports[sfComp_nr][0] := ANSIString(ReadStrFromMany(2,sfText,' '));
      inc(sfj);
      portList[sfj] := ANSIString(ReadStrFromMany(3,sfText,' '));
      origi_ports[sfComp_nr][1] := ANSIString(ReadStrFromMany(3,sfText,' '));
      inc(sfComp_nr);
      inc(sfj);
      inc(sfc);
    end;
  end;
  for sf1 := 0 to (componentTotal*2 - 2) do
    for sf2 := (sf1 + 1) to (componentTotal*2 - 1) do
      if portlist[sf2] < portlist[sf1] then
        Str50Swop(portList[sf1],portList[sf2]);
  sfm := 0;
  sfn := 0;
  while sfm < (componentTotal*2) do
    if (portList[sfm] <> portList[sfm+1]) then
    begin
      portList[sfn{+1}] := portList[sfm{+1}];
      inc(sfm); inc(sfn);
      if (portList[sfm-1] = portList[componentTotal*2 - 1]) then break;
    end
    else
      inc(sfm);
  portTotal := sfn;
end; // CycleStoreFile
{ --------------------------- CycleConvertPorts ------------------------------ }
procedure CycleConvertPorts;

var
  cpi, cpz : integer;

begin
  for cpi := 0 to (componentTotal-1) do
  begin
    cpz := 0;
    while origi_ports[cpi,0] <> portList[cpz] do
      inc(cpz);
    lookup_ports[cpi,0] := cpz;
    cpz := 0;
    while origi_ports[cpi,1] <> portList[cpz] do
      inc(cpz);
    lookup_ports[cpi,1] := cpz;
  end;
end; // CycleConvertPorts
{ --------------------------- GetMatrixDimensions ---------------------------- }
procedure GetMatrixDimensions;

var
  mdi, mdj : integer;

begin
  mdi := 0;
  mdj := 0;
  while cOut[mdi,mdj] <> -1 do
  begin
    if mdi > maxI then
      maxI := mdi;
    while (cOut[mdi, mdj] <> -1) do
    begin
      if mdj > maxJ then
        maxJ := mdj;
      inc(mdj);
    end;
    mdj := 0; inc(mdi);
  end;
  inc(maxI);
  inc(maxJ);
end; // GetMatrixDimensions
{ ------------------------------- IsNewVertex -------------------------------- }
function IsNewVertex(invi, invj, invPrev : integer) : Boolean;
begin
  if ((adj[invi,invj] <> 0) and ((invi <> invPrev) or (invi = 0))) then
    IsNewVertex := True
  else
    IsNewVertex := False;
end; // IsNewVertex
{ --------------------------- IncrementDecrement ----------------------------- }
procedure IncrementDecrement(idN : integer; var idInc, idDec : integer);
begin
  if idInc < (idN - 1) then
    inc(idInc)
    else if idInc = (idN - 1) then
      idInc := 0;
  if idDec > 0 then
    dec(idDec)
    else if idDec = 0 then
      idDec := (idN - 1);
end; // IncrementDecrement
{ ----------------------- CheckEquivalenceRotational ------------------------- }
function CheckEquivalenceRotational(ceN, ce1, ce2 : integer) : Boolean;

var
  cei, cej, commonVertex, iDec, jDec, equiv : integer;

begin
  cei := 0;
  cej := 0;
  commonVertex := 0;
  iDec := 0;
  jDec := 0;
  equiv := 1;
  for cei := 0 to (ceN - 1) do
    if cOut[ce1,cei] <> cOut[ce2,cei] then
      equiv := 0;
  if equiv = 1 then
  begin
    CheckEquivalenceRotational := True;
    exit;
  end;
  for cei := 0 to (ceN - 1) do
  begin
    for cej := 0 to (ceN - 1) do
      if cOut[ce1,cei] = cOut[ce2,cej] then
      begin
        commonVertex := 1;
        break;
      end;
    if (commonVertex = 1) then
      break;
  end;
  if commonVertex = 1 then
  begin
    iDec := cei;
    jDec := cej;
    repeat
      IncrementDecrement(ceN, cei, iDec);
      IncrementDecrement(ceN, cej, jDec);
      if ((cOut[ce1,cei] <>  cOut[ce2,cej]) or (cOut[ce1,iDec] <> cOut[ce2,jDec])) then
      begin
        CheckEquivalenceRotational := False;
        exit;
      end;
    until (cei = iDec) or (cej = jDec);
    CheckEquivalenceRotational := True;
    exit;
  end
  else
  begin
    CheckEquivalenceRotational := False;
    exit;
  end;
end; // CheckEquivalenceRotational
{ -------------------- CheckEquivalenceRotationalReverse --------------------- }
function CheckEquivalenceRotationalReverse(ceN, ce1, ce2 : integer) : Boolean;

var
  cei, cej, commonVertex, iDec, jDec, equiv : integer;

begin
  cei := 0;
  cej := 0;
  commonVertex := 0;
  iDec := 0;
  jDec := 0;
  equiv := 1;
  for cei := 0 to (ceN - 1) do
    if cOut[ce1,cei] <> cOut[ce2,ceN-1-cei] then
      equiv := 0;
  if equiv = 1 then
  begin
    CheckEquivalenceRotationalReverse := True;
    exit;
  end;
  for cei := 0 to (ceN - 1) do
  begin
    for cej := 0 to (ceN - 1) do
      if cOut[ce1,cei] = cOut[ce2,cej] then
      begin
        commonVertex := 1;
        break;
      end;
    if (commonVertex = 1) then
      break;
  end;
  if commonVertex = 1 then
  begin
    iDec := cei;
    jDec := cej;
    repeat
      IncrementDecrement(ceN, cei, iDec);
      IncrementDecrement(ceN, cej, jDec);
      if ((cOut[ce1,cei] <>  cOut[ce2,jDec]) or (cOut[ce1,iDec] <> cOut[ce2,cej])) then
      begin
        CheckEquivalenceRotationalReverse := False;
        exit;
      end;
    until (cei = iDec) or (cej = jDec);
    CheckEquivalenceRotationalReverse := True;
    exit;
  end
  else
  begin
    CheckEquivalenceRotationalReverse := False;
    exit;
  end;
end; // CheckEquivalenceRotationalReverse
{ -------------------------------- FindCycle --------------------------------- }
procedure FindCycle(fci, fcj, fcPrev : integer; var fcDone : IntArrayType);

var
  fcSearch, fcPrevPrev, fcUsed, fcEnd, fcStart, fcRepeat, fcCopy : integer;

begin
  fcUsed := 0;
  fcRepeat := 0;
  repeat
    if IsNewVertex(fci, fcj, fcPrev) then
    begin
      fcSearch := 0;
      while((fcSearch < (portTotal+1)) and (fcDone[fcSearch] <> -1)) do
        inc(fcSearch);
      fcDone[fcSearch] := fcj;
      fcSearch := 0;
      while ((fcSearch < (portTotal+1)) and (fcDone[fcSearch] <> -1)) do
        inc(fcSearch);
      fcEnd := fcSearch - 1;
      fcSearch := 0;
      while (fcSearch < fcEnd) do
      begin
        if ((fcDone[fcSearch] = fcj) and (fcj <> 0)) then
        begin
          if (fcUsed = 0) then
            fcRepeat := fcDone[fcSearch];
          fcUsed := 1;
          break;
        end;
        inc(fcSearch);
      end;
      if ((fcUsed = 1) and (fci <> 0)) then
      begin
        fcUsed := 0;
        fcCopy := 0;
        fcStart := 0;
        fcSearch := 0;
        while ((fcSearch < (portTotal+1)) and (fcDone[fcSearch] <> -1)) do
        begin
          if (fcCopy = 2) then
            cOut[ck,(fcSearch - fcStart)] := -1;
          if ((fcDone[fcSearch] = fcRepeat) and (fcCopy = 0)) then
          begin
            fcCopy := 1;
            fcStart := fcSearch;
          end;
          if fcCopy = 1 then
            cOut[ck,fcSearch - fcStart] := fcDone[fcSearch]
          else if ((fcDone[fcSearch] = fcRepeat) and (fcCopy = 1)) then // The copying is complete
            fcCopy := 2;
          inc(fcSearch);
        end;
        inc(ck);
        fcSearch := 0;
        while ((fcSearch < (portTotal+1)) and (fcDone[fcSearch] <> -1)) do
          inc(fcSearch);
        fcDone[fcSearch - 1] := -1;
        inc(fcj);
        if fcj = portTotal then
          fcj := 0;
      end
      else
      begin
        if ((fcj = 0) and (fcPrev <> 0)) then
        begin
          fcSearch := 0;
          while (fcSearch < (portTotal + 1)) and (fcDone[fcSearch] <> -1) do
          begin
            cOut[ck,fcSearch] := fcDone[fcSearch];
            inc(fcSearch);
          end;
          inc(ck);
          fcSearch := 0;
          while ((fcSearch < (portTotal + 1)) and (fcDone[fcSEarch] <> -1)) do
            inc(fcSearch);
          fcDone[fcSearch - 1] := -1;
          inc(fcj);
        end
        else
        begin
          fcPrevPrev := fcPrev;
          fcPrev := fci;
          fci := fcj;
          fcj := fcPrev;
          inc(fcj);
          if fcj = portTotal then
            fcj := 0;
          FindCycle(fci, fcj, fcPrev, fcDone);
          fcj := fci;
          fci := fcPrev;
          fcPrev := fcPrevPrev;
          inc(fcj);
          if fcj = portTotal then
            fcj := 0;
        end;
      end;
    end
    else
    begin
      inc(fcj);
      if fcj = portTotal then fcj := 0;
    end;
  until (fcPrev = fcj);
  fcSearch := 0;
  while ((fcSearch < (portTotal-1)) and (fcDone[fcSearch] <> -1)) do
    inc(fcSearch);
  fcDone[fcSearch - 1] := -1;
end; // FindCycle
{ ------------------------------ FindAllCycles ------------------------------- }
procedure FindAllCycles;

var
  faci, facj : integer;
  facDone : IntArrayType;

begin
  SetLength(facDone,portTotal+2);
  for faci := 0 to (portTotal+1) do
    facDone[faci] := -1;
  facj := 0;
  while facj < portTotal do
  begin
    if adj[0,facj] <> 0 then
    begin
      for faci := 0 to (portTotal+1) do
        facDone[faci] := -1;
      facDone[0] := 0;
      FindCycle(0, facj, 0, facDone);
      break;
    end;
    inc(facj);
  end;
end; // FindAllCycles
{ ---------------------------- FindInvalidCycles ----------------------------- }
procedure FindInvalidCycles;

var
  icN, icM, ici, icj, icp, icq : integer;

begin
  for ici := 0 to maxI do
    for icj := 0 to maxJ do
      if cOut[ici,icj] = -1 then
      begin
        icN := icj - 1;
        for icp := 0 to maxI do
          for icq := 0 to maxJ do
            if cOut[icp,icq] = -1 then
            begin
              icM := icq - 1;
              if ((icN = icM) and (ici <> icp)) then
                if cOut[icp,0] <> -1 then
                  if (CheckEquivalenceRotational(icN, ici, icp) or CheckEquivalenceRotationalReverse(icN, ici, icp)) then
                    cOut[icp, 0] := -1;
              break;
            end;
        break;
      end;
end; // FindInvalidCycles
{ -------------------------- RemoveInvalidCycles ----------------------------- }
procedure RemoveInvalidCycles;

var
  finalOut : DoubleIntArrayType;
  rici, ricj, rick : integer;

begin
  SetLength(finalOut,maxI+1,maxJ+1);
  for rici := 0 to maxI do
    for ricj := 0 to maxJ do
      finalOut[rici,ricj] := -1;
  rick := 0;
  for rici := 0 to (maxI - 1) do
    if cOut[rici,0] <> -1 then
    begin
      for ricj := 0 to (maxJ - 1) do
        if cOut[rici,ricj] <> -1 then
          finalOut[rick,ricj] := cOut[rici,ricj]
        else
          finalOut[rick,ricj] := -1;
      inc(rick);
    end;
  SetLength(cOut,maxI+1,maxJ+1);
  cOut := finalOut;
  SetLength(finalOut,0);
end; // RemoveInvalidCycles;
{ ---------------------------- FindValidCycles ------------------------------- }
procedure FindValidCycles;

begin
  FindAllCycles;
  GetMatrixDimensions;
  FindInvalidCycles;
  RemoveInvalidCycles;
end; // FindValidCycles
{ ---------------------------- WriteCyclesFile ------------------------------- }
procedure WriteCyclesFile;

var
  wcfi, wcfj : integer;
  wcfs : String;

begin
  SetLength(CycleList,0);
  for wcfi := 0 to (maxI - 1) do
  begin
    if cOut[wcfi, 0] = -1 then
      break;
    SetLength(cycleList,Length(cycleList)+1);
    for wcfj := 0 to (maxJ - 2) do
      if cOut[wcfi,wcfj+1] <> -1 then
      begin
        SetLength(cycleList[High(cycleList)],Length(cycleList[High(cycleList)])+1);
        if adj[cOut[wcfi,wcfj],cOut[wcfi,wcfj+1]] < 0 then
        begin
          cycleList[High(cycleList),High(cycleList[High(cycleList)])] := '-'+nameList[-adj[cOut[wcfi,wcfj],cOut[wcfi,wcfj+1]]-1];
        end
        else
        begin
          cycleList[High(cycleList),High(cycleList[High(cycleList)])] := nameList[adj[cOut[wcfi,wcfj],cOut[wcfi,wcfj+1]]-1];
        end;
      end;
  end;
  EchoLn('Cycles:');
  for wcfi := 0 to High(cycleList) do
  begin
    wcfs := '[';
    for wcfj := 0 to High(cycleList[wcfi]) do
      wcfs := wcfs + String(cycleList[wcfi,wcfj]) + ',';
    delete(wcfs,Length(wcfs),1);
    EchoLn(wcfs+']');
  end;
end; // WriteCyclesFile
{ --------------------------------- Cycles ----------------------------------- }
procedure Cycles;

var
  ci, cj, ck : integer;
  cElementAdded : Boolean;

begin
  componentTotal := GetCycleCount;
  SetLength(portList,componentTotal*2);
  portTotal := 0;
  SetLength(nameList,componentTotal+1);
  SetLength(origi_ports,componentTotal,2);
  SetLength(lookup_ports,componentTotal,2);
  for ci := 0 to componentTotal do
    nameList[ci] := '';
  CycleStoreFile;
  CycleConvertPorts;
  SetLength(adj,portTotal + 1,portTotal + 1);
  for ci := 0 to portTotal do
    for cj := 0 to portTotal do
      adj[ci,cj] := 0;
  for ci := 0 to (componentTotal-1) do
    adj[lookup_ports[ci,0],lookup_ports[ci,1]] := ci+1;
  for ci := 0 to (portTotal-1) do
    for cj := 0 to (portTotal-1) do
      if (ci = cj) then
        adj[ci,cj] := 0
      else if (adj[ci,cj] > 0) then
        adj[cj,ci] := -adj[ci,cj]
      else if (adj[cj,ci] > 0) then
        adj[ci,cj] := -adj[cj,ci];

  maxI := 0;
  maxJ := 0;
  SetLength(cOut,HRN *portTotal, portTotal+2);
  for ci := 0 to (HRN*portTotal-1) do
    for cj := 0 to (portTotal + 1) do
      cOut[ci,cj] := -1;
  FindValidCycles;
  WriteCyclesFile;
  for ci := 0 to High(cycleList) do
    for cj := 0 to High(cycleList[ci]) do
    begin
      if (ci = 0) and (cj = 0) then
      begin
        SetLength(elements,Length(elements)+1);
        elements[High(elements)].Name := ANSIString(StripMinus(String(cycleList[ci, cj])));
      end
      else
      begin
        cElementAdded := False;
        for ck := 0 to High(elements) do
          if StripMinus(String(cycleList[ci, cj])) = String(elements[ck].Name) then
            cElementAdded := True;
        if not cElementAdded then
        begin
          SetLength(elements,Length(elements)+1);
          elements[High(elements)].Name := ANSIString(StripMinus(String(cycleList[ci, cj])));
        end;
      end;
    end;
  SetLength(adj,0);
  SetLength(cOut,0);
end;

end.
