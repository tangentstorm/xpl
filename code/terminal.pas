unit terminal;
interface uses baseunix, termio;

  procedure OnResizeIgnore (const w, h : byte ); { default handler }
  procedure GetXY( var x, y : byte );
  procedure GetWH( var w, h : byte );
  
  var
    w, h	   : byte; { initial terminal width and height }
    startX, startY : byte; { initial cursor x and y coordinates }
    OnResize	   : procedure ( const w, h : byte );

implementation

procedure OnResizeIgnore (const w, h : byte );
  begin
    { do nothing }
  end;
  
procedure GetWH( var w, h :  byte );
  var winsize : termio.TWinSize;
  begin
    baseunix.fpioctl(system.stdInputHandle,
		     termio.TIOCGWINSZ,
		     @winsize);
    w := winsize.ws_col;
    h := winsize.ws_row;
  end;

procedure OnResizeSignal( sig : cint ); cdecl;
  begin
    GetWH( terminal.w, terminal.h );
    OnResize( terminal.w, terminal.h );
  end;

{---------------------------------------------------------------------}
{ this portion was extracted from the crt unit                        }
{---------------------------------------------------------------------}
{                                                                     }
{   This file is part of the Free Pascal run time library.            }
{   Copyright (c) 1999-2000 by Michael Van Canneyt and Peter Vreman,  }
{   members of the Free Pascal development team.                      }
{    See the file COPYING.FPC, included in this distribution,         }
{   for details about the copyright.                                  }
{                                                                     }
{    This program is distributed in the hope that it will be useful,  }
{   but WITHOUT ANY WARRANTY; without even the implied warranty of    }
{   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              }
{---------------------------------------------------------------------}

var
  OldIO : termio.TermIos;
  inputRaw, outputRaw: boolean;

procedure saveRawSettings(const tio: termio.termios);
  Begin
    with tio do
      begin
	inputRaw :=
	  ((c_iflag and (IGNBRK or BRKINT or PARMRK or ISTRIP or
			 INLCR or IGNCR or ICRNL or IXON)) = 0) and
	  ((c_lflag and (ECHO or ECHONL or ICANON or ISIG or IEXTEN)) = 0);
	outPutRaw :=
	  ((c_oflag and OPOST) = 0) and
	  ((c_cflag and (CSIZE or PARENB)) = 0) and
	  ((c_cflag and CS8) <> 0);
      end;
  end;

procedure restoreRawSettings(tio: termio.termios);
  begin
    with tio do
    begin
      if inputRaw then
        begin
	  c_iflag := c_iflag and (not (IGNBRK or BRKINT or PARMRK or ISTRIP or
				       INLCR or IGNCR or ICRNL or IXON));
	  c_lflag := c_lflag and
		     (not (ECHO or ECHONL or ICANON or ISIG or IEXTEN));
	end;
      if outPutRaw then
        begin
	  c_oflag := c_oflag and not(OPOST);
	  c_cflag := c_cflag and not(CSIZE or PARENB) or CS8;
	end;
    end;
  end;


procedure SetRawMode(b:boolean);
  var Tio : Termios;
  Begin
    if b then
      begin
	TCGetAttr(1,Tio);
	SaveRawSettings(Tio);
	OldIO:=Tio;
	CFMakeRaw(Tio);
      end
    else
      begin
	RestoreRawSettings(OldIO);
	Tio:=OldIO;
      end;
    TCSetAttr(1,TCSANOW,Tio);
  end;
  
procedure GetXY(var x, y : byte);
  var
    fds	   : tfdSet;
    i,j,   
    readed : longint;
    buf	   : array[0..255] of char;
    s	   : string[16];
  begin
    x:=0;
    y:=0;
    s:=#27'[6n';
    fpWrite(0,s[1],length(s));
    fpFD_ZERO(fds);
    fpFD_SET(1,fds);
    readed:=0;
    repeat
      if (fpSelect(2,@fds,nil,nil,1000)>0) then
        begin
	  readed:=readed+fpRead(1,buf[readed],sizeof(buf)-readed);
	  i:=0;
	  while (i+5<readed) and (buf[i]<>#27) and (buf[i+1]<>'[') do inc(i);
	  if i+5<readed then
	    begin
	      s:=space(16);
	      move(buf[i+2],s[1],16);
	      j:=Pos('R',s);
	      if j>0 then
  	        begin
		  i:=Pos(';',s);
		  Val(Copy(s,1,i-1),y);
		  Val(Copy(s,i+1,j-(i+1)),x);
		  break;
		end;
	    end;
	end
      else break;
    until false;
  end;

{---------------------------------------------------------------------}
{ end crt extract                                                     }
{---------------------------------------------------------------------}

initialization
  GetWH( w, h );
  OnResize := @OnResizeIgnore;
  SetRawMode( true );
  GetXY( startX, startY );
  SetRawMode( false );

  { callback for window/terminal size change }
  if baseunix.fpSignal( baseunix.SigWinCh,
		        baseunix.SignalHandler( @OnResizeSignal ))
     = baseunix.signalhandler(SIG_ERR)
  then
    begin
      writeln( 'Error registering terminal resize signal. ', fpGetErrno, '.' );
      halt( 1 );
    end;
end.
