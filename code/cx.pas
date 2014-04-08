// cx : colored exception tracebacks.
//
// based on code from:
// http://wiki.lazarus.freepascal.org/Logging_exceptions
//
// simply adding this unit to your 'uses' statement will
// install the colored traceback behavior.
//
{$mode delphiunicode}{$i xpc.inc}
unit cx; { colorized exceptions }
interface uses xpc, kvm, cw, ustr, sysutils;

  // the formatting routine is made public
  // for the test runner (../tests/run-tests.pas)
  function stacktrace( e : exception ) : TStr;

implementation

// this returns a TStr rather than printing directly with
// cwriteln because the test runner hides stack traces.
function stacktrace( e : exception ) : TStr;
  var i : integer; frames : ppointer;
  begin
    result := '|K';
    if e <> nil then { show the exception message }
      result += '' + a2u(e.classname) + ': |R' + a2u(e.message) + ^M;
    { top level address }
    result += '|c' + a2u(backtracestrfunc( exceptaddr ));
    { backtrace }
    frames := exceptframes;
    for i := 0 to exceptframecount - 1 do begin
      if odd( i ) then result += '|c' else result += '|B';
      result += ^M + a2u(backtracestrfunc( frames[ i ]));
    end;
    result += '|w';
  end; { stacktrace }

procedure on_error
   ( obj	: TObject;
     Addr	: Pointer;
     FrameCount	: Longint;
     Frames	: PPointer );
  begin
    kvm.popterms;
    cw.cwrite('|!k|w');
    cw.cwrite(stacktrace( obj as exception ));
    kvm.newline;
  end; { on_error }

initialization
  system.ExceptProc := @on_error;
end.
