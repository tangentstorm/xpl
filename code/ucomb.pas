{$mode delphi}{$i xpc}
unit ucomb;
interface uses xpc, num;

type
  TComboCursor = class (TObject)
    _limit : cardinal;
    _bases,
    _digits : array of cardinal;
  public
    constructor Create(n,k : cardinal); { k!n or "n choose k" }
    destructor Destroy; override;
    function GetBase( i : cardinal ): cardinal;
    function GetLength : cardinal;
    property bases[ i : cardinal ] : cardinal read GetBase;
    property limit : cardinal read _limit;
    property length : cardinal read GetLength;
  end;

implementation

function TComboCursor.GetBase( i : cardinal ): cardinal;
  begin result := _bases[ i ]
  end;

function TComboCursor.GetLength : cardinal;
  begin result := system.Length(_bases)
  end;

constructor TComboCursor.Create(n,k : cardinal);
  var i : cardinal;
  begin
    inherited Create;
    _limit := num.choose(n,k);
    SetLength(_bases,k); SetLength(_digits,k);
    if (k > 0) and (n > k) then begin
      for i := 0 to k-1 do _bases[i] := n-i;
      for i := 0 to k-1 do _digits[i] := 0;
    end
  end;

destructor TComboCursor.Destroy;
  begin inherited
  end;

end.
