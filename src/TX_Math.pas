unit TX_Math;

{*******************************************************************************
*    Unit TX_Math (for use with TimEx)                                         *
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
  SysUtils, Math, TX_Globals;
type
  DoubleArrayTipe = array of array of double;
  DoubleArraySingleTipe = array of double;

function CheckIfInteger(TestStr : string) : boolean;
function CheckIfReal(TestStr : string) : boolean;
procedure IntSwop(var int1, int2 : integer);
function ReturnLargest(Num1, Num2 : integer) : integer;
function EvaluateFunctionGauss(eStr : string) : double;


implementation

{ ----------------------------- CheckIfInteger ------------------------------- }
function CheckIfInteger(TestStr : string) : boolean;

var
  c1 : integer;
  cb : boolean;

begin
  cb := true;
  if length(TestStr) = 1 then
    if not (ord(TestStr[1]) in [48..57]) then cb := false;
  if not ((ANSIChar(TestStr[1]) in ['+','-']) or (ord(TestStr[1]) in [48..57])) then
    cb := false;
  for c1 := 2 to length(TestStr) do
    if not (ord(TestStr[c1]) in [48..57]) then  // check if ordinal values of every character is in range 48 (0) to 57 (9)
      cb := false;
  CheckIfInteger := cb;
end; // CheckIfInteger
{ ------------------------------ CheckIfReal --------------------------------- }
function CheckIfReal(TestStr : string) : boolean;

var
  c1 : integer;
  cb, cexpfound, cpointfound, cesignfound, cefound : boolean;

begin
  cb := true; cexpfound := false; cpointfound := false; cefound := false; cesignfound := false;
  while copy(TestStr,1,1) = ' ' do
    delete(TestStr,1,1);                // strip leading spaces
  if TestStr = '' then // It's empty!
  begin
    CheckIfReal := False;
    Exit;
  end;
  while copy(TestStr,length(TestStr),1) = ' ' do
    delete(TestStr,length(TestStr),1);  // strip trailing spaces
  if length(TestStr) = 1 then
    if not (ord(TestStr[1]) in [48..57]) then cb := false;
  if not ( (ord(TestStr[1]) in [48..57]) or (ANSIChar(TestStr[1]) in ['-','+','.']) ) then
    cb := false;
  if  copy(TestStr,1,1) = '.' then
    cpointfound := true;
  for c1 := 2 to length(TestStr) do
  begin
    if (cpointfound or cefound) and (copy(TestStr,c1,1) = '.') then
      cb := false;
    if copy(TestStr,c1,1) = '.' then cpointfound := true;
    if (not cefound) and (ANSIChar(TestStr[c1]) in ['-','+']) then
      cb := false;
    if cefound and (ord(TestStr[c1]) in [48..57]) then
      cexpfound := true;
    if not ( (ord(TestStr[c1]) in [48..57]) or (ANSIChar(TestStr[c1]) in ['-','+','.','e','E']) ) then cb := false;
    if cefound and (ANSIChar(TestStr[c1]) in ['e','E']) then
      cb := false;
    if ANSIChar(TestStr[c1]) in ['e','E'] then
      cefound := true;
    if (cefound and cexpfound) and (ANSIChar(TestStr[c1]) in ['-','+']) then
      cb := false;
    if (cefound and (not cexpfound)) and (ANSIChar(TestStr[c1]) in ['-','+']) then
      if not cesignfound then
        cesignfound := true
      else
        cb := false;
  end;
  CheckIfReal := cb;
end; // CheckIfReal
{ --------------------------------- IntSwop ---------------------------------- }
procedure IntSwop(var int1, int2 : integer);

var
  is1 : integer;

begin
  is1 := int1;
  int1 := int2;
  int2 := is1;
end; // IntSwop
{ ------------------------------ ReturnLargest ------------------------------- }
function ReturnLargest(Num1, Num2 : integer) : integer;

begin
  if Num1 > Num2 then
    ReturnLargest := Num1
  else ReturnLargest := Num2;
end;  // ReturnLargest
{ ------------------------- EvaluateFunctionGauss ---------------------------- }
function EvaluateFunctionGauss(eStr : string) : double;
// Returns value from gaussian distribution, found from eStr
var
  ef1, ef2 : double;
begin
  ef1 := 1;
  ef2 := 0;
  if CheckIfReal(copy(eStr, pos('(',eStr)+1, pos(',',eStr)-pos('(',eStr)-1)) then
    ef1 := StrToFloat(copy(eStr, pos('(',eStr)+1, pos(',',eStr)-pos('(',eStr)-1));
  if CheckIfReal(copy(eStr, pos(',',eStr)+1, pos(')',eStr)-pos(',',eStr)-1)) then
    ef2 := StrToFloat(copy(eStr, pos(',',eStr)+1, pos(')',eStr)-pos(',',eStr)-1));
  if applyRandom then
    EvaluateFunctionGauss := RandG(ef1,ef2)
  else
    EvaluateFunctionGauss := ef1; // If not applyRandom: use mean value
end;


end.
