unit os;

interface

  function thisdir : string;

implementation

  function thisDir : String;
  begin
    GetDir( 0, result );
  end; { thisDir }

begin
end.
