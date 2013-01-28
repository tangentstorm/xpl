{$i xpc.inc}
unit vt;
interface uses xpc, utf8, kvm, crt;

  type
    utf8ch  = string[ 4 ];
    unichar = word;
    cell    = packed record
		fg, bg : byte;
		ch     : unichar;
	      end;

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

//  function readkey	: char;
//  function keypressed	: boolean;
//  procedure cursoron;
//  procedure cursoroff;
//  procedure cursorbig;

  type iScreen = interface(IUnknown)
    procedure clrscr;
    procedure clreol;
    procedure fg( c : byte );
    procedure bg( c : byte ) ;
    procedure gotoxy( x, y : word );
//    procedure emit( uc : unichar );
    procedure insline;
    procedure delline;
  end;

implementation

  type screen = class( tinterfacedobject, iScreen )
    buffer : array of cell;
    procedure clrscr;
    procedure clreol;
    procedure fg( c : byte );
    procedure bg( c : byte ) ;
    procedure gotoxy( x, y : word );
//    procedure emit( uc : unichar );
    procedure insline;
    procedure delline;
    private
      _fg, _bg : byte;
      w, h : word;
  end;

  var work : screen;

implementation

  procedure screen.clrscr; begin kvm.clrscr end;
  procedure screen.clreol; begin kvm.clreol end;
  procedure screen.fg( c : byte ); begin kvm.fg( c ) end;
  procedure screen.bg( c : byte ); begin kvm.bg( c )end;
  procedure screen.gotoxy( x, y : word ); begin kvm.gotoxy( x, y ) end;
//  procedure screen.emit( uc : unichar ); begin end;
  procedure screen.insline; begin end;
  procedure screen.delline; begin end;

  procedure fg( c : byte ); begin work.fg( c ) end;
  procedure bg( c : byte ); begin work.bg( c ) end;
  procedure gotoxy( x, y : word ); begin work.gotoxy( x, y ) end;
  procedure clrscr; begin work.clrscr end;
  procedure clreol; begin work.clreol end;
  function width : word; begin result := work.w end;
  function height : word; begin result := work.h end;

  function wherex : word;
  begin
    result := crt.wherex;
  end;

  function wherey : word;
  begin
    result := crt.wherey;
  end;


  function get_textattr : word;
  begin
    result := ( work._fg shl 8 ) + work._bg;
  end;
  procedure set_textattr( value	: word );
  begin
    work._fg := value shr 8;
    work._bg := value and $00ff;
  end;

initialization
  work := screen.create;
end.
