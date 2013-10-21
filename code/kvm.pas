
{ --- warning!! generated file. edit ../text/kvm.pas.org instead!! --- }


{$mode objfpc}{$i xpc.inc}
unit kvm;
interface uses xpc, ugrid2d, terminal, sysutils;

  type ITerm = interface
    function  Width : word;
    function  Height: word;
    function  MaxX  : word;
    function  MaxY  : word;
    function  WhereX: word;
    function  WhereY: word;
    procedure ClrScr;
    procedure ClrEol;
    procedure Fg( c : byte );
    procedure Bg( c : byte );
    procedure Emit( wc : widechar );
    procedure GotoXY( x, y : word );
    procedure InsLine;
    procedure DelLine;
    procedure SetTextAttr( value : word );
    function  GetTextAttr : word;
    property  TextAttr : word read GetTextAttr write SetTextAttr;
    procedure ShowCursor;
    procedure HideCursor;
  end;
  {$DEFINE unitscope}
  function  Width : word;
  function  Height: word;
  function  MaxX  : word;
  function  MaxY  : word;
  function  WhereX : word;
  function  WhereY : word;
  procedure ClrScr;
  procedure ClrEol;
  procedure Fg( color : byte );
  procedure Bg( color : byte );
  procedure Emit( wc : widechar ); {$IFNDEF unitscope}virtual;{$ENDIF}
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
  type TScreenCell = record
      ch   : widechar;
      attr : TTextAttr;
    end;
  type TScreenGrid = class (specialize GGrid2d<TScreenCell>)
    private
      function GetAttr( const x, y : word ) : TTextAttr;
      function GetChar( const x, y : word ) : WideChar;
      procedure SetAttr( const x, y : word; const value : TTextAttr );
      procedure SetChar( const x, y : word; const value : WideChar );
    public
      property attr[ x, y : word ] : TTextAttr read GetAttr write SetAttr;
      property char[ x, y : word ] : WideChar read GetChar write SetChar;
    end;
  type TPoint = class
    x, y : cardinal;
  end;
  type TRect = class
    x, y : cardinal;
    w, h : cardinal;
  end;
  type TScreenTerm = class  (TInterfacedObject, ITerm) // (TAbstractTerminal)
    public
      function  Width : word;
      function  Height: word;
      function  MaxX  : word;
      function  MaxY  : word;
      function  WhereX : word;
      function  WhereY : word;
      procedure ClrScr;
      procedure ClrEol;
      procedure Fg( color : byte );
      procedure Bg( color : byte );
      procedure Emit( wc : widechar ); {$IFNDEF unitscope}virtual;{$ENDIF}
      procedure GotoXY( x, y : word );
      procedure InsLine;
      procedure DelLine;
      procedure SetTextAttr( value : word );
      function  GetTextAttr : word;
      property  TextAttr : word read GetTextAttr write SetTextAttr;
      procedure ShowCursor;
      procedure HideCursor;
    private
      attr : TTextAttr;
      curs : TPoint;
      grid : TScreenGrid;
   public
      constructor Create( w, h : word );
      destructor Destroy; override;
      function  Cursor : TPoint;
    end;
  type TAnsiTerm = class (TInterfacedObject, ITerm)
    public
      function  Width : word;
      function  Height: word;
      function  MaxX  : word;
      function  MaxY  : word;
      function  WhereX : word;
      function  WhereY : word;
      procedure ClrScr;
      procedure ClrEol;
      procedure Fg( color : byte );
      procedure Bg( color : byte );
      procedure Emit( wc : widechar ); {$IFNDEF unitscope}virtual;{$ENDIF}
      procedure GotoXY( x, y : word );
      procedure InsLine;
      procedure DelLine;
      procedure SetTextAttr( value : word );
      function  GetTextAttr : word;
      property  TextAttr : word read GetTextAttr write SetTextAttr;
      procedure ShowCursor;
      procedure HideCursor;
    private
      attr : word;
    public
      constructor Create;
      procedure ResetColor;
    end;
  type TTermProxy = class  (TInterfacedObject, ITerm)
    protected
      _term : ITerm;
    public
      constructor Create( term : ITerm);
      function  Width : word; virtual;
      function  Height: word; virtual;
      function  WhereX : word; virtual;
      function  WhereY : word; virtual;
      procedure ClrScr; virtual;
      procedure ClrEol; virtual;
      procedure Fg( color : byte ); virtual;
      procedure Bg( color : byte ); virtual;
      procedure Emit( wc : widechar ); virtual;
      procedure GotoXY( x, y : word ); virtual;
      procedure InsLine; virtual;
      procedure DelLine; virtual;
      procedure SetTextAttr( value : word ); virtual;
      function  GetTextAttr : word; virtual;
      procedure ShowCursor; virtual;
      procedure HideCursor; virtual;
      property  TextAttr : word read GetTextAttr write SetTextAttr;
      function  MaxX  : word; { not virtual because it's derived from Width }
      function  MaxY  : word; { not virtual because it's derived from Height }
    end;
  type
    TSubTerm = class (TTermProxy)
      protected
        _x, _y, _w, _h : word;
      public
        constructor Create(term : ITerm; x, y, w, h : word );
        function  Width : word; override;
        function  Height: word; override;
        function  WhereX : word; override;
        function  WhereY : word; override;
        procedure ClrScr; override;
        procedure ClrEol; override;
        procedure GotoXY( x, y : word ); override;
        procedure InsLine; override;
        procedure DelLine; override;
      end;

  procedure fg( c : char );
  procedure bg( c : char );
var work : ITerm;

implementation
  
  function TScreenGrid.GetAttr( const x, y : word ) : TTextAttr;
    begin
      result.fg := self[ x, y ].attr.fg;
      result.bg := self[ x, y ].attr.bg;
    end;
  
  procedure TScreenGrid.SetAttr( const x, y  : word;
                               const value : TTextAttr );
    begin
      with _data[ xyToI( x, y ) ].attr do
        begin
          bg := value.bg;
          fg := value.fg;
        end
    end;
  
  function TScreenGrid.GetChar( const x, y : word ) : WideChar;
    begin
      result := self[ x, y ].ch;
    end;
  
  procedure TScreenGrid.SetChar( const x, y  : word;
                               const value : WideChar );
    begin
      _data[ xyToI( x, y ) ].ch := value;
    end;
  
  
  constructor TScreenTerm.Create( w, h : word );
    begin
    end;
  
  destructor TScreenTerm.Destroy;
    begin
    end;
  
  function  TScreenTerm.Width  : word; begin result := grid.w      end;
  function  TScreenTerm.Height : word; begin result := grid.h      end;
  function  TScreenTerm.MaxX   : word; begin result := width - 1   end;
  function  TScreenTerm.MaxY   : word; begin result := height - 1  end;
  function  TScreenTerm.WhereX : word; begin result := cursor.x    end;
  function  TScreenTerm.WhereY : word; begin result := cursor.y    end;
  
  function  TScreenTerm.GetTextAttr : word;
    begin
      result := word(attr)
    end;
  
  procedure TScreenTerm.SetTextAttr( value : word );
    begin
      attr := TTextAttr(value)
    end;
  
  procedure TScreenTerm.Fg( color : byte );
    begin
      attr.fg := color
    end;
  
  procedure TScreenTerm.Bg( color : byte );
    begin
      attr.bg := color
    end;
  
  procedure TScreenTerm.ClrScr;
    begin
    end;
  
  procedure TScreenTerm.ClrEol;
    begin
    end;
  
  procedure TScreenTerm.GotoXY( x, y : word );
    begin
      cursor.x := x;
      cursor.y := y;
    end;
  
  procedure TScreenTerm.Emit( wc : widechar );
    begin
    end;
  
  procedure TScreenTerm.InsLine;
    begin
    end;
  
  procedure TScreenTerm.DelLine;
    begin
    end;
  
  function TScreenTerm.Cursor : TPoint;
    begin
      result := curs
    end;
  
  procedure TScreenTerm.ShowCursor;
    begin
    end;
  
  procedure TScreenTerm.HideCursor;
    begin
    end;
  
  
  constructor TAnsiTerm.Create;
    begin
      attr := $0007
    end;
  
  { TODO: find a way to get this data without the baggage incurred by
    crt or video modules (breaking keyboard input or clearing the screen  }
  
  function  TAnsiTerm.Width  : word; begin result := terminal.w end;
  function  TAnsiTerm.Height : word; begin result := terminal.h end;
  function  TAnsiTerm.MaxX   : word; begin result := width  - 1  end;
  function  TAnsiTerm.MaxY   : word; begin result := height - 1  end;
  
  function  TAnsiTerm.WhereX : word;
    var bx, by : byte;
    begin
      terminal.getxy(bx, by);
      result := bx;
    end;
  
  function  TAnsiTerm.WhereY : word;
    var bx, by : byte;
    begin
      terminal.getxy(bx, by);
      result := by;
    end;
  
  function  TAnsiTerm.GetTextAttr : word;
    begin
      result := attr;
    end;
  
  procedure TAnsiTerm.SetTextAttr( value : word );
    begin
      Fg(lo(value));
      Bg(hi(value));
    end;
  
  procedure TAnsiTerm.Fg( color : byte );
    begin
      attr := hi(attr) shl 8 + color;
      { xterm 256-color extensions }
      write( #27, '[38;5;', color , 'm' )
    end;
  
  procedure TAnsiTerm.Bg( color : byte );
    begin
      attr := color shl 8 + lo(attr);
      { xterm 256-color extensions }
      write( #27, '[48;5;', color , 'm' )
    end;
  
  procedure TAnsiTerm.ClrScr;
    begin
      write( #27, '[H', #27, '[J' )
    end;
  
  procedure TAnsiTerm.ClrEol;
    var curx, cury, i : byte;
    begin
      terminal.getxy( curx, cury );
      for i := curx to maxX do write(' ');
      gotoxy( curx, cury );
    end;
  
  procedure TAnsiTerm.GotoXY( x, y : word );
    begin
      write( #27, '[', y + 1, ';', x + 1, 'H' )
    end;
  
  procedure TAnsiTerm.Emit( wc : widechar );
    begin
      { TODO: handle escaped characters }
      write( wc )
    end;
  
  { TODO }
  procedure TAnsiTerm.InsLine;
    begin
    end;
  
  procedure TAnsiTerm.DelLine;
    begin
    end;
  
  procedure TAnsiTerm.ResetColor;
    begin
      write( #27, '[0m' )
    end;
  
  procedure TAnsiTerm.ShowCursor; // !! xterm / dec terminals
    begin
      write(#27, '[?25h');
    end;
  
  procedure TAnsiTerm.HideCursor; // !! xterm / dec terminals
    begin
      write(#27, '[?25l');
    end;
  
  
  constructor TTermProxy.Create( term : ITerm );
    begin
      inherited Create;
      _term := term;
    end;
  
  function  TTermProxy.Width  : word; begin result := _term.Width end;
  function  TTermProxy.Height : word; begin result := _term.Height end;
  function  TTermProxy.WhereX : word; begin result := _term.WhereX end;
  function  TTermProxy.WhereY : word; begin result := _term.WhereY end;
  function  TTermProxy.MaxX   : word; begin result := self.Width-1 end;
  function  TTermProxy.MaxY   : word; begin result := self.Height-1 end;
  
  
  procedure TTermProxy.ClrScr; begin _term.ClrScr end;
  procedure TTermProxy.ClrEol; begin _term.ClrEol end;
  
  procedure TTermProxy.Fg( color : byte );    begin _term.Fg( color ) end;
  procedure TTermProxy.Bg( color : byte );    begin _term.Bg( color ) end;
  
  procedure TTermProxy.Emit( wc : widechar ); begin _term.Emit( wc ) end;
  procedure TTermProxy.GotoXY( x, y : word ); begin _term.GotoXY( x, y ) end;
  
  procedure TTermProxy.InsLine; begin _term.InsLine end;
  procedure TTermProxy.DelLine; begin _term.DelLine end;
  
  procedure TTermProxy.ShowCursor; begin _term.ShowCursor end;
  procedure TTermProxy.HideCursor; begin _term.HideCursor end;
  
  procedure TTermProxy.SetTextAttr( value : word );
     begin
       _term.TextAttr := value
     end;
  function  TTermProxy.GetTextAttr : word;
    begin
      result := _term.TextAttr
    end;
  
  
  constructor TSubTerm.Create(term : ITerm; x, y, w, h : word );
    begin
      inherited Create(term);
      _x := x;
      _y := y;
      _w := w;
      _h := h;
    end;
  
  function  TSubTerm.Width : word;
    begin
      result := _w
    end;
  
  function  TSubTerm.Height: word;
    begin
      result := _h
    end;
  
  function  TSubTerm.WhereX : word;
    begin
      result := _term.WhereX - _x
    end;
  
  function  TSubTerm.WhereY : word;
    begin
      result := _term.WhereY - _y
    end;
  
  procedure TSubTerm.ClrScr;
    var y : word; i : integer;
    begin
      for y := 0 to maxY do
        begin
          gotoxy(0, y);
          for i := 1 to self.width do emit(' ');
        end;
      gotoxy(0, 0);
    end;
  
  procedure TSubTerm.ClrEol;
    var curx, cury, i : word;
    begin
      curx := self.WhereX;
      cury := self.WhereY;
      for i := curx to self.maxX do _term.emit(' ');
      self.gotoxy( curx, cury );
    end;
  
  procedure TSubTerm.GotoXY( x, y : word );
    begin
      _term.GotoXY( _x + x, _y + y );
    end;
  
  procedure TSubTerm.InsLine;
    begin
      raise Exception.Create('TSubTerm.InsLine not yet implemented. :/');
    end;
  
  procedure TSubTerm.DelLine;
    begin
      raise Exception.Create('TSubTerm.DelLine not yet implemented. :/');
    end;
  
  
  procedure bg( c :  char );
    var i : byte;
    begin
      i := pos( c, 'krgybmcwKRGYBMCW' );
      if i > 0 then bg( i - 1  );
    end;
  
  procedure fg( c :  char );
    var i : byte;
    begin
      i := pos( c, 'krgybmcwKRGYBMCW' );
      if i > 0 then fg( i - 1  );
    end;
  
  function  Width  : word; begin result := work.Width end;
  function  Height : word; begin result := work.Height end;
  function  MaxX   : word; begin result := work.MaxX end;
  function  MaxY   : word; begin result := work.MaxY end;
  function  WhereX : word; begin result := work.WhereX end;
  function  WhereY : word; begin result := work.WhereY end;
  
  procedure ClrScr; begin work.ClrScr end;
  procedure ClrEol; begin work.ClrEol end;
  
  procedure Fg( color : byte );    begin work.Fg( color ) end;
  procedure Bg( color : byte );    begin work.Bg( color ) end;
  
  procedure Emit( wc : widechar ); begin work.Emit( wc ) end;
  procedure GotoXY( x, y : word ); begin work.GotoXY( x, y ) end;
  
  procedure InsLine; begin work.InsLine end;
  procedure DelLine; begin work.DelLine end;
  
  procedure ShowCursor; begin work.ShowCursor end;
  procedure HideCursor; begin work.HideCursor end;
  
  procedure SetTextAttr( value : word );
    begin work.TextAttr := value end;
  function  GetTextAttr : word;
    begin result := work.TextAttr end;

initialization
  if TTextRec(output).Mode = fmOutput then
    begin
      work := TAnsiTerm.Create;
      work.GotoXY( terminal.startX, terminal.startY );
    end;
finalization
  { work is destroyed automatically by reference count }
end.
