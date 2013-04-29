{$i xpc.inc}
unit vt;
interface uses xpc, utf8, kvm, num, sysutils { for environ };

  type
    utf8ch  = string[ 4 ];
    unichar = word;
    cell    = packed record
		fg, bg : byte;
		ch     : unichar;
	      end;
    colors  = (blk, grn, red, yel, blu, cyn, mgn, wht );

  procedure gotoxy( x, y : word );
  procedure clrscr;
  procedure clreol;

  procedure fg( color : byte );
  procedure bg( color : byte );
  function get_textattr : word;
  procedure set_textattr( value	: word );
  property textattr : word read get_textattr write set_textattr;

  function width : word;
  function height : word;
  function wherex : word;
  function wherey : word;

  function windMaxX : word;
  function windMaxY : word;

//  function readkey	: char;
//  function keypressed	: boolean;
//  procedure cursoron;
//  procedure cursoroff;
//  procedure cursorbig;

  type iScreen = interface(IUnknown)
    procedure clrscr;
    procedure clreol;
    procedure fg( c : byte );
    procedure bg( c : byte );
    procedure gotoxy( x, y : word );
//    procedure emit( uc : unichar );
    procedure insline;
    procedure delline;
  end;

implementation

  type screen = class( tinterfacedobject, iScreen )
    buffer : array of cell;
    constructor create;
    procedure clrscr;
    procedure clreol;
    procedure fg( c : byte );
    procedure bg( c : byte );
    procedure gotoxy( x, y : word );
//    procedure emit( uc : unichar );
    procedure insline;
    procedure delline;
    private
      _fg, _bg : byte;
      w, h : word;
  end;

  var work : screen;

  procedure GetEnv( const key : AnsiString; out result : word; const default : word );
    begin
      try result := s2n( sysutils.GetEnvironmentVariable( key ))
      except result := default end;
    end;

  constructor screen.create;
    begin
      {  TODO : get terminal size for non-linux platforms }
      GetEnv( 'LINES', h, 80 );
      GetEnv( 'COLUMNS', w, 25 );
    end;

  procedure screen.clrscr; begin kvm.clrscr end;
  procedure screen.clreol; begin kvm.clreol end;
  procedure screen.fg( c : byte ); begin kvm.fg( c ) end;
  procedure screen.bg( c : byte ); begin kvm.bg( c )end;
  procedure screen.gotoxy( x, y : word ); begin kvm.gotoxy( x, y ) end;
//  procedure screen.emit( uc : unichar ); begin end;
  procedure screen.insline; begin end;
  procedure screen.delline; begin end;

  procedure fg( color : byte ); begin work.fg( color ) end;
  procedure bg( color : byte ); begin work.bg( color ) end;
  procedure gotoxy( x, y : word ); begin work.gotoxy( x, y ) end;
  procedure clrscr; begin work.clrscr end;
  procedure clreol; begin work.clreol end;
  function width : word; begin result := work.w end;
  function height : word; begin result := work.h end;
  function windMaxX : word; begin result := work.w - 1 end;
  function windMaxY : word; begin result := work.h - 1 end;

  function wherex : word;
  begin
    result := 0; //video.cursorx;
  end;

  function wherey : word;
  begin
    result := 0; //video.cursory;
  end;

  function get_textattr : word;
  begin
    result := ( work._fg shl 8 ) + work._bg;
  end;
  procedure set_textattr( value	: word );
  begin
    work._fg := value and $0f;
    work._bg := (value and $f00) shr 8;
    fg( work._fg );
    bg( work._bg );
  end;

initialization
  work := screen.create;
end.
