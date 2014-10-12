{$mode delphi}{$i xpc}
unit ucomb;
interface uses xpc, num;

type
  TComboCursor = class (TObject)
    limit : cardinal;
  public
    constructor Create(n,k : cardinal); { k!n or "n choose k" }
    destructor Destroy; override;
  end;

implementation

constructor TComboCursor.Create(n,k : cardinal);
  begin
    inherited Create;
    self.limit := choose(n,k);
  end;

destructor TComboCursor.Destroy;
  begin inherited
  end;

end.
