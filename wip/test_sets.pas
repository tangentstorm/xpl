
{$mode delphi}
{$i test_sets.def }{$h+}
implementation uses sets;

  type
    TStringSet = GSet<string>;
    TCharSet   = set of char;

  const { these are built-in (set of char), tested with bits }
    hexits = ['0'..'9','a'..'f'];
    vowels = ['a','e','i','o','u'];

  var { these use the custom implementation }
    h, v : TStringSet;

  function makeStringSet( chs : TCharSet ) : TStringSet;
    var ch : char;
    begin
      result := TStringSet.Create;
      for ch in chs do result.include( ch );
    end;
  
  function ToString( ss : TStringSet) : string;
    var s : string;
    begin
      result := '';
      for s in s do result += s;
    end;

  procedure setup;
    begin
      h := makeStringSet(hexits);
      v := makeStringSet(vowels);
    end;
  
  procedure test_iter;
    begin
      chk.equal( '0123456789abcdef', ToString(h));
    end;

end.
