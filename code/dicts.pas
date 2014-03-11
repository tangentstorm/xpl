// forth-style dictionary with python-style interface.
//
// forth-style means that we use strings for all keys,
// and perform a straightforward linear search.
//
// the keys are hashed to (hopefully) speed up comparisons.
// but there isn't actually a hash table inside.
//
// we avoid collisions by double-checking the cached string
// only when the hashes match.

{$mode delphiunicode}{$i xpc.inc}
unit dicts;
interface uses xpc, sysutils, variants;

function JavaHash( const s : TStr ) : int32;

type
  GEntry<T> = record
    hash  : int32;
    key	  : TStr;
    value : T;
  end;
  THashFunction = function( const s : TStr ): int32;
  GDict<T> = class
    protected
      _items : array of GEntry<T>;
      _hashFn : THashFunction;
      function HasKey(const key : TStr; out i: int32) : boolean;  overload;
      function HasKey(const key : TStr; out i, h: int32) : boolean;  overload;
      function Append(const key : TStr; const hash: int32; const value : T) : T;
    public
      hashFn : THashFunction;
      constructor Create;
      function Get( const key : TStr; default : T ) : T;
      function SetDefault( const key : TStr; default : T ) : T;
      function HasKey( const key : TStr ) : boolean; overload;
      function GetItem( const key : TStr ) : T;
      procedure SetItem( const key : TStr; const value : T );
      property Items[ s : TStr ] : T read GetItem write SetItem; default;
    end;
  TStrDict = GDict<TStr>;
  TIntDict = GDict<Int32>;
  TVarDict = GDict<variant>;
  EKeyError = class (Exception) end;


implementation

{ this is the algorithm java uses }
function JavaHash( const s : TStr ) : int32;
  var i : int32;
  begin
    result := 0;
    for i := 1 to length( s ) do result := int32(31 * result + ord( s[ i ]));
  end;

constructor GDict<T>.Create;
  begin
    inherited Create;
    _hashFn := JavaHash;
  end;

{ lookup the string, leaving i := the index if found }
function GDict<T>.HasKey( const key : TStr; out i, h : int32 ) : boolean;
  var len : int32; found : boolean = false;
  begin
    h := _hashFn( key ); len := length( _items );
    i := 0;
    if len > 0 then
      repeat
	found := ( _items[ i ].hash = h ) and
		 ( _items[ i ].key = key );
	if not found then inc( i );
      until found or (i = len);
    result := found
  end;

function GDict<T>.HasKey(const key : TStr; out i : int32) : boolean; inline;
  var h : int32;
  begin
    result := self.HasKey(key, i, h);
  end;

function GDict<T>.HasKey( const key : TStr ) : boolean; inline;
  var i,h : int32;
  begin
    result := self.HasKey(key, i, h);
  end;
 

{ public GDict<T> interface }

function GDict<T>.Get( const key : TStr; default : T ) : T;
  var i : int32;
  begin
    if self.HasKey( key, i ) then result := _items[ i ].value
    else result := default;
  end;
  
function GDict<T>.GetItem( const key : TStr ) : T;
  var i : int32;
  begin
    if self.HasKey( key, i ) then result := _items[ i ].value
    else raise EKeyError.Create(Utf8Encode( key ));
  end;
  
function GDict<T>.Append( const key : TStr; const hash : int32; const value : T) : T;
  var i : int32;
  begin
    i := length( _items );
    SetLength( _items, i + 1 );
    _items[ i ].key := key;
    _items[ i ].hash := hash;
    _items[ i ].value := value;
    result := value;
  end;
  
function GDict<T>.SetDefault( const key : TStr; default : T ) : T;
  var i, h : int32;
  begin
    if self.HasKey( key, i, h ) then result := _items[ i ].value
    else result := Append(key, h, default);
  end;

procedure GDict<T>.SetItem( const key : TStr; const value : T );
  var i, h : int32;
  begin
    if self.HasKey( key, i, h ) then _items[ i ].value := value
    else Append( key, h, value );
  end;


initialization
end.
