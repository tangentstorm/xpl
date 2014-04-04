
{ --- warning!! generated file. edit ../text/kvm.pas.org instead!! --- }


{$mode objfpc}{$i xpc.inc}
unit kvm;
interface uses xpc, ugrid2d, sysutils, strutils, chk,
  {$ifdef VIDEOKVM}video
  {$else}terminal
  {$endif}
  ;

var stdout : text;

  type ITerm = interface
    function  Width : word;
    function  Height: word;
    function  XMax  : word;
    function  YMax  : word;
    function  WhereX: word;
    function  WhereY: word;
    procedure ClrScr;
    procedure ClrEol;
    procedure NewLine;
    procedure ScrollUp;
    procedure Fg( color : byte );
    procedure Bg( color : byte );
    procedure Emit( s : TStr );
    procedure GotoXY( x, y : word );
    procedure InsLine;
    procedure DelLine;
    procedure SetTextAttr( value : word );
    function  GetTextAttr : word;
    property  TextAttr : word read GetTextAttr write SetTextAttr;
    procedure ShowCursor;
    procedure HideCursor;
    procedure Resize( NewW, NewH : word );
  end;
  {$DEFINE unitscope}
  function  Width : word;
  function  Height: word;
  function  XMax  : word;
  function  YMax  : word;
  function  WhereX : word;
  function  WhereY : word;
  procedure ClrScr;
  procedure ClrEol;
  procedure Fg( color : byte );
  procedure Bg( color : byte );
  procedure Emit( s : TStr );
  procedure GotoXY( x, y : word );
  procedure InsLine;
  procedure DelLine;
  procedure SetTextAttr( value : word );
  function  GetTextAttr : word;
  property  TextAttr : word read GetTextAttr write SetTextAttr;
  procedure ShowCursor;
  procedure HideCursor;
  {$UNDEF unitscope}

  type TTextAttr = record
      bg : byte;
      fg : byte;
    end;
  type TTermCell = record
      ch   : widechar;
      attr : TTextAttr;
    end;
  type TTermGrid = class (specialize GGrid2d<TTermCell>)
    private
      function GetAttr( const x, y : word ) : TTextAttr;
      function GetChar( const x, y : word ) : WideChar;
      procedure SetAttr( const x, y : word; const value : TTextAttr );
      procedure SetChar( const x, y : word; const value : WideChar );
    public
      property attrs[ x, y : word ] : TTextAttr read GetAttr write SetAttr;
      property chars[ x, y : word ] : WideChar read GetChar write SetChar;
    end;
  type TPoint = class
    x, y : cardinal;
  end;
  type TRect = class
    x, y : cardinal;
    w, h : cardinal;
  end;
  type
    TOnEmit = procedure( s : TStr ) of object;
    TOnGotoXY = procedure( x, y : word ) of object;
    TOnSetTextAttr = procedure( a : TTextAttr ) of object;
    TOnSetColor = procedure( color : byte ) of object;
  type TBaseTerm = class (TInterfacedObject, ITerm)
    protected
      _attr  : TTextAttr;
      _curs  : TPoint;
      _w, _h : word;
    public
      constructor Create( NewW, NewH : word ); virtual;
      function Width : word; virtual;
      function Height : word; virtual;
      function xMax : word; virtual;
      function yMax : word; virtual;
      function WhereX : word; virtual;
      function WhereY : word; virtual;
      procedure GotoXY( x, y : word ); virtual;
      procedure ClrScr; virtual;
      procedure ClrEol; virtual;
      procedure NewLine; virtual;
      procedure ScrollUp; virtual;
      procedure Fg( color : byte ); virtual;
      procedure Bg( color : byte ); virtual;
      function GetTextAttr : word;
      procedure SetTextAttr( value : word ); virtual;
      procedure EmitChar( ch : TChr ); virtual;
      procedure Emit( s : TStr );
      procedure InsLine; virtual;
      procedure DelLine; virtual;
      procedure ShowCursor; virtual;
      procedure HideCursor; virtual;
      procedure Resize( NewW, NewH : word );
    protected
      _OnEmit : TOnEmit;
      _OnGotoXY : TOnGotoXY;
      _OnSetTextAttr : TOnSetTextAttr;
      _OnSetFg : TOnSetColor;
      _OnSetBg : TOnSetColor;
    published
      property w : word read Width;
      property h : word read Height;
      property OnEmit : TOnEmit read _OnEmit write _OnEmit;
      property OnGotoXY : TOnGotoXY read _OnGotoXY write _OnGotoXY;
      property OnSetTextAttr : TOnSetTextAttr
        read _OnSetTextAttr write _OnSetTextAttr;
      property OnSetFg : TOnSetColor read _OnSetFg write _OnSetFg;
      property OnSetBg : TOnSetColor read _OnSetBg write _OnSetBg;
    end;
  type TGridTerm = class (TBaseTerm, ITerm)
    private
      _grid : TTermGrid;
    public
      constructor Create( NewW, NewH : word ); override;
      destructor Destroy; override;
      function GetCell( const x, y : word ) : TTermCell;
      procedure PutCell( const x, y : word; const cell : TTermCell );
      procedure ClrScr; override;
      procedure EmitChar( wc : widechar ); override;
      property cells[ x, y : word ] : TTermCell
        read GetCell write PutCell; default;
      procedure DelLine; override;
    end;
  type TAnsiTerm = class (TBaseTerm)
    public
      constructor Create( NewW, NewH : word; CurX, CurY : byte );
        reintroduce;
      procedure DoGotoXY( x, y : word );
      procedure DoEmit( s : TStr );
      //  the rest of these should be callbacks too:
      procedure ResetColor;
      procedure Fg( color : byte ); override;
      procedure Bg( color : byte ); override;
      procedure ClrScr; override;
      procedure ShowCursor; override;
      procedure HideCursor; override;
  end;
  type TVideoTerm = class (TANSITerm)
  end;
  type
    TSubTerm = class (TGridTerm)
      protected
        _term : ITerm;
        _x, _y : word;
      public
        constructor Create(term : ITerm; x, y, NewW, NewH : word ); reintroduce;
        procedure DoGotoXY( x, y : word );
        procedure DoEmit( s : TStr );
        procedure DoSetTextAttr( value : word );
        procedure DoSetFg( color : byte );
        procedure DoSetBg( color : byte );
      end;

  procedure fg( ch : char );
  procedure bg( ch : char );

