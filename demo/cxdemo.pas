program cxdemo;
uses xpc, cx, sysutils;

type
  ECxDemoException = class (Exception) end;

procedure outer;
  procedure inner;
    begin raise ECxDemoException.Create(
       '"use cx" to get colored exception tracebacks like this!');
    end;
  begin inner;
  end;

begin outer
end.
