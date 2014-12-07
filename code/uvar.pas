{ utilities for working with variants and arrays of variants. }
{$mode delphiunicode}{$i xpc.inc}
unit uvar;
interface uses xpc, variants, sysutils;

type
  TVar   = variant;
  TVars  = variant; //array of TVar;
  TVarFn = function(v : TVar):TVar;

function A(vars : array of TVar) : TVars;

function drop(n : word; vars: TVars) : TVars;
function behead( vars : TVars ) :TVars;
function link(x,y : TVar) : TVars;
function implode(glue : TStr; vars: TVars) : TStr;
function join(glue : TVar; vars: TVars) : TVars;
function repr( v : TVar ) : TVar;
function map(f : TVarFn; vars : TVars) : TVars;
function len( v : TVar ) : cardinal;


implementation

{-- constructor for array of variants -------------------------}

function A(vars : array of TVar) : TVars;
  var i : cardinal;
  begin
    if length(vars) > 0 then begin
      result := VarArrayCreate([0,High(vars)],varVariant);
      for i := 0 to High(vars) do result[i]:=vars[i];
    end else result := NULL;
  end;

function len( v : TVar ) : cardinal;
  begin
    if varIsEmpty(v) or (v = NULL) or varIsNull(v) then result := 0
      else if varIsArray(v) then
        result:=varArrayHighBound(v,1)-varArrayLowBound(v,1)+1
      else if varIsStr(v) then result:=length(v)
      else result := 1
  end;

{-- restructuring tools ---------------------------------------}

function drop(n : word; vars: tvars) : TVars; inline;
  var i : integer;
  begin
    if vars.IsArray and (vars.ArrayHighBound > n) then begin
      result := VarArrayCreate([0, vars.Count-n], vars.vType);
      for i := n to vars.ArrayHighBound do result[i-n] := vars[i]
    end
    else result := vars;
  end;

function behead( vars : tvars ) :TVars; inline;
  begin result := drop(1, vars)
  end;

function link( x, y : TVar ): TVars;
  var i,j : cardinal;
  begin
    if x = NULL then result := y
    else if y = NULL then result := x
    else begin
      if not x.isArray then x := A([x]);
      if not y.isArray then y := A([y]);
      j := x.Count; result := VarArrayCreate([j+y.Count], varVariant);
      if x.Count>0 then for i := 0 to x.ArrayHighBound do result[i] := x[i];
      if y.Count>0 then for i := 0 to y.ArrayHighBound do result[j+i] := y[i];
    end;
  end;

{--  string related --}
function join(glue : tvar; vars: tvars) : TVars;
  var i,vlen : integer;
  begin vlen := len(vars);
    case vlen of
      0 : result := '';
      1 : result := vars;
      else begin
        result := VarArrayCreate([0,vlen*2-2], varVariant);
        for i := 0 to vlen-2 do begin
          result[i*2]:=vars[i]; result[i*2+1]:=glue
        end;
        result[2*(vlen-1)] := vars[vlen-1]
      end;
    end
  end;

function implode(glue : TStr; vars: tvars) : TStr;
  var a:TVars; i:integer;
  begin
    a := join(glue,vars); result:='';
    if len(a)=0 then ok
    else if len(a)=1 then result := a[0]
    else for i:=0 to len(a)-1 do result+=a[i];
  end;

function repr( v : TVar ) : TVar;
  var s: TStr='';
  begin
    if v=NULL then s := '[]'
    else if VarIsArray(v) then
      s := implode(' ',A(['[',implode(' ',map(repr,v)),']']))
    else if VarIsStr(v) then s := '"' + v + '"'
    else writestr(s, v);
    result := s;
  end;


{-- higher order functions --}

function map(f : TVarFn; vars : TVars) : TVars;
  var i,vlen : cardinal;
  begin
    vlen := len(vars);
    if vlen=0 then result := A([])
    else begin
      result := VarArrayCreate([0,vlen-1], varVariant);
      for i:=0 to vlen-1 do result[i] := f(vars[i]);
    end
  end;

initialization
end.
