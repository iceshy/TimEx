unit TX_Strings;

{*******************************************************************************
*    Unit TX_Strings (for use with TimEx)                                      *
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
  SysUtils, TX_Math, TX_Globals;

function ReadSpiceVariableValue(rv : string) : Double;
procedure SetSpiceVariableValue(svName : string; svValue : double);
procedure ExitWithHaltCodeStrings(EText : string; HCode : integer);
function EvaluateSpiceExpression(eeTest : string; leadingMinus : Double) : Double;
procedure WriteDot(wdLength, wdDotSize : Integer; var wdCount, wdLastDot : Integer);
function StripSpaces(FullString : string) : string;
function StripMinus(FullString : string) : string;
function StringToDouble(txtext : string) : double;
function ReadRealFromText(txtext : string; varDefault : double; errorText : string) : double;
function ReadIntFromText(txtext : string; varDefault : integer; errorText : string) : integer;
function ReadStrFromText(txtext : string) : string;
function ReadValueAfterEqualSign(rText, rIdentifier : string) : string;
function ConvertToValue(cvStr : string) : double;
function ReadStrFromMany(txIndex : integer; txtext, txSeparator : string) : string;
function CountSubstrings(cText, cSeparator : String) : Integer;
function ReadLastStrFromMany(var txtext : string; txSeparator : string; txWipe : boolean) : string;
function CreateTab(txSpaces : Integer) : string;
procedure AddValueToTextString(avValue : Double; var avTeks : string; avMinValue : Double; avExceptTeks : string; avPrecision, avDigits, avTrimLength, avPadLength : Integer);
function SynthesizeSpiceCard(sCardLineRaw : string) : string;
procedure SynthesizeSpiceCardNoise(sCardLineRaw : string; var sFile : TextFile);

implementation

{ ------------------------- ExitWithHaltCodeStrings -------------------------- }
procedure ExitWithHaltCodeStrings(EText : string; HCode : integer);
// Writes text to both the screen and an output file, then closes file and halts
begin
  WriteLn('('+IntToStr(HCode)+') '+EText);
  WriteLn(OutFile,'('+IntToStr(HCode)+') '+ EText);
  CloseFile(OutFile);
  Halt(HCode);
end; // ExitWithHaltCode
{ ---------------------------- StringIsDigit --------------------------------- }
function StringIsDigit(siChar : Char) : boolean;

begin
  if ANSIChar(siChar) in ['0'..'9'] then
    StringIsDigit := True
  else
    StringIsDigit := False;
end;
{ ------------------------- ReadSpiceVariableValue --------------------------- }
function ReadSpiceVariableValue(rv : string) : Double;

var
  rv1 : Integer;
  rvRet : Double;
begin
  rvRet := 0;
  if ANSIChar(rv[1]) in ['a'..'z','A'..'Z','_'] then
  begin
    for rv1 := 0 to High(spiceVariables) do
      if spiceVariables[rv1].name = ANSIString(Copy(rv,1,Length(rv))) then
        rvRet := spiceVariables[rv1].value;
  end
  else
    if CheckIfReal(rv) then
      rvRet := StrToFloat(rv)
    else
      ExitWithHaltCodeStrings('Cannot parse '+rv+'.', 0);
  ReadSpiceVariableValue := rvRet;
end; // ReadSpiceVariableValue
{ -------------------------- SetSpiceVariableValue --------------------------- }
procedure SetSpiceVariableValue(svName : string; svValue : double);

var
  sv1 : Integer;
begin
  for sv1 := 0 to High(spiceVariables) do
    if LowerCase(String(spiceVariables[sv1].name)) = LowerCase(svName) then
      spiceVariables[sv1].Value := svValue;
end; // SetSpiceVariableValue
{ ---------------------- ReplacePlusMinusArithmeticOps ----------------------- }
function ReplacePlusMinusArithmeticOps(rpStr : string) : string;
// Replace "-" with "[" and "+" with "]" in strings to prevent Expression Evaluation clashes with E+ and E- in scientific notation
var
  rp1 : integer;
  rpNewStr : string;

begin
  if rpStr = '' then
  begin
    ReplacePlusMinusArithmeticOps := '';
    exit;
  end;
  rpNewStr := '';
  for rp1 := 1 to (Length(rpStr)-1) do
  begin
    if rpStr[rp1] = '-' then
    begin
      if Length(rpStr) > 3 then
        if (rpStr[rp1-1] <> 'e') or (not StringIsDigit(rpStr[rp1-2])) or (not StringIsDigit(rpStr[rp1+1])) then
          rpNewStr := rpNewStr + '['
        else
          rpNewStr := rpNewStr + '-'
      else
        rpNewStr := rpNewStr + '[';
    end
    else
    begin
      if rpStr[rp1] = '+' then
      begin
        if Length(rpStr) > 3 then
          if (rpStr[rp1-1] <> 'e') or (not StringIsDigit(rpStr[rp1-2])) or (not StringIsDigit(rpStr[rp1+1])) then
            rpNewStr := rpNewStr + ']'
          else
            rpNewStr := rpNewStr + '+'
        else
          rpNewStr := rpNewStr + ']';
      end
      else
        rpNewStr := rpNewStr + rpStr[rp1];
    end;
  end;
  rpNewStr := rpNewStr + rpStr[Length(rpStr)];
  ReplacePlusMinusArithmeticOps := rpNewStr;
end;
{ ------------------------ EvaluateSpiceExpression --------------------------- }
function EvaluateSpiceExpression(eeTest : string; leadingMinus : Double) : Double;
// Recursively find value of expression. Operator prededence : / * + -
var
  eeStr, eeTempStr1, eeTempStr2 : string;
  t1, t2, fVal : double;
  ee1, ee2 : integer;
  pClosedFound, noFunctions : boolean;

begin
  eeStr := LowerCase(StripSpaces(eeTest));
  eeStr := ReplacePlusMinusArithmeticOps(eeStr);
  // Process functions
  repeat
    noFunctions := true;
    if pos('gauss(',eeStr) > 0 then  // Guassian random variable - evaluate
    begin
      noFunctions := false;
      eeTempStr1 := copy(eeStr,pos('gauss(',eeStr),length(eeStr)-pos('gauss(',eeStr)+1);
      eeTempStr2 := copy(eeTempStr1,1,pos(')',eeTempStr1));
      if eeTempStr2 <> '' then
        // In order to evaluate expressions for "gauss", we need to copy correct string with all parentheses. This not handled yet.
        fVal := EvaluateFunctionGauss(eeTempStr2)
      else
        fVal := 1;
      eeStr := copy(eeStr,1,pos(eeTempStr1,eeStr)-1)+FloatToStrF(fVal,ffGeneral,5,4)+copy(eeStr,pos(eeTempStr1,eeStr)+length(eeTempStr2),length(eeStr)-pos(eeTempStr1,eeStr)-length(eeTempStr2)+1);
    end;
  until noFunctions;

  // Firstly, evaluate the parentheses.
  if (Length(eeStr) > 1) and (pos('(',eeStr) > 0) then // Cannot open and close parentheses in only one string character
  begin
    ee1 := Length(eeStr)-1;
    repeat
      if copy(eeStr,ee1,1) = '(' then    // Last opening parenthesis found - now look for closing parenthesis
      begin
        ee2 := ee1+1;
        pClosedFound := False;
        repeat
          if copy(eeStr,ee2,1) = ')' then    // First closing parenthesis found - Now to evaluate the expression within
            pClosedFound := True
          else
            ee2 := ee2+1;
        until (ee2 > Length(eeStr)) or (pClosedFound);
        if not pClosedFound then
          ExitWithHaltCodeStrings('Cannot find closing parenthesis in "'+eeStr+'".', 3);
        eeTempStr1 := ''; eeTempStr2 := '';
        if ee1 > 1 then
          eeTempStr1 := Copy(eeStr,1,ee1-1);
        if ee2 < Length(eeStr) then
          eeTempStr2 := Copy(eeStr,ee2+1,Length(eeStr)-ee2);
        eeStr := eeTempStr1 + lowercase(FloatToStrF(EvaluateSpiceExpression(Copy(eeStr,ee1+1,ee2-ee1-1), 1.0),ffExponent,15,4)) + eeTempStr2;
        eeStr := ReplacePlusMinusArithmeticOps(eeStr);
        ee1 := Length(eeStr);
      end;
      ee1 := ee1-1;
    until (ee1 < 1);
  end;
  if (pos('[',eeStr) > 0) then // character for arithmetic "-" operator
  begin
    t1 := EvaluateSpiceExpression(Copy(eeStr,1,pos('[',eeStr)-1), leadingMinus);   // If a leading minus was sent in, pass it down
    t2 := EvaluateSpiceExpression(Copy(eeStr,pos('[',eeStr)+1,Length(eeStr)-pos('[',eeStr)), -1.0);
    EvaluateSpiceExpression := t1+t2; // We work the "-" into the first variable in the new term...
    exit;
  end
  else if pos(']',eeStr) > 0 then // character for arithmetic "+" operator
  begin
    t1 := EvaluateSpiceExpression(Copy(eeStr,1,pos(']',eeStr)-1), leadingMinus);
    t2 := EvaluateSpiceExpression(Copy(eeStr,pos(']',eeStr)+1,Length(eeStr)-pos(']',eeStr)), 1.0);
    EvaluateSpiceExpression := t1+t2;
    exit;
  end
  else if pos('*',eeStr) > 0 then
  begin
    t1 := EvaluateSpiceExpression(Copy(eeStr,1,pos('*',eeStr)-1), leadingMinus);
    t2 := EvaluateSpiceExpression(Copy(eeStr,pos('*',eeStr)+1,Length(eeStr)-pos('*',eeStr)), 1.0);
    EvaluateSpiceExpression := t1*t2;
    exit;
  end
  else if pos('/',eeStr) > 0 then
  begin
    t1 := EvaluateSpiceExpression(Copy(eeStr,1,pos('/',eeStr)-1), leadingMinus);
    t2 := EvaluateSpiceExpression(Copy(eeStr,pos('/',eeStr)+1,Length(eeStr)-pos('/',eeStr)), 1.0);
    EvaluateSpiceExpression := t1/t2;
    exit;
  end
  else
  begin // No operator - evaluate variable
    if eeStr <> '' then
    begin
//      if eeStr[1] = '@' then
      if (ANSIChar(eeStr[1]) in ['a'..'z','A'..'Z','_']) then
        EvaluateSpiceExpression := leadingMinus * ReadSpiceVariableValue(eeStr)
      else
      begin
        EvaluateSpiceExpression := leadingMinus * StringToDouble(eeStr);
      end;
    end
    else
      EvaluateSpiceExpression := EPSILON; // Not a good idea... change to error
    exit;
  end;
end; // EvaluateSpiceExpression
{ -------------------------------- WriteDot ---------------------------------- }
procedure WriteDot(wdLength, wdDotSize : Integer; var wdCount, wdLastDot : Integer);

begin
  wdCount := wdCount + wdLength;
  if (wdCount div wdDotSize) > wdLastDot then
  begin
    Write('.');
    inc(wdLastDot,1);
  end;
end;  // WriteDot;
{ ------------------------------ StripSpaces --------------------------------- }
function StripSpaces(FullString : string) : string;

var
  fstr : string;

begin
  fstr := FullString;
  while (copy(fstr,1,1) = ' ') or (copy(fstr,1,1) = #9) do
    delete(fstr,1,1);                // strip leading spaces
  while (copy(fstr,length(fstr),1) = ' ') or (copy(fstr,length(fstr),1) = #9) do
    delete(fstr,length(fstr),1);  // strip trailing spaces
  StripSpaces := fstr;
end;  // StripSpaces
{ ------------------------------- StripMinus --------------------------------- }
function StripMinus(FullString : string) : string;

var
  fstr : string;

begin
  fstr := FullString;
  if (copy(fstr,1,1) = '-') then
    delete(fstr,1,1);                // strip leading minus
  StripMinus := fstr;
end;  // StripMinus
{-------------------------------------------- StringToDouble ---}
function StringToDouble(txtext : string) : double;
var
  stdMultiplier, stdValue : Double;
  std1 : Integer;
  suffixFound : Boolean;
begin
  suffixFound := False;  stdMultiplier := 1;
  for std1 := 1 to Length(txtext) do
    if not ((ord(ANSIChar(txtext[std1])) in [48..57]) or (ANSIChar(txtext[std1]) in ['.', ',', 'e', 'E', '+', '-'])) then
      begin
        if LowerCase(txtext[std1]) = 'a' then
          begin
            stdMultiplier := 1E-18; suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'f' then
          begin
            stdMultiplier := 1E-15; suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'p' then
          begin
            stdMultiplier := 1E-12; suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'n' then
          begin
            stdMultiplier := 1E-9; suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'u' then
          begin
            stdMultiplier := 1E-6; suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'm' then
          begin
            if LowerCase(copy(txtext,std1,3)) = 'meg' then
              stdMultiplier := 1E6
              else
                stdMultiplier := 1E-3;
            suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'k' then
          begin
            stdMultiplier := 1E3; suffixFound := True;
          end;
        if LowerCase(txtext[std1]) = 'g' then
          begin
            stdMultiplier := 1E9; suffixFound := True;
          end;
        break;
      end;
  if not suffixFound then
    begin
      if CheckIfReal(txtext) then
        stdValue := StrToFloat(txtext)
        else
          stdValue := 0;
    end
    else
      if CheckIfReal(copy(txtext,1,std1-1)) then
        stdValue := StrToFloat(copy(txtext,1,std1-1))
        else
          stdValue := 0;
  StringToDouble := stdValue*stdMultiplier;
end; // StringToDouble
{--------------------------------------------ReadRealFromText---}
function ReadRealFromText(txtext : string; varDefault : double; errorText : string) : double;
begin
  if CheckIfReal(StripSpaces(copy(txtext,pos('=',txtext)+1,length(txtext)-pos('=',txtext)))) then
    ReadRealFromText := StrToFloat(StripSpaces(copy(txtext,pos('=',txtext)+1,length(txtext)-pos('=',txtext))))
    else
      begin
        WriteLn(errorText+' Default value of '+FloatToStrF(varDefault,ffGeneral,6,6)+' assigned.');
        WriteLn(outFile, errorText+' Default value of '+FloatToStrF(varDefault,ffGeneral,6,6)+' assigned.');
        ReadRealFromText := varDefault;
      end;
end;  // ReadRealFromText
{--------------------------------------------ReadIntFromText---}
function ReadIntFromText(txtext : string; varDefault : integer; errorText : string) : integer;
begin
  if CheckIfInteger(StripSpaces(copy(txtext,pos('=',txtext)+1,length(txtext)-pos('=',txtext)))) then
    ReadIntFromText := StrToInt(StripSpaces(copy(txtext,pos('=',txtext)+1,length(txtext)-pos('=',txtext))))
    else
      begin
        WriteLn(errorText+' Default value of '+IntToStr(varDefault)+' assigned.');
        WriteLn(outFile,errorText+' Default value of '+IntToStr(varDefault)+' assigned.');
        ReadIntFromText := varDefault;
      end;
end;  // ReadRealFromText
{ ---------------------------- ReadStrFromText ------------------------------- }
function ReadStrFromText(txtext : string) : string;

begin
  if StripSpaces(copy(txtext,pos('=',txtext)+1,length(txtext)-pos('=',txtext))) = '' then
    ReadStrFromText := ' ' // pass back a space so that it is not empty
  else
    ReadStrFromText := lowercase(StripSpaces(copy(txtext,pos('=',txtext)+1,length(txtext)-pos('=',txtext))));
end;  // ReadStrFromText
{ ------------------------ ReadValueAfterEqualSign --------------------------- }
function ReadValueAfterEqualSign(rText, rIdentifier : string) : string;
// Read string value after the '=' in a string that follows directly after the identifier substring
var
  rTrim : String;

begin
  rTrim := rText;
  if pos(rIdentifier,rTrim) < 1 then
  begin
    ReadValueAfterEqualSign := '';
    exit;
  end;
  Delete(rTrim,1,pos(rIdentifier,rTrim)-1);
  Delete(rTrim,1,pos('=',rTrim));
  rTrim := StripSpaces(rTrim);
  if pos(' ',rTrim) > 0 then
    Delete(rTrim,pos(' ',rTrim),length(rTrim)-pos(' ',rTrim)+1);
  ReadValueAfterEqualSign := rTrim;
end; // ReadValueAfterEqualSign
{ ---------------------------- ConvertToValue -------------------------------- }
function ConvertToValue(cvStr : string) : double;
// Convert a SPICE/JSIM element value to a double - might contain braced expressions
var
  cvStrTrim : string;
  cvValue : Double;
begin
  if pos('=',cvStr) > 0 then
    cvStrTrim := copy(cvStr,pos('=',cvStr)+1,Length(cvStr)-pos('=',cvStr))
  else
    cvStrTrim := cvStr;
  cvValue := EPSILON;
  if (pos('{',cvStrTrim) > 0) then
  begin
    if (pos('}',cvStrTrim) > 0) and (pos('}',cvStrTrim) > pos('{',cvStrTrim)) then
      cvValue := EvaluateSpiceExpression(copy(cvStrTrim,pos('{',cvStrTrim)+1,pos('}',cvStrTrim) - pos('{',cvStrTrim)-1),1);
  end
  else
    cvValue := StringToDouble(cvStrTrim);
  ConvertToValue := cvValue;
end; // ConvertToValue
{ ---------------------------- ReadStrFromMany ------------------------------- }
function ReadStrFromMany(txIndex : integer; txtext, txSeparator : string) : string;

var
  txOrig : string;
  tx1 : Integer;

begin
  txOrig := txtext;
  for tx1 := 1 to (txIndex-1) do
  begin
    if pos(txSeparator,txOrig) = 0 then
    begin
      ReadStrFromMany := ' ';
      exit;
    end;
    txOrig := copy(txOrig,pos(txSeparator,txOrig)+1,length(txOrig)-pos(txSeparator,txOrig));
    while copy(txOrig,1,1) = txSeparator do
      Delete(txOrig,1,1);
    if txOrig = '' then
    begin
      ReadStrFromMany := ' ';
      exit;
    end;
  end;
  if StripSpaces(txOrig) = '' then
    ReadStrFromMany := ' ' // pass back a space so that it is not empty
  else
  begin
    if pos(txSeparator,txOrig) > 0 then
      txOrig := copy(txOrig,1,pos(txSeparator,txOrig)-1);
    txOrig := lowercase(StripSpaces(txOrig));
    if pos('=',txOrig) > 0 then
      txOrig := copy(txOrig,1,pos('=',txOrig)-1);  // Remove "=" sign if present
    ReadStrFromMany := txOrig;
  end;
end;  // ReadStrFromMany
{ ---------------------------- CountSubstrings ------------------------------- }
function CountSubstrings(cText, cSeparator : String) : Integer;

var
  cCount : Integer;

begin
  cCount := 0;
  while ReadStrFromMany(cCount+1,cText,cSeparator) <> ' ' do
  begin
    inc(cCount);
    if cCount > 1024 then
      Break;  // Failsafe. Strings surely won't have that many substrings.
  end;
  CountSubstrings := cCount;
end; // CountSubstrings
{ --------------------------- ReadLastStrFromMany ---------------------------- }
function ReadLastStrFromMany(var txtext : string; txSeparator : string; txWipe : boolean) : string;

var
  txRes : string;
  tx1 : Integer;

begin
  txtext := StripSpaces(txtext); txRes := ' '; // Don't send back an empty string...
  tx1 := Length(txtext);
  while not (copy(txtext,tx1,1) = txSeparator) do
    dec(tx1,1);
  if tx1= 0 then
    txRes := ' '
  else
  begin
    txRes := copy(txtext,tx1,length(txtext)-tx1+1);
    if txWipe then
      Delete(txtext,tx1,length(txtext)-tx1+1);
  end;
  if StripSpaces(txRes) = '' then
    ReadLastStrFromMany := ' ' // pass back a space so that it is not empty
  else
    ReadLastStrFromMany := lowercase(StripSpaces(txRes));
end;  // ReadLastStrFromMany
{ ------------------------------- CreateTab ---------------------------------- }
function CreateTab(txSpaces : Integer) : string;

var
  cti : Integer;
  cts : String;

begin
  cts := '';
  for cti := 1 to txSpaces do
    cts := cts + ' ';
  CreateTab := cts;
end;  // CreateTab
{ -------------------------- AddValueToTextString ---------------------------- }
procedure AddValueToTextString(avValue : Double; var avTeks : string; avMinValue : Double; avExceptTeks : string; avPrecision, avDigits, avTrimLength, avPadLength : Integer);

begin
  if abs(avValue) > avMinValue then
    avTeks := avTeks + FloatToStrF(avValue,ffFixed,avPrecision,avDigits)
  else avTeks := avTeks + avExceptTeks;
  while (Length(avTeks) > (avTrimLength+1)) and (copy(avTeks,length(avTeks),1) <> '.') do    // don't make shorter than integer part
    Delete(avTeks,Length(avTeks),1);
  if Length(avTeks) > avTrimLength then
    Delete(avTeks,Length(avTeks),1);  // trim last digit, especially if it is just '.'
  if avTeks[length(avTeks)] = '.' then
    Delete(avTeks,Length(avTeks),1);  // trim '.' if that is the last character
  while length(avTeks) < avPadLength do
    avTeks := avTeks+' ';
end;  // AddValueToTextString
{ -------------------------- SynthesizeSpiceCard ----------------------------- }
function SynthesizeSpiceCard(sCardLineRaw : string) : string;

var
  sCard, sSnippet, sCardLeft, sCardRight : string;
  sValue : double;

begin
  if pos('.param',LowerCase(sCardLineRaw)) > 0 then
    sCard := '*'+sCardLineRaw                          // .PARAM not supported in JSIM yet - comment the line
  else
    sCard := sCardLineRaw;
  repeat
    if (pos('{',sCard) > 0) then
    begin
      if (pos('}',sCard) > 0) and (pos('}',sCard) > pos('{',sCard)) then
      begin
        sCardLeft := copy(sCard,1,pos('{',sCard)-1);
        if pos('}',sCard) < Length(sCard) then
          sCardRight := copy(sCard,pos('}',sCard)+1,Length(sCard)-pos('}',sCard))
        else
          sCardRight := '';
        sSnippet := copy(sCard,pos('{',sCard)+1,pos('}',sCard) - pos('{',sCard)-1);
        sValue := EvaluateSpiceExpression(sSnippet,1);
        sSnippet := FloatToStrF(sValue,ffGeneral,6,4);
        sCard := sCardLeft + sSnippet + sCardRight;
      end;
    end;
  until (pos('{',sCard) = 0);
  if pos('}',sCard) > 0 then
    ExitWithHaltCodeStrings('Cannot synthesize spice card: '+sCardLineRaw,0);
  SynthesizeSpiceCard := sCard;
end; // SynthesizeSpiceCard

{ ------------------------ SynthesizeSpiceCardNoise -------------------------- }
procedure SynthesizeSpiceCardNoise(sCardLineRaw : string; var sFile : TextFile);

var
  sCard, sCard2, sSnippet, sCardLeft, sCardRight : string;
  sValue, sNoiseAmp : double;

begin
  if pos('.param',LowerCase(sCardLineRaw)) > 0 then
  begin
    sCard := '*'+sCardLineRaw;                          // .PARAM not supported in JSIM yet - comment the line
    WriteLn(sFile,sCard);
  end
  else
  begin
    sCard := sCardLineRaw;
    repeat
      if (pos('{',sCard) > 0) then
      begin
        if (pos('}',sCard) > 0) and (pos('}',sCard) > pos('{',sCard)) then
        begin
          sCardLeft := copy(sCard,1,pos('{',sCard)-1);
          if pos('}',sCard) < Length(sCard) then
            sCardRight := copy(sCard,pos('}',sCard)+1,Length(sCard)-pos('}',sCard))
          else
            sCardRight := '';
          sSnippet := copy(sCard,pos('{',sCard)+1,pos('}',sCard) - pos('{',sCard)-1);
          sValue := EvaluateSpiceExpression(sSnippet,1);
          sSnippet := FloatToStrF(sValue,ffGeneral,6,4);
          sCard := sCardLeft + sSnippet + sCardRight;
        end;
      end;
    until (pos('{',sCard) = 0);
    if pos('}',sCard) > 0 then
      ExitWithHaltCodeStrings('Cannot synthesize spice card: '+sCardLineRaw,0);
    WriteLn(sFile,sCard);
    if (LowerCase(sCard[1]) = 'r') and (noiseTemp > 0) and (numSimsTol > 1) and applyRandom then
    begin
      sValue := StrToFloat(ReadStrFromMany(4,sCard,' '));
      sNoiseAmp := sqrt(4*1.38e-23*noiseTemp/sValue);
      sCard2 := 'inoise'+ReadStrFromMany(1,sCard,' ')+' '+ReadStrFromMany(2,sCard,' ')+' '+ReadStrFromMany(3,sCard,' ')+' NOISE('
               +FloatToStrF(sNoiseAmp,ffGeneral,5,4)+' 0.0 1.0p)';
      Writeln(sFile,sCard2);
    end;
  end;
end; // SynthesizeSpiceCardNoise


end.
