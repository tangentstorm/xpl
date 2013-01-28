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

  procedure fg( color : byte );
  procedure bg( color : byte );

  procedure cursoron;
  procedure cursoroff;
  procedure cursorbig;

  type iScreen = interface(IUnknown)
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
    buffer : array of cell;
    constructor create(   );
  end;

implementation
end.
