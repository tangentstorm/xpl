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



procedure run( test_name : string; to_test : testcase );
var result : outcome = pass;  p : problem;  e : exception;
begin
  //  chk.reset;
  try to_test
  except
    on Exception do begin
      e := ExceptObject as exception;
      if e is EAssertionFailed then result := fail
      else result := err;
      // setlength( p.error,
      //   ExceptionErrorMessage( e, ExceptAddr, @p.error[1], 255 ));
      p.error := e.message;
      p.test_name := test_name;
      p.result := result;
      setlength( problems, length( problems ) + 1 );
      problems[ length( problems ) - 1 ] := p;
    end;
  end;
  case result of
    pass : begin inc( passed ); {c}write( {'|g',} 'o' ) end;
    fail : begin inc( failed ); {c}write( {'|y',} '!' ) end;
    err  : begin inc( broken ); {c}write( {'|r',} 'X' ) end;
  end;
end;

procedure report;
  var total : integer; p : problem;
begin
  //cwriteln( '|K');
  writeln;
  {c}writeln('----------------------------------------------' );
  writeln;
  for p in problems do begin
    {c}writeln( {'|K',} '[ ',  { colors[ p.result ] + }
	       p.test_name, {'|K',}  ' ] ');
    writeln( {'|w',} p.error );
    writeln;
  end;
  //cwriteln( '|K');
  {c}writeln('----------------------------------------------' );
  total := passed + failed + broken;
  {c}writeln( {'|K',} 'results: ', {'\w',} total, ' tests run. ',
	   passed, ' tests passed; ',
           failed, ' failed; ',
           broken, ' broken.' );
  writeln;
end;


begin
  setup;
  {$i run-tests.run }
  report;
end.
