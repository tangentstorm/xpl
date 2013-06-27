unit dy; // dynamic type support
interface 
uses variants;
	  
  function cons(head, tail : variant):variant;

implementation

  function cons(head,tail:variant):variant;
  begin
    result := VarArrayCreate([0,1], varVariant);
  end;
