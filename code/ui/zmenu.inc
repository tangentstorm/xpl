
constructor zMenu.create( esc, alt, usetemp : Boolean; head : zchoice );
begin
  mChoices := choicelist.create;
  mChoices.append( head );
  mCurrent := mChoices.MakeCursor;
  setonfirst;
  escexits  := esc;
  altexits  := esc;
  usetempscreen := usetemp;
  endloop   := false;
  topmenu   := false;
  subactive := false;
end;

function zMenu.firstChoice : zChoice;
begin
  result := zChoice( mChoices.first );
end;

function zMenu.lastChoice : zChoice;
begin
  result := zChoice( mChoices.last );
end;

function zMenu.thisChoice : zChoice;
begin
  result := mCurrent.value
end;

procedure zMenu.insert( z : zchoice );
begin
  mChoices.insert( z );
end;

procedure zMenu.add( z : zchoice );
begin
  if z = nil then exit;  { has to add in all the nexts! }
  mchoices.append( z );
end;

procedure zMenu.Render;
var
  oldIsMV : Boolean;
  choice  : ui.zChoice;
  cur	  : choicecursor;
begin
  cur  := mChoices.MakeCursor;
  while cur.next( choice ) do begin
    choice.draw( mCurrent.index = cur.index );
  end;
  if submenu <> nil then submenu.Render;
  begin
    oldIsMV := mvisible;
    if oldIsMV then mou.hide;
    if oldIsMV then mou.show;
  end;
end;

procedure zMenu.seton( z : zChoice );
begin
  subactive := submenu <> nil;
  if subactive then
    begin
      submenu.reset;
      subactive := submenu.mCurrent <> nil
    end
end;

procedure zMenu.setto( z : zChoice );
begin seton( z ); smudge;
end;

procedure zMenu.setonfirst;
begin
 if not mChoices.IsEmpty then
 begin
   mCurrent.ToTop;
   while not ( thischoice.on or mcurrent.AtEnd ) do mcurrent.MoveNext
 end;
end;

procedure zMenu.settofirst;
begin setonfirst; smudge;
end;