var work : ITerm;

implementation
  
  function TTermGrid.GetAttr( const x, y : word ) : TTextAttr;
    begin
      result.fg := self[ x, y ].attr.fg;
      result.bg := self[ x, y ].attr.bg;
    end;
  
  procedure TTermGrid.SetAttr( const x, y  : word;
                               const value : TTextAttr );
    begin
      with _data[ xyToI( x, y ) ].attr do
        begin
          bg := value.bg;
          fg := value.fg;
        end
    end;
  
  function TTermGrid.GetChar( const x, y : word ) : WideChar;
    begin
      result := self[ x, y ].ch;
    end;
  
  procedure TTermGrid.SetChar( const x, y  : word;
                               const value : WideChar );
    begin
      _data[ xyToI( x, y ) ].ch := value;
    end;
  
  constructor TBaseTerm.Create( NewW, NewH : word );
    begin
      _w := NewW; _h := NewH;
      _curs := TPoint.Create; _curs.x := 0; _curs.y := 0;
      _attr.fg := $07; _attr.bg := $00; // light gray on black
    end;
  function TBaseTerm.Width : word; begin result := _w end;
  function TBaseTerm.Height: word; begin result := _h end;
  function TBaseTerm.XMax : word; begin result := width - 1  end;
  function TBaseTerm.YMax : word; begin result := height - 1 end;
  procedure TBaseTerm.Resize( NewW, NewH : word );
    begin
      _w := NewW; _h := NewH;
    end;
  
  function TBaseTerm.WhereX : word; begin result := _curs.x end;
  function TBaseTerm.WhereY : word; begin result := _curs.y end;
  
  procedure TBaseTerm.GotoXY( x, y : word );
    begin
      _curs.x := x;
      _curs.y := y;
      if assigned(_OnGotoXY) then _OnGotoXY( x, y );
    end;
  
  procedure TBaseTerm.ClrScr;
    var y : word; i : integer;
    begin
      for y := 0 to yMax do
        begin
          gotoxy(0, y);
          for i := 1 to self.width do Emit(' ');
        end;
      gotoxy(0, 0);
    end;
  
  procedure TBaseTerm.ClrEol;
    var oldX, i : word;
    begin
      oldX := _curs.x;
      if oldX < xMax then for i := oldX to xMax do Emit(' ')
      else ok;
    { ensure curs'.x = curs.x ; curs'.y = curs.y }
      self.gotoXY( oldX, _curs.y );
    end;
  
  procedure TBaseTerm.NewLine;
    begin
      if whereY = yMax then begin scrollUp; gotoXY( 0, yMax ) end
      else self.gotoXY( 0, whereY+1 );
    end;
  
  procedure TBaseTerm.ScrollUp;
    var x, y : cardinal;
    begin
      x := _curs.x; y := _curs.y; gotoXY(0,0); delLine; gotoXY(x, y);
    end;
  
  
  procedure TBaseTerm.ShowCursor; begin ok end;
  procedure TBaseTerm.HideCursor; begin ok end;
  
  
  procedure TBaseTerm.InsLine; begin ok end;
  procedure TBaseTerm.DelLine; begin ok end;
  
  
  function  TBaseTerm.GetTextAttr : word;
    begin
      result := word(_attr)
    end;
  
  procedure TBaseTerm.SetTextAttr( value : word );
    begin
      _attr := TTextAttr(value)
    end;
  
  procedure TBaseTerm.Fg( color : byte );
    begin
      _attr.fg := color;
      if assigned( _OnSetFg ) then _OnSetFg( color );
    end;
  
  procedure TBaseTerm.Bg( color : byte );
    begin
      _attr.bg := color;
      if assigned( _OnSetBg ) then _OnSetBg( color );
    end;
  
  
  procedure TBaseTerm.EmitChar( ch : TChr );
     begin
     end;
  
  procedure TBaseTerm.Emit( s : TStr );
    var ch : widechar; dist : cardinal;
    begin
      if length(s) > 0 then begin
        dist := _w - _curs.x; // distance to end of line
        if length(s) <= dist then
          begin
            // ensure  xpos' = xpos + dist
            for ch in s do begin EmitChar(ch); _curs.x += 1; end;
            if assigned(_OnEmit) then _OnEmit(s);
          end
        else
          begin
            emit(midstr(s, 1, dist));
            chk.equal( _w, _curs.x );
            self.newline;
            chk.equal( 0, _curs.x );
            emit(midstr(s, dist, length(s)-dist));
          end
      end
    end;
  
  constructor TGridTerm.Create( NewW, NewH : word );
    begin
      inherited create( NewW, NewH );
      _grid := TTermGrid.Create( NewW, NewH );
      clrscr;
    end;
  
  destructor TGridTerm.Destroy;
    begin;
      _grid.Free;
      inherited destroy;
    end;
  
  procedure TGridTerm.ClrScr;
    var cell : TTermCell;
    begin
      inherited clrscr;
      cell.ch := ' ';
      cell.attr := _attr;
      _grid.fill(cell);
      gotoxy(0,0);
    end;
  
  procedure TGridTerm.EmitChar( wc : widechar );
    var cell : TTermCell;
    begin
      cell.attr := _attr; cell.ch := wc;
      _grid[_curs.x, _curs.y] := cell;
    end;
  
  function TGridTerm.GetCell( const x, y : word ) : TTermCell;
    begin
      result := _grid[x,y]
    end;
  
  procedure TGridTerm.PutCell( const x, y : word; const cell : TTermCell );
    begin
      _grid[x,y] := cell;
    end;
  
  procedure TGridTerm.DelLine;
    var curx, cury, x, y : integer;
    begin
      curx := wherex; cury := wherey;
      for y := cury to ymax-1 do
        begin
          gotoxy(0, y);
          for x := 0 to xmax do
            begin
              emit(_grid[x, y+1].ch);
            end;
          end;
      gotoxy(0, ymax); clreol;
      gotoxy(curx, cury);
    end;
  
  constructor TAnsiTerm.Create(NewW, NewH : word; CurX, CurY : byte);
    begin
      inherited Create( NewW, NewH );
      // we set xy directly because the cursor is already
      // somewhere when the program starts.
      _curs.x := curx;
      _curs.y := cury;
      _OnGotoXY := @DoGotoXY;
      _OnEmit := @DoEmit;
    end;
  
  procedure TAnsiTerm.Fg( color : byte );
    begin
      inherited fg( color );
      _attr.fg := color;
      { xterm 256-color extensions }
      write( stdout, #27, '[38;5;', color , 'm' )
    end;
  
  procedure TAnsiTerm.Bg( color : byte );
    begin
      inherited bg( color );
      _attr.bg := color;
      { xterm 256-color extensions }
      write( stdout, #27, '[48;5;', color , 'm' )
    end;
  
  procedure TAnsiTerm.ClrScr;
    begin
      write( stdout, #27, '[H', #27, '[J' )
    end;
  
  procedure TAnsiTerm.DoGotoXY( x, y : word );
    begin
      write(stdout, #27, '[', y + 1, ';', x + 1, 'H' )
    end;
  
  procedure TAnsiTerm.DoEmit( s : TStr );
    begin
      write(stdout, utf8encode(s));
    end;
  
  procedure TAnsiTerm.ResetColor;
    begin
      write(stdout, #27, '[0m' )
    end;
  
  procedure TAnsiTerm.ShowCursor; // !! xterm / dec terminals
    begin
      write(stdout, #27, '[?25h');
    end;
  
  procedure TAnsiTerm.HideCursor; // !! xterm / dec terminals
    begin
      write(stdout, #27, '[?25l');
    end;
  
    
  constructor TSubTerm.Create(term : ITerm; x, y, NewW, NewH : word );
    begin
      inherited Create(NewW, NewH);
      _term := term;
      _x := x; _y := y;
      _OnEmit := @DoEmit;
      _OnGotoXy := @DoGotoXY;
      _OnSetFg := @DoSetFg;
      _OnSetBg := @DoSetBg;
    end;
    
  procedure TSubTerm.DoGotoXY( x, y : word );
    begin _term.GotoXY( x + _x, y + _y );
    end;
    
  procedure TSubTerm.DoEmit( s : TStr );
    begin _term.Emit( s );
    end;
    
  procedure TSubTerm.DoSetTextAttr( value : word );
    begin _term.TextAttr := value;
    end;
    
  procedure TSubTerm.DoSetFg( color : byte );
    begin _term.Fg(color)
    end;
    
  procedure TSubTerm.DoSetBg( color : byte );
    begin _term.Bg(color)
    end;
  
  
  procedure bg( ch :  char );
    var i : byte;
    begin
      i := pos( ch, 'krgybmcwKRGYBMCW' );
      if i > 0 then bg( i - 1  );
    end;
  
  procedure fg( ch :  char );
    var i : byte;
    begin
      i := pos( ch, 'krgybmcwKRGYBMCW' );
      if i > 0 then fg( i - 1  );
    end;
  
  {$IFDEF UNIX}
  function GetLiveAnsiTerm : TAnsiTerm;
    var termw, termh : byte; curx, cury : byte;
    begin
      terminal.getwh(termw, termh);
      curx := terminal.startX;
      cury := terminal.startY;
      result := TAnsiTerm.Create( termw, termh, curx, cury );
    end;
  {$ENDIF}
  function  Width  : word; begin result := work.Width end;
  function  Height : word; begin result := work.Height end;
  function  XMax   : word; begin result := work.xMax end;
  function  YMax   : word; begin result := work.yMax end;
  function  WhereX : word; begin result := work.WhereX end;
  function  WhereY : word; begin result := work.WhereY end;
  
  procedure Fg( color : byte );    begin work.Fg( color ) end;
  procedure Bg( color : byte );    begin work.Bg( color ) end;
  
  procedure Emit( s : TStr ); begin work.Emit( s ) end;
  procedure GotoXY( x, y : word ); begin work.GotoXY( x, y ) end;
  
  procedure ClrScr; begin work.ClrScr end;
  procedure ClrEol; begin work.ClrEol end;
  
  procedure InsLine; begin work.InsLine end;
  procedure DelLine; begin work.DelLine end;
  
  procedure ShowCursor; begin work.ShowCursor end;
  procedure HideCursor; begin work.HideCursor end;
  
  procedure SetTextAttr( value : word );
    begin work.TextAttr := value end;
  function  GetTextAttr : word;
    begin result := work.TextAttr end;
  
  function KvmWrite(var f: textrec): integer;
    var s: ansistring;
    begin
      if f.bufpos > 0 then
        begin
          setlength(s, f.bufpos);
          move(f.buffer, s[1], f.bufpos);
          kvm.emit(TStr(s)); // convert to widestring
        end;
      f.bufpos := 0;
      Result := 0;
    end;
  
  function KvmClose(var txt: TTextRec): integer;
    begin
      Result := 0;
    end;
  
  function KvmOpen(var txt: TTextRec): integer;
    begin
      case txt.mode of
        fmOutput:
        begin
          txt.inOutFunc := @KvmWrite;
          txt.flushFunc := @KvmWrite;
        end
        else // todo : error;
      end;
      Result := 0;
    end;
  
  // http://docwiki.embarcadero.com/RADStudio/XE5/en/Standard_Routines_and_Input-Output
  procedure AssignKvm(var txt: Text);
    begin
      Assign(txt, '');
      with TTextRec(txt) do
      begin
        mode := fmClosed;
        openFunc := @KvmOpen;
        closeFunc := @KvmClose;
      end;
    end;
initialization
  Assign(stdout,''); Rewrite(stdout);
  AssignKVM(output); Rewrite(output);
  {$IFDEF UNIX}
    work :={$IFDEF VIDEOKVM}TVideoTerm.Create
           {$ELSE}GetLiveANSITerm{$ENDIF};
  {$ELSE}
    work := TGridTerm.Create(64, 16);
  {$ENDIF}
finalization
  { work is destroyed automatically by reference count }
end.
