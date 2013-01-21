// forth-style dictionary with hashmap
//
// this version uses strings for all keys.
// lookup is done with a simple linear search for now,
// avoiding collisions by double-checking the cached string

{$i xpc.inc}
unit di;
interface uses xpc, li;

  type
    generic dict<v> = class
      public
        function get( const key : string; default : v ) : v;
        procedure put( const key : string; var value : v );
      private
        items : array of record
                           hash  : integer;
                           key   : string;
                           value : v;
		         end;
      function has_i( const key : string; var i: int32 ) : boolean;
      function hash( const s : string ): integer;
    end;
    stringdict = specialize dict<string>;


implementation

  { this is the algorithm java uses }
  function dict.hash( const s : string ) : integer;
    var i : integer;
  begin
    hash := 0;
    for i := 1 to length( s ) do hash := 31 * hash + ord( s[ i ]);
  end;

  { lookup the string, leaving i := the index if found }
  function dict.has_i( const key : string; var i : int32 ) : boolean;
    var h, len : integer; found : boolean = false;
  begin
    h := hash( key ); i := -1; len := length( self.items );
    repeat
      inc( i );
      found := ( self.items[ i ].hash = h ) and
	       ( self.items[ i ].key = key );
    until found or ( i = len );
    result := found
  end;


  { public dict interface }

  function dict.get( const key : string; default : v ) : v;
    var i : int32;
  begin
    if self.has_i( key, i ) then result := self.items[ i ].value
    else result := default;
  end;

  procedure dict.put( const key : string; var value : v );
    var i : int32;
  begin
    if self.has_i( key, i ) then
      self.items[ i ].value := value
    else begin
      i := length( self.items );
      setlength( self.items, i + 1 );
      self.items[ i ].value := value;
    end
  end;


begin
end. { unit }
