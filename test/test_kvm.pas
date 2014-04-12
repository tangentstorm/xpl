{$mode delphiunicode}{$i xpc.inc}{$i test_kvm.def}
implementation uses kvm;

procedure test_hookterm;
  var base : kvm.TBaseTerm; hook : kvm.THookTerm; old : word;
  begin
    old := kvm.textattr; kvm.textattr := $abcd;
    try
      hook := THookTerm.Create;
      hook.textattr := $1234;
      chk.equal($1234, kvm.textattr);
      chk.equal($1234, hook.asterm.textattr);
      chk.equal($1234, hook.textattr);

      base := TBaseTerm.Create(10,10);
      base.textattr := $9999;
      chk.equal($9999, base.textattr);

      hook.subject := base;
      hook.textattr := $1234;
      chk.equal($1234, base.textattr);

      hook.asTerm.textattr := $2345;
      chk.equal($2345, base.textattr);

    finally kvm.textattr := old end;
  end;

end.
