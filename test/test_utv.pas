{$mode delphiunicode}{$i xpc.inc}{$i test_utv.def}
implementation uses utv, kvm;


procedure test_view;
  var tv : utv.TView;
  begin tv := tview.create(nil); tv.free;
  end;

procedure test_termview_pointers;
  var tv : utv.TTermView; hook : THookTerm;
  begin
    tv := TTermView.Create(Nil);
    chk.equal(tv.asterm.textattr, $0807,   'this works');
    chk.equal(tv.asterm.textattr, $0807,   'hopefully this won''t fail');
    tv.free; // and hopefully this won't fail either!
  end;

end.
