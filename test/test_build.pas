{$i test_build.def }
implementation uses build.dom;

  var
    b : IDomBuilder;

  procedure test_builder;
  begin
    b := TDomBuilder.Create;
  end;

end.
