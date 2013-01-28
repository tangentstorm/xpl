{ this emulates the turbo pascal crt interface, but atop the cross-platform "video" module }
unit vid;
interface uses video;

  var
    windmaxx,
    windmaxy,
    wherex,
    wherey :  byte;

  type
    fgbg      = (fore, back);
    color     = $0 .. $f ;
    attribute = packed array[fgbg] of color;

  procedure textcolor( c : byte );
  procedure gotoxy( x, y : cardinal );

  procedure crt_set_textattr( value : byte );
  function  crt_get_textattr:byte;
  property TextAttr : byte
    read crt_get_textattr
    write crt_set_textattr;

implementation

  {-- emulate setting crt.textattr --}
  
  var _textattr : attribute;
  
  procedure crt_set_textattr( value : byte );
  begin
    _textattr[ back ]:= hi( value );
    _textattr[ fore ]:= lo( value );
  end;
    
  function crt_get_textattr : byte;
  begin
    result := (_textattr[back] shl 8) + _textattr[fore]
  end;

  procedure textcolor( c : byte );
  begin
    _textattr[ fore ] := color( c );
  end;

  procedure gotoxy( x, y : cardinal );
  begin
    wherex := x;
    wherey := y;
  end;

end.
