
{ TODO: this should just be an alternate constructor for ztoggle }

constructor zyesno.create( a, b, tc : Byte; startval : Boolean );
begin
  ztoggle.create( a, b, tc, 'Yes', 'No ', startval );
end;

