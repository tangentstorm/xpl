{$mode delphiunicode}{$i test_xpc.def }
implementation uses xpc;

  procedure test_hex;
  begin
    chk.equal( hex( 1234 ), '4D2' );
  end;

end.
