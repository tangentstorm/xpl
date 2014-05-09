{ utilities for working with variants and arrays of variants. }
{$mode delphiunicode}{$i xpc.inc}
unit uvar;
interface uses xpc, variants, sysutils;

type
  TVar = variant;
  TVars = array of TVar;

function A(vars : array of TVar) : TVars;

function drop(n : word; vars: tvars) : TVars;
function behead( vars : tvars ) :TVars;
function implode(glue : tvar; vars: tvars) : TVars;
function repr( v : TVar ) : TStr;

implementation

{-- constructor for array of variants -------------------------}

function A(vars : array of TVar) : TVars; inline;
  begin result := g<TVar>.fromOpenArray(vars);
  end;

{-- helpers ----------------------------------------------------}

function drop(n : word; vars: tvars) : TVars; inline;
  var i : integer;
  begin
    if length(vars) > n then begin
      setlength(result, length(vars)-n);
      for i := n to length(vars) -1 do result[i-n] := vars[i]
    end
   else setlength(result,0)
  end;

function behead( vars : tvars ) :TVars; inline;
  begin result := drop(1, vars)
  end;

function implode(glue : tvar; vars: tvars) : TVars; inline;
  var i, len : integer;
  begin
    len := length(vars);
    if len <= 1 then result := vars
    else begin
      setlength(result, len*2-1);
      for i := 0 to len-2 do begin
        result[i*2]:=vars[i]; result[i*2+1]:=glue
      end;
      result[2*(len-1)] := vars[len-1]
    end
  end;

function repr( v : TVar ) : TStr; inline;
  var item : TVar;
  begin
    if VarIsArray(v) then
      begin
	result :='';
	for item in implode(' ', TVars(v)) do result += repr(item);
	if length(result) > 0 then result := '[ ' + result + ' ]'
	else result := '[]'
      end
    else writestr(result, v);
  end;

initialization
end.
