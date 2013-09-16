{ lined: line editor for pascal by tangenstorm
  inspired by linenoise by antirez. }
{$i xpc.inc}{$mode objfpc}{$h+}
unit lined;
interface uses classes, sysutils, kvm, kbd;

  type
    StringList	   = class ( TStringList )
      procedure load( path : string );
      procedure save( path : string );
    end;
    HistoryList	   = StringList;
    Completions	   = StringList;
    completion_cbk = procedure( const buf: string; var comps : Completions );

    LineEditor	   = class
      history      : StringList;
      on_complete  : completion_cbk;
      constructor create;
      function flush: string;
      function input( const pmt : string; var res : string ) : boolean;
      procedure refresh;
      procedure backspace;
      procedure delete_char;
      procedure transpose;
      procedure kill_prev_word;
      procedure complete_line( var buf : string );
      procedure browse_history( new_index : integer );
      procedure reset;
      procedure step;
    private
      _done      : boolean;
      hist_index : integer;
      plen, len, cur : integer;
      keep : boolean;
      pmt, buf : string;
      procedure escapes;
      procedure set_prompt( const s :  string );
    public
      property prompt : string read pmt write set_prompt;
      property done : boolean read _done;
    end;

  const
    MAX_LINE_SIZE = 1024;
    unsupported	: array[ 1..3 ] of string
		  = ( '', 'dumb', 'cons25' );
    force_plain	  = false;

  var
    ed	: LineEditor;

  function prompt( const msg : string; var buf : string ) : boolean;


implementation

  constructor LineEditor.Create;
  begin
    history := StringList.create;
    hist_index := 0;
    self.reset;
  end;

  procedure LineEditor.set_prompt( const s : string );
  begin
    self.pmt := s;
    self.plen := length(s);
  end;

  procedure LineEditor.refresh;
    var ch: char; ofs : shortint = -1; i : integer = 0;
  begin
    kvm.gotoxy( 0, kvm.wherey ); // left edge
    write( pmt );
    for ch in buf do begin
      inc( i );
      if ( ch < ' ' ) and not ( ch = ^J ) then begin
	kvm.fg('g');
	write( '^', chr( ord( '@' ) + ord( ch )));
	if i <= cur then inc( ofs );
	kvm.fg('w');
      end
      else write( ch )
    end;
    kvm.clreol; // write( #27, '[0G', #27, '[', plen + cur , 'C' );
    kvm.gotoxy( plen + cur + ofs, kvm.wherey );
  end;

  procedure LineEditor.backspace;
  begin
    if ( cur > 1 ) and ( len > 0 ) then begin
      dec( cur ); dec( len );
      delete( buf, cur, 1 );
    end;
  end;

  procedure LineEditor.delete_char; inline;
  begin
    if cur <= len then begin
      dec( len );
      delete( buf, cur, 1 );
    end;
  end;

  procedure LineEditor.transpose;
    var ch : char;
  begin
    if cur > 1 then begin
      if cur >= len then cur := len;
      ch := buf[ cur - 1 ];
      buf[ cur - 1 ] := buf[ cur ];
      buf[ cur ] := ch;
      inc( cur );
      if cur >= len then cur := len + 1;
    end;
  end;

  procedure LineEditor.kill_prev_word;
    var old, dif : integer;
  begin
    old := cur;
    while ( cur > 1 ) and ( buf[ cur - 1 ] <= ' ' ) do dec( cur );
    while ( cur > 1 ) and ( buf[ cur - 1 ]  > ' ' ) do dec( cur );
    dif := old - cur + 1;
    delete( buf, cur, dif );
    len := length( buf );
  end;

  procedure LineEditor.complete_line( var buf : string );
  begin
    //  todo
  end;

  procedure LineEditor.browse_history( new_index : integer );
  begin

    // clamp:
    hist_index := new_index;
    if hist_index < 0 then hist_index := 0;
    if hist_index > history.count then hist_index := history.count;

    // special case for new input at end of list:
    if hist_index = history.count
      then buf := ''
    else buf := history[ hist_index ];
    len := length( buf );

    // cursor tracking:
    //  maybe remember column for hopping past short lines?
    if cur > len then cur := len + 1;
  end;


  procedure LineEditor.escapes;
  begin
    insert( #27, buf, cur );
  end;

  procedure LineEditor.step;
    var ch : char;
  begin
    refresh; ch := kbd.readkey;
    case ch of
      ^A : cur := 1;
      ^B : begin dec( cur ); if cur = 0 then cur := 1 end;
      ^C : begin keep := false; _done := true end;
      ^D : if (len > 0) or (cur > 1) then delete_char
	   else begin keep := false; _done := true end;
      ^E : cur := len + 1;
      ^F : begin inc( cur ); if cur > len then cur := len + 1 end;
      ^G : ;
      ^H : backspace;
      ^I : complete_line( buf );
      ^J : _done := true;
      ^K : begin len := cur - 1; setlength( buf, len ) end;
      ^L : kvm.clrscr;
      ^M : _done := true;
      ^N : browse_history( hist_index + 1 );
      ^O : ;
      ^P : browse_history( hist_index - 1 );
      ^Q : ;
      ^R : ;
      ^S : ;
      ^T : transpose;
      ^U : begin delete( buf, 1, cur - 1); len := length( buf ); cur := 1
	   end;
      ^V : ;
      ^W : kill_prev_word;
      ^X : ;
      ^Y : ;
      ^Z : ;
      { special characters }
      ^@ : escapes; // #0 ( null )
      ^[ : escapes;
      ^\ , ^], ^^ , ^_ : ; // field, group, record, unit separator
      ^? : backspace;
      else begin
	write( ch );
	insert( ch, buf, cur );
	inc( cur ); inc( len );
      end
    end
  end; { step }

  procedure LineEditor.reset;
  begin
    len := 0; cur := 1; plen := length( pmt );
    _done := false;
    browse_history( history.count );
  end;

  function LineEditor.input( const pmt : string; var res : string ) : boolean;
  begin
    self.pmt := pmt;
    self.buf := res;
    reset;
    refresh;
    _done := false; keep := true; // optimism!
    repeat step until done;
    if keep then res := flush;
    result := keep;
  end; { LineEditor.prompt }


  function LineEditor.flush : string;
  begin
    result := self.buf;
    if result <> '' then history.add( result );
    self.buf := '';
    reset;
  end;



function term_supported : boolean;
  var un, term : string;
begin
  result := true;
  term := getEnvironmentVariable( 'TERM' );
  for un in unsupported do if term = un then result := false;
end;


function prompt( const msg : string; var buf : string ) : boolean;
begin
  if term_supported and not force_plain then //  and is_tty( stdin )
  begin
    result := ed.input( msg, buf )
  end
  else begin
    write( msg );
    readln( system.input );
    result := not eof; //  need to debug this
  end
end;


{ -- TStringList wrappers  -- }

procedure StringList.load( path : string ); inline;
begin
  if fileExists( path ) then self.LoadFromFile( path );
end;

procedure StringList.save( path : string ); inline;
begin
  self.SaveToFile( path );
end;


initialization
  ed := LineEditor.create;
end.
