{$i xpc.inc}
unit build;
interface uses xpc;
  
type
  generic IBuilder<T> = interface
    function GetRoot : T;
    function GetLast : T;
    procedure Append( item : T );
    procedure Branch( item : T );
    procedure Return;
    property root : T read GetRoot;
    property last : T read GetLast;
  end;

implementation

begin
end.
