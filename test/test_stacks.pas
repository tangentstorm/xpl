{$mode delphi}
{$i test_stacks.def }
implementation uses stacks;

var
  ints : GStack<Int32>;

procedure setup;
  begin
    if assigned(ints) then ints.free;
    ints := GStack<Int32>.Create(16);
  end;

procedure test_pick;
  begin
    ints.push(2); ints.push2(1, 0);
    chk.equal(3, ints.count);
    chk.equal(0, ints.tos, 'tos');
    chk.equal(1, ints.nos, 'nos');
    chk.equal(0, ints[0], 'pick(0)');
    chk.equal(1, ints[1], 'pick(1)');
    chk.equal(2, ints[2], 'pick(2)');
    chk.equal(2, ints[-1], 'pick(-1)');
    chk.equal(1, ints[-2], 'pick(-2)');
    chk.equal(0, ints[-3], 'pick(-3)');
  end;
  
end.
