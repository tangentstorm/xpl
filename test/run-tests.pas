{$i xpc.inc}
program run_tests;
uses cw, xpc, sysutils {$i run-tests.use }; // includes test_*.pas

type
  outcome  = ( pass, fail, err );
  problem  = record
	       test_name : string;
	       result	 : outcome;
	       error	 : string;
	     end;
  testcase = procedure;
const
  colors : array[ outcome ] of string[ 2 ] = ( '|g', '|y', '|r' );

var
  overall   : outcome;
  passed,
  failed,
  broken    : integer;
  unit_name : string;
  problems  : array of problem;

procedure setup;
begin
  setlength( problems, 0 );
  writeln( 'running tests' );
  writeln;
end;



// mostly taken from:
// http://wiki.lazarus.freepascal.org/Logging_exceptions#Dump_current_call_stack
function stacktrace( e :  exception ) : string;
  var
    i	   : integer;
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
  
procedure run( test_name : string; to_test : testcase );
var result : outcome = pass;  p : problem;  e : exception;
begin
  //  chk.reset;
  try to_test
  except
    on exception do begin
      e := ExceptObject as exception;
      if e is EAssertionFailed then result := fail
      else result := err;
      p.error := stacktrace( e );
      p.test_name := test_name;
      p.result := result;
      setlength( problems, length( problems ) + 1 );
      problems[ length( problems ) - 1 ] := p;
    end;
  end;
  case result of
    pass : begin inc( passed ); cwrite( '|g.' ) end;
    fail : begin inc( failed ); cwrite( '|y!' ) end;
    err  : begin inc( broken ); cwrite( '|rX' ) end;
  end;
end;

procedure report;
  var total : integer; p : problem;
begin
  if length( problems ) > 0 then begin
    cwriteln( '|K');
    writeln('----------------------------------------------' );
    writeln;
  end;

  for p in problems do begin
    cwriteln( '|K[ ' + colors[ p.result ] + p.test_name + ' |K]');
    cwriteln( '|w' + p.error );
  end;
  cwriteln( '|K');
  writeln('----------------------------------------------' );
  total := passed + failed + broken;
  cwriteln([ '|K', 'results: ', '|w', total, ' tests run. ',
	     passed, ' tests passed; ',
             failed, ' failed; ',
             broken, ' broken.' ]);
  writeln;
end;


begin
  setup;
  {$i run-tests.run }
  report;
end.
