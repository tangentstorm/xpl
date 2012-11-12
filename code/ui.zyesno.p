
{ TODO: this should just be an alternate constructor for ztoggle }

constructor zyesno.init( a, b, tc : Byte; startval : Boolean );
begin
  ztoggle.init( a, b, tc, 'Yes', 'No ', startval );
end;

