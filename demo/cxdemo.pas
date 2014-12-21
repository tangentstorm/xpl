// demo of cx unit, which provides (c)olorized e(x)ception tracebacks.
{$mode delphi}
program cxdemo;
uses xpc, cx, sysutils;

type
  ECxDemoException = class (Exception) end;

procedure countdown( i : integer );
  begin
    if i <= 0 then raise ECxDemoException.Create(
       '"use cx" to get colored exception tracebacks like this!')
    else countdown( i-1 )
  end;

begin countdown(10)
end.
