{$mode delphi}{$i xpc}
unit ucomb;
interface uses xpc, num, math, sysutils;

type
  TComboCursor = class (TObject)
    _n, _k,
    _limit : cardinal;
    _bases,
    _digits : array of cardinal;
  public
    constructor Create(n,k : cardinal); { k!n or "n choose k" }
    destructor Destroy; override;
    function GetBase( i : cardinal ): cardinal;
    function GetDigit( i : cardinal ): cardinal;
    function GetLength : cardinal;
    function GetValue : cardinal;
    function ToStr:TStr;
    procedure MoveNext;
    property bases[ i : cardinal ] : cardinal read GetBase;
    property digit[ i : cardinal ] : cardinal read GetDigit;
    property limit : cardinal read _limit;
    property length : cardinal read GetLength;
    property value : cardinal read GetValue;
  end;

implementation

constructor TComboCursor.Create(n,k : cardinal);
  var i,b : cardinal;
  begin
    inherited Create;
    _limit := num.choose(n,k); _n := n; _k := k; b:=n-k+1;
    SetLength(_bases,k);
    SetLength(_digits,k);
    if (k > 0) and (n > k) then
      for i := 0 to k-1 do begin
        // fractional bases
        _bases[i] := b; inc(b);
        _digits[i] := 0;
      end
  end;

destructor TComboCursor.Destroy;
  begin inherited
  end;


function TComboCursor.GetBase( i : cardinal ): cardinal;
  begin result := _bases[ i ]
  end;

function TComboCursor.GetDigit( i : cardinal ): cardinal;
  begin result := _digits[ i ]
  end;

function TComboCursor.GetLength : cardinal;
  begin result := system.Length(_bases)
  end;

function TComboCursor.GetValue : cardinal;
  var x : extended = 0; i : cardinal;
  begin
    writeln;
    if _k = 0 then ok
    else begin
      x := _digits[_k-1];
      if _k > 1 then
	for i := _k-2 downto 0 do x +=  _digits[ i ] * (_k-i);
    end;
    result := ceil(x);
  end;

function TComboCursor.ToStr:TStr;
  var i : cardinal;
  begin
    writestr(result, Format('TComboCursor(%d,%d):[ ', [_n,_k]));
    for i := 0 to _k-1 do writestr(result, result, _digits[i], ' ');
    writestr(result, result, ']');
  end;

procedure TComboCursor.MoveNext;
  var i : cardinal; done : boolean;
  begin
    i := _k;  // start just after least signficant digit
    if length > 0 then
      repeat
        dec(i);
        inc(_digits[i]);
        if (_digits[i] < _bases[i]) then
          done := true
        else begin
          done := false;
          _digits[i] := 0;
          if i >0 then ok else i := _k; // TODO: mention carry?
        end;
      until done
  end;

end.