procedure zMenu.handle( ch : Char );
begin
  if ( ch = #0 ) then handlestripped( readkey )
  else begin

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
      submenu.handle( ch );
      endloop := submenu.endloop;
      submenu.endloop := false;
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
      end  { case }
  end
end; { handle }


procedure ZMenu.Handlestripped( ch : Char );
  var old : cardinal;
begin
  if ( subactive ) and ( ch in sArrows ) then
    submenu.handlestripped( ch )
  else begin
    case Ch of
      kbd.UP :
        begin
	  //  todo: move wrapping to list.cursor
	  old := mCurrent.index;
	  repeat
	    if mCurrent.AtTop then mCurrent.ToEnd
	    else mCurrent.MovePrev;
	  until thisChoice.enabled or ( mCurrent.index = old );
          smudge;
        end;

      kbd.LEFT :
        if subactive then
          if submenu.subactive then
            submenu.handlestripped( ch )
          else begin
              subactive := no;
              submenu.mCurrent.reset;
            end;

      kbd.DOWN :
	begin
	  old := mCurrent.index;
	  //  todo: move wrapping to list.cursor
	  repeat
	    if mCurrent.AtEnd then mCurrent.ToTop
	    else mCurrent.MoveNext;
	  until thisChoice.enabled or ( mcurrent.index = old );
          smudge;
        end;

      kbd.RIGHT :
        if thisChoice.sub <> nil then
        begin
          subactive := true;
          submenu.Reset;
          subactive := submenu.FirstChoice <> nil; { TODO .FirstEnabled ? }
        end;

      #71, #73 : { home }
        begin
          mCurrent.ToTop;
          if not thisChoice.enabled then
             handlestripped( kbd.DOWN );
        end;

      #79, #81 : { end }
        begin
          mCurrent.ToEnd;
          if not thisChoice.enabled then
             handlestripped( kbd.UP );
        end;
    otherwise writeln(' you pressed: $', hex(ord(ch)))
    end;
  end; { case }
end; { handlestripped }

procedure zMenu.Reset;
begin
  if not mChoices.IsEmpty then
  begin
    setonfirst;
    repeat
      mCurrent.MoveNext;
      if thisChoice.sub <> nil then submenu.Reset
    until mCurrent.AtEnd;
    setonfirst;
    subactive := submenu <> nil;
    endloop   := false;
  end;
end;

procedure zMenu.domousestuff;
var cur : choicecursor; choice : zchoice;
begin
  if not mpresent then exit;
  getmpos;

  if submenu <> nil then
  begin
    submenu.domousestuff;
    endloop := submenu.endloop;
    submenu.endloop := false;
  end;

  if endloop then exit;

  if ( mou.state = 2 ) then
  begin
    repeat getmpos until ( mou.state and 2 = 0 );
    handle( kbd.ESC );
  end
  else { no right click, procede as usual }
  begin
    cur := mchoices.MakeCursor;
    while cur.next( choice ) do
    begin
      if ( choice.on ) and ( choice.pressed ) then
      begin
        self.setto( choice );
        if choice.click then handle( kbd.ENTER );
      end;
      smudge;
    end { clicked }
  end { else }
end; { domousestuff }


procedure zMenu.dowhilelooping;
begin
  { this is to allow the menu to update clocks or screen savers, }
  { or to allow other controls to be onscreen at the same time.. }
  { multi-tasking in other words.. }
end;

procedure zMenu.format( choice : zchoice );
{ virtual procedure }
begin
  if choice.st2 = ''
  then choice.st2 := invertstr( choice.st1 )
  else choice.st2 := invertstr( choice.st2 );

  if choice.st1 <> ''
  then choice.st1 := normalstr( choice.st1 );
end;

function zMenu.normalstr( s : String ) : String;
begin
  result := '|!' + zbmb + '|' + zbmt + s;
end;

function zMenu.invertstr( s : String ) : String;
begin
  result := '|!' + zbhb + '|' + zbhf + s;
end;

function zMenu.submenu : zMenu;
begin
  if thisChoice.sub <> nil
  then result := zMenu( thisChoice.sub )
  else result := nil;
end;


function zMenu.shortcut( ch : Char ) : zchoice;
  function match_shortcut( choice : zchoice ): boolean;
  begin
    result := choice.sc = ch
  end;
begin
  { TODO : find should return the content, not the node }

  result := mChoices.find( match_shortcut );
  if Assigned( result ) and not result.enabled then
    result := nil
end;

function zMenu.valuecut( v : Word ) : zChoice;
  function match_valcut( node : zchoice ): boolean;
  begin
    result := zchoice( node ).v = v;
  end;
begin
  result := zChoice( mChoices.find( match_valcut ));
  if Assigned( result ) and not result.enabled then
    result := nil;
end;



function zMenu.value : Byte;
begin
  if mCurrent = nil then
    result := 255
  else if submenu <> nil then
    result := submenu.value
  else
    result := thisChoice.v;
end;


function zMenu.get : Byte;
var mv : Boolean;
begin
  if mChoices.IsEmpty then
    result := 0
  else
    begin
      topmenu := true;
      mv      := mvisible;
      if mv then mou.hide;
      if mv then mou.show;
      endloop := false;
      Reset;
      if mCurrent.value = nil then mCurrent.ToTop;
      smudge;
      repeat
        dowhilelooping;
        if (( shiftstate and altpressed ) <> 0 ) then
        begin
          repeat until ( shiftstate and altpressed ) = 0;
	  if ( altexits ) and ( not kbd.keypressed ) then handle( kbd.ESC );
        end;
	if kbd.keypressed then handle( readkey ) else domousestuff
      until endloop;
      get     := value;
      topmenu := false;
      mv      := mvisible;
      if mv then mou.hide;
      if mv then mou.show;
  end;
end;
