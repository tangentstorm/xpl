unit vt;
interface uses utf8;

  type
    utf8ch  = string[ 4 ];
    unichar = word;
    cell    = packed record
		fg, bg : byte;
		ch     : unichar;
	      end;

  function readkey : char;
  function keypressed : boolean;

  procedure fg;
  procedure bg;

  procedure cursoron;
  procedure cursoroff;
  procedure cursorbig;

  type iScreen = interface
    procedure clrscr;
    procedure clreol;
    procedure setfg( c : byte );
    procedure setbg( c : byte ) ;
    procedure gotoxy( x, y : word );
    procedure emit( uc : unichar );
    procedure insline;
    procedure delline;
  end;

  type screen = class( iScreen )
    constructor create(   );
    buffer : array of cell;
  end;

begin
end.
