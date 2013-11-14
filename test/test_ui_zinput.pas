{$i test_ui_zinput.def }{$h+}
implementation uses xpc, ui;

  var inp : ui.ZInput;

procedure setup;
  begin
    inp := ui.ZInput.Create(Nil);
  end;

procedure test_create;
  begin
    chk.equal( inp.value, '' );
    chk.equal( inp.cpos, 0 );
  end;

procedure test_insert;
  begin
    chk.equal( inp.cpos, 0 );
    inp.insert( 'a' );
    chk.equal( inp.cpos, 1 );
    chk.equal( inp.value, 'a' );
    inp.insert( 'b' );
    chk.equal( inp.cpos, 2 );
    chk.equal( inp.value, 'ab' );
  end;

procedure test_backspace;
  begin
    chk.equal( inp.cpos, 0 );
    inp.backspace;
    chk.equal( inp.cpos, 0 );
    chk.equal( inp.value, '' );

    inp.insert( 'a' );
    chk.equal( inp.cpos, 1 );
    inp.backspace;
    chk.equal( inp.cpos, 0 );
    chk.equal( inp.value, '' );

    inp.insert( 'b' );
    chk.equal( inp.cpos, 1 );
    inp.insert( 'c' );
    chk.equal( inp.cpos, 2 );
    chk.equal( inp.value, 'bc' );


    inp.backspace;
    chk.equal( inp.cpos, 1 );
    chk.equal( inp.value, 'b' );

    inp.backspace;
    chk.equal( inp.cpos, 0 );
    chk.equal( inp.value, '' );
  end;

procedure test_str_to_end;
  begin
    //  movecursor should probably be renamed to 'setcursor' (or just use a property)
    inp.work := 'hello world';
    chk.equal( inp.str_to_end, 'hello world' );
    inp.movecursor( 6 );
    chk.equal( inp.str_to_end, 'world' );
    inp.movecursor( 1 );
    chk.equal( inp.str_to_end, 'ello world' );
  end; { test_str_to_end }


procedure test_movement;
  begin
    inp.to_start; chk.equal( inp.cpos, 0 );
  end;

type
  TStringCatcher = class
    _s : string;
    procedure SetValue(s:string);
    property value : string read _s write SetValue;
  end;

procedure TStringCatcher.SetValue(s : string);
  begin
    _s := s
  end;

procedure test_OnAccept;
  var s : TStringCatcher;
  begin
    s := TStringCatcher.Create;
    s.value := '';
    inp.value := 'hello world';
    inp.Accept; // make sure default handler doesn't crash.
    inp.OnAccept := @s.SetValue;
    inp.Accept;
    chk.equal( s.value, 'hello world' );
  end;

end.
