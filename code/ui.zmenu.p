
constructor zMenu.init( esc, alt, usetemp : Boolean; head : pzchoice );
var i : integer;
begin
  mChoices.init;
  mChoices.insert( head );
{
  for i := 0 to high( choices ) do
    begin
      add( choices[ i ]);
      format( choices[ i ]);
    end;

  assert( menu <> nil, 'menu must not be nil' );
  add( menu );
  each := pzchoice( mChoices.first );
  // post-setformat
  while ( each <> nil ) do begin
    format( each );
    each := pzchoice( each.next );
  end;
}
  setonfirst;
  escexits  := esc;
  altexits  := esc;
  usetempscreen := usetemp;
  endloop   := false;
  topmenu   := false;
  subactive := false;
end;

function zMenu.firstChoice : pzChoice;
begin
  result := pzChoice( mChoices.first );
end;

function zMenu.lastChoice : pzChoice;
begin
  result := pzChoice( mChoices.last );
end;

function zMenu.thisChoice : pzChoice;
begin
  result := pzChoice( mCurrent );
end;

procedure zMenu.insert( z : pzchoice );
var
  l : pzchoice;
begin
  mChoices.insert( z );
{
  if z = nil then exit;
  l := z;
  while l^.next <> nil do l := pzchoice( l^.next );
  if mChoices.Last = nil then mLast := l
  else l^.next := mLast^.next;
  last^.next := z;
}
end;


procedure zMenu.add( z : pzchoice );
// var l, t : pzchoice;
begin
  if z = nil then exit;  { has to add in all the nexts! }
  insert( z );
{
    l := z;
    while l^.next <> nil do
begin
      t := l;
      l := pzchoice( l^.next );
      if l <> nil then l^.prev := t;
end;
    if self.last = nil then self.last := l
    else l^.next := self.last^.next;
    first()^.prev := l;
    last^.next := z;
    z^.prev := last;
    last := l;
    }
end;


procedure zMenu.show;
var
  oldIsMV :   Boolean;
  p, q    : zchoice;
  node    : ll.pNode;
  choice  : ui.pZChoice;
begin
  node := mChoices.first;
  repeat
    choice := pzChoice( node );
    choice^.draw( mCurrent = choice );
    node := node^.next;
  until node = mChoices.last;

  {
  p := zchoice( mChoices.first.value );
  while p <> nil do begin
    q := p;
    p := zchoice( mChoices.next( p ) );
    q^.draw( q = mCurrent );
  end;
  }

  if submenu <> nil then submenu^.show;
  begin
    oldIsMV := mvisible;
    if oldIsMV then showmouse( off );
    if oldIsMV then showmouse( on );
  end;
end;


procedure zMenu.seton( z : pzChoice );
begin
{  if ( z <> nil ) and ( z^.on ) then  }
{    mCurrent := mChoices.first.find( z ) as ll.Node;}
  subactive := submenu <> nil;
  if subactive then
    begin
      submenu^.reset;
      subactive := submenu^.mCurrent <> nil
    end
end;


procedure zMenu.setto( z : pzChoice );
begin
  seton( z );
  show;
end;

procedure zMenu.setonfirst;
begin
 if not mChoices.isEmpty then
 begin
   mCurrent := pzChoice( mChoices.first );
   repeat
      if ( mCurrent <> nil) and (thisChoice^.on) then
         mCurrent := pzChoice( mCurrent^.Next );
    until ( mCurrent = pzChoice( mChoices.last )) or ( thisChoice^.on );
 end;
end;

procedure zMenu.settofirst;
begin
  setonfirst;
  show;
end;

