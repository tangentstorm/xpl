
constructor zMenubar.create(
  x_, y_ : Byte; p : String; e, a : Boolean; head : zChoice );
begin
  tx    := x_;
  ty    := y_;
  width := 0;
  setpal( p );
  zMenu.create( e, a, on, head );
end;
  

procedure zMenubar.handle( ch : Char );
begin
  if ch <> #32 then inherited handle( ch )
  else
    if shortcut( ' ' ) <> nil then
    begin
      setto( shortcut( ' ' ) );
      if submenu <> nil then
      begin
        subactive := true;
        submenu.Reset;
        subactive := submenu.mCurrent <> nil
      end
    end
end;


procedure zMenubar.handlestripped( ch : Char );
begin
  case ch of
    #2 : handle( #32 ); { alt-space }
    #71, #73,           { home, pageup, }
    #79, #81,           { end,  pgdown, }
    kbd.UP, kbd.DOWN :  { up & down }
      if subactive then submenu.handlestripped( ch );
    
    kbd.LEFT :
      begin { go to prev one }
        subactive := false; { turn off submenu now }
        inherited handlestripped( kbd.UP );
        if submenu <> nil then
        begin
          subactive := true;
          submenu.Reset;
          subactive := submenu.mCurrent <> nil
        end
      end;
    
    kbd.RIGHT :
      begin { go to next one }
        subactive := false; { turn off submenu }
        inherited handlestripped( kbd.DOWN );

        { TODO : this pattern seems to repeat over and over... }
        if submenu <> nil then
        begin
          subactive := true;
          submenu.Reset;
          subactive := submenu.mCurrent <> nil
        end
      end;
    
    { and the alt keys: }
    #16 .. #25 :
      if shortcut( alt16to25[ Byte( ch ) - 15] ) <> nil
      then setto( shortcut( alt16to25[ Byte( ch ) - 15 ]));
    
    #30 .. #38 :
      if shortcut( alt30to38[ Byte( ch ) - 29 ]) <> nil
      then setto( shortcut( alt30to38[Byte( ch ) - 29 ]));
    
    #44 .. #50 :
      if shortcut( alt44to50[ Byte( ch ) - 43 ]) <> nil then
        setto( shortcut( alt44to50[Byte( ch ) - 43 ]));
    
  otherwise inherited handlestripped( ch )
  end
end;
  

procedure zMenubar.format( choice : zChoice );
begin
  inherited format( choice );
  choice.y  := ty;
  choice.y2 := ty;
  choice.x  := tx + width;
  width      := width + cwlen( choice.st1 ) - 1;
  choice.x2 := tx + width;
end;

