{  kvm : wrapper for keyboard, video, and mouse units
   copyright (c) 2012 michal j. wallace. all rights reserved.
   license: mit / isc
}
{$i xpc.inc}
unit kvm;
interface uses xpc;

  
{  this should probably get moved into its own class? }
type
  vector2d = record
	       case kind : ( asize, apoint, avec2d ) of
		 asize	: ( w, h : int32 );
		 apoint	: ( x, y : int32 );
		 avec2d	: ( v : array[ 0 .. 1 ] of int32 );
	     end;

{-- interface > video > graphics --}
type
  color	  = record
	      case separate : boolean of
		true  : ( r, g, b, a : byte );
		false : ( c : int32 );
	    end;

  surface = record
	      w, h : int32;
	      data : array of int32;
	    end;

function hascanvas : boolean;
var canvas : surface;

{-- interface > video > terminal --}
type
  glyph	  = record
	      codepoint	: int32;
	      w, h	: int32;
	    end;

  bmpfont = record
	      size   : vector2d;
	      glyphs : array of glyph;
	    end;

procedure clrscr;
procedure clreol;
procedure gotoxy( x, y : int32 );
procedure fg( c : char );  procedure fg( b : byte );
procedure bg( c : char );  procedure bg( b : byte );
procedure setfont( font :  bmpfont );
  
var term : surface;

{-- interface > mouse --}

{  TODO type buttons = (??) for mouse / gamepad }

function hasmouse : boolean;
function mx : int32;
function my : int32;
function mb : set32;

  
implementation

{ -- implementation > mouse ------------------------------ }

{  mouse routines are just stubs at the moment }

function hasmouse : boolean;
begin
  result := false;
end; { hasmouse }

function mx : int32;
begin
  result := 0;
end; { mx }

function my : int32;
begin
  result := 0;
end; { my }

function mb : set32;
begin
  result := [];
end; { mbtn }

{ -- implementation > video > graphics -------------------- }

function hascanvas : boolean;
begin
  result := false;
end; { hascanvas }


{ -- implementation > video > text > general ------------- }

procedure clrscr;
begin
  write( #27, '[H', #27, '[J' );
end; { clrscr }

procedure clreol;
begin
  write( #27, '[K' );
end; { clreol }

procedure ansi_reset;
begin
  write( #27, '[0m' );
end; { ansi_reset }

procedure gotoxy( x, y : integer );
begin
  write( #27, '[', y + 1, ';', x + 1, 'H' );
  { crt.gotoxy( x + 1, y + 1 ); }
end; { gotoxy }

  
procedure setfont( font : bmpfont );
begin
end; { write }


{ -- implementation > video > text > fg color ------------ }

procedure ansi_fg( i : byte );
begin
  if i < 8 then write( #27, '[0;3', i , 'm' )           // ansi dim
  else if i < 17 then write( #27, '[01;3', i-8 , 'm' ); // ansi bold
  // else do nothing
end; { ansi_fg }

{ xterm 256-color extensions }
procedure xterm_fg( i	:  byte );
begin
  write( #27, '[38;5;', i , 'm' );
end;

{ --- public --- }

procedure fg( c :  char );
  var i : byte;
begin
  i := pos( c, 'krgybmcwKRGYBMCW' );
  if i > 0 then xterm_fg( i - 1 );
end; { fg }

procedure fg( b : byte );
begin
  xterm_fg( b );
end; { fg }

{ -- implementation > video > text > bg color ------------ }

{  implement ansi_bg  -- below is only a copy/paste of ansi_fg }
{procedure ansi_bg( i : byte );
begin
  if i < 8 then write( #27, '[0;3', i , 'm' )           // ansi dim
  else if i < 17 then write( #27, '[01;3', i-8 , 'm' ); // ansi bold
  // else do nothing
end; }
  
procedure xterm_bg( i	:  byte );
begin
  write( #27, '[48;5;', i , 'm' );
end;

procedure bg( c :  char );
var i : byte;
begin
  {  crt.textbackground( i - 1 ); }
  i := pos( c, 'krgybmcwKRGYBMCW' );
  if i > 0 then xterm_bg( i - 1  );
end;

procedure bg( b : byte );
begin
  xterm_bg( b );
end; { bg }



end.
