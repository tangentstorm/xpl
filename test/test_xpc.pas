{$mode delphiunicode}{$i test_xpc.def }
implementation uses xpc, num;

procedure test_hex;
  begin
    chk.equal( hex( 1234 ), '4D2' );
  end;

function cmp(a,b : byte):TCmp;
  begin
    if a<b then result := cmpLT
    else if a > b then result := cmpGT
    else result := cmpEQ;
  end;
procedure test_sort;
  var data, goal: array of byte; i : byte;
  begin
    data := G<byte>.FromOpenArray([246,29,220,69,151,40,194,29,168,174,89,89]);
    goal := G<byte>.FromOpenArray([29,29,40,69,89,89,151,168,174,194,220,246]);
    G<byte>.sort(data, cmp);
    for i := 0 to high(data) do chk.equal(data[i], goal[i], n2s(i));
  end;

end.