procedure zMenu.handle( ch : Char );
begin
  if ( ch = #0 ) then begin
    handlestripped( readkey );
    exit;
  end;

  { hitting esc anywhere will exit }
  if ( ch = kbd.ESC ) then begin
    if escexits then begin
      mCurrent    := nil;
      endloop := true;
    end;
    exit; { quit handling regardless of whether esc exits the menu }
  end;

  { since we're still here.. }
  { just letters, so the submenu handles it }

  if subactive then
  begin
    submenu^.handle( ch );
    endloop := submenu^.endloop;
    submenu^.endloop := false;
  end

  else  { sub <> nil }
    case Ch of
      kbd.ENTER : EndLoop := true;
    otherwise
      if shortcut( ch ) <> nil then
      begin
        setto( shortcut( ch ) );
        if not subactive then endloop := true;
      end;
    end;  { case }
end; { handle }


procedure ZMenu.Handlestripped( ch : Char );
var l : pzchoice;
begin
  if ( subactive ) and ( ch in sArrows ) then
    submenu^.handlestripped( ch )
  else begin
    case Ch of
      kbd.UP :
        begin
          repeat
            if ( mCurrent = pzChoice( mChoices.First )) then
              mCurrent := pzChoice( mChoices.Last )
            else
              mCurrent := pzChoice( mCurrent^.prev )
          until ( thisChoice^.enabled ) or ( mCurrent = pzChoice( mChoices.First ));
          show;
        end;

      kbd.LEFT :
        if subactive then
          if submenu^.subactive then
            submenu^.handlestripped( ch )
          else begin
              subactive := no;
              submenu^.mCurrent := nil
            end;

      kbd.DOWN :
        begin
          repeat
            if ( mCurrent = pzChoice( mChoices.Last )) then
              mCurrent := pzChoice( mChoices.First )
            else if mCurrent <> nil then
              mCurrent := pzChoice( mCurrent^.next )
          until ( thisChoice^.enabled ) or ( mCurrent = pzChoice( mChoices.Last ));
          if mCurrent = nil then halt;
          show;
        end;

      kbd.RIGHT :
        if thisChoice^.sub <> nil then
        begin
          subactive := true;
          submenu^.Reset;
          subactive := submenu^.FirstChoice <> nil; { TODO .FirstEnabled ? }
        end;

      #71, #73 : { home }
        begin
          mCurrent := pzChoice( mChoices.First );
          if not thisChoice^.enabled then
             handlestripped( kbd.DOWN );
        end;

      #79, #81 : { end }
        begin
          mCurrent := pzChoice( mChoices.Last );
          if not thisChoice^.enabled then
             handlestripped( kbd.UP );
        end;
    otherwise handle( ch );
    end;
  end; { case }
end; { handlestripped }

procedure zMenu.Reset;
begin
  if not mChoices.isEmpty then
  begin
    setonfirst;
    repeat
      mCurrent := pzChoice( mCurrent^.next );
    if thisChoice^.sub <> nil then submenu^.Reset
    until mCurrent = pzChoice( mChoices.last );
    setonfirst;
    subactive := submenu <> nil;
    endloop   := false;
  end;
end;

procedure zMenu.domousestuff;
var node : ll.pNode; choice : pzchoice;
begin
  if not mpresent then exit;
  getmpos;

  if submenu <> nil then
  begin
    submenu^.domousestuff;
    endloop := submenu^.endloop;
    submenu^.endloop := false;
  end;

  if endloop then exit;

  if ( ms.state = 2 ) then
  begin
    repeat getmpos until ( ms.state and 2 = 0 );
    handle( kbd.ESC );
  end
  else { no right click, procede as usual }
  begin
    node := mChoices.first;
    while node <> nil do
    begin
      choice := pzChoice( node );
      node := node^.next;
      if ( choice^.on ) and ( choice^.pressed ) then
      begin
        setto( choice );
        if choice^.click then handle( kbd.ENTER );
      end;
      show;
    end { clicked }
  end { else }
end; { domousestuff }


procedure zMenu.dowhilelooping;
begin
  { this is to allow the menu to update clocks or screen savers, }
  { or to allow other controls to be onscreen at the same time.. }
  { multi-tasking in other words.. }
end;

procedure zMenu.format( choice : pzchoice );
{ virtual procedure }
begin
  if choice^.st2 = ''
  then choice^.st2 := invertstr( choice^.st1 )
  else choice^.st2 := invertstr( choice^.st2 );

  if choice^.st1 <> ''
  then choice^.st1 := normalstr( choice^.st1 );
end;

function zMenu.normalstr( s : String ) : String;
begin
  result := '|!' + zbmb + '|' + zbmt + s;
end;

function zMenu.invertstr( s : String ) : String;
begin
  result := '|!' + zbhb + '|' + zbhf + s;
end;

function zMenu.submenu : pzMenu;
begin
  if thisChoice^.sub <> nil
  then result := pzMenu( thisChoice^.sub )
  else result := nil;
end;


function zMenu.shortcut( ch : Char ) : pzchoice;
  function match_shortcut( node : ll.pNode ): boolean;
  begin
    result := pzchoice( node )^.sc = ch
  end;
begin
  { TODO : find should return the content, not the node }

  result := pzchoice( mChoices.find( match_shortcut ));
  if Assigned( result ) and not result^.enabled then
    result := nil
end;

function zMenu.valuecut( v : Word ) : pzChoice;
  function match_valcut( node : ll.pNode ): boolean;
  begin
    result := pzchoice( node )^.v = v;
  end;
begin
  result := pzChoice( mChoices.find( match_valcut ));
  if Assigned( result ) and not result^.enabled then
    result := nil;
end;



function zMenu.value : Byte;
begin
  if mCurrent = nil then
    result := 255
  else if submenu <> nil then
    result := submenu^.value
  else
    result := thisChoice^.v;
end;


function zMenu.get : Byte;
var
  ta : Byte;
  mv : Boolean;
begin
  ta := crt.textattr;
  if mChoices.isEmpty then
    result := 0
  else
    begin
      topmenu := true;
      mv      := mvisible;
      if mv then showmouse( off );
      if mv then showmouse( on );
      endloop := false;
      Reset;
      if mCurrent = nil then
        mCurrent := pzChoice( mChoices.First );
      show;
      repeat
        dowhilelooping;
        if (( shiftstate and altpressed ) <> 0 ) then
        begin
          repeat until ( shiftstate and altpressed ) = 0;
          if ( altexits ) and ( not keypressed ) then handle( kbd.ESC );
        end;
        if keypressed then handle( readkey ) else domousestuff
      until endloop;
      get     := value;
      topmenu := false;
      mv      := mvisible;
      if mv then showmouse( off );
      if mv then showmouse( on );
      crt.textAttr := ta;
  end;
end;
