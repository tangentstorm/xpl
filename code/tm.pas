{$mode delphiunicode}{$i xpc}
unit tm; { time }
interface uses xpc, dos, ustr, num;

  const
    days : array[ 0 .. 6 ] of string[ 3 ] =
	   ( 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' );

  function time : TStr;
  function stardate : TStr;

implementation
  
  function time : string;
    var
      h, m, s, n : word;
      ampm	 : TChr;
  begin
    gettime( h, m, s, n );
    if h > 12 then ampm := 'p' else ampm := 'a';
    h := h mod 12;
    if h = 0 then h := 12;
    time := flushrt( n2s( h ), 2, '0' ) + ':' +
	    flushrt( n2s( m ), 2, '0') + ampm + 'm';
  end; { time }

  function stardate : string;  { Sat 1218.93 21:40 }
    var
      w,mo,d,y : word;
  begin
    getdate( y, mo, d, w );
    stardate := days[ w-1 ] + ' ' +
		flushrt( n2s( mo ), 2, '0') +
		flushrt( n2s( d ), 2, '0') + '.' +
		copy(flushrt( n2s( y ), 4, '0'), 3, 5 ) + ' ' + a2u(time);
  end; { stardate }

end.