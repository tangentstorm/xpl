{$i xpc.inc}
unit cx; { colorized exceptions }
interface uses cw, sysutils;

  function stacktrace( e :  exception ) : string;

implementation

  // mostly taken from:
  // http://wiki.lazarus.freepascal.org/Logging_exceptions#Dump_current_call_stack
  function stacktrace( e :  exception ) : string;
    var
      i	     : integer;
      frames : ppointer;
  begin
    result := '|K';
    if e <> nil then result := e.classname + ': |R' + e.message + lineending;
    result += '|c' + backtracestrfunc( exceptaddr );
    frames := exceptframes;
    for i := 0 to exceptframecount - 1 do begin
      if odd( i ) then result += '|c' else result += '|B';
      result += lineending + backtracestrfunc( frames[ i ]);
    end;
  end; { stacktrace }

  // adapted from http://wiki.freepascal.org/Logging_exceptions#Unit_SysUtils
  procedure on_error
   ( obj	: TObject;
     Addr	: Pointer;
     FrameCount	: Longint;
     Frames	: PPointer );
  begin
    cw.cwrite( stacktrace( obj as exception ))
  end; { on_error }

initialization
  system.ExceptProc := @on_error;
end.
