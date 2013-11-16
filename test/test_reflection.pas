{$mode delphi}{$H+}
{$i test_reflection.def }
implementation uses classes, ureflection, variants;

type
  TWhatever = class (TComponent)
    protected
      _int      : integer;
      _OnChange : TNotifyEvent;
      procedure SetInt(value : integer);
    published
      property Int : integer read _int write SetInt;
      property OnChange : TNotifyEvent write _OnChange;
    end;

  TChild = class (TComponent)
    protected
      _value : variant;
    published
      property value : variant read _value write _value;
    end;

procedure TWhatever.SetInt(value : integer);
  begin
    _int := value;
    if assigned(_OnChange) then _OnChange(self);
  end;

var
  obj : TWhatever;
  rfl : IReflection;

procedure setup;
  begin
    if Assigned(obj) then obj.Free;
    obj := TWhatever.Create(nil);
    with TChild.Create(obj) do value := 'kid';
    rfl := Reflect(obj);
  end;

procedure test_className;
  begin
    chk.equal('TWhatever', rfl.className);
  end;

procedure test_propNames;
  var props : array of string;
  begin
    props := rfl.propNames;
    chk.equal(4, length(props));
    chk.equal('Int', props[0]);
    chk.equal('Name', props[1]); // from TComponent
    chk.equal('OnChange', props[2]);
    chk.equal('Tag', props[3]);  // from TComponent
  end;

procedure test_getProp;
  begin
    obj.tag := 1234;
    chk.equal(1234, rfl.GetProp('tag'));
    chk.equal(1234, rfl['tag']);
    obj.tag := 4321;
    chk.equal(4321, rfl['tag']);
    obj.name := 'somename';
    chk.equal('somename', rfl['name']);
  end;

procedure test_setProp;
  begin
    obj.tag := 867;
    rfl['tag'] := 5309;
    chk.equal(5309, rfl['tag']);
    obj.name := 'someone';
    rfl['name'] := 'jenny';
    chk.equal('jenny', rfl['name']);
  end;

procedure test_children;
  var kids : TChildren; kid : IReflection;
  begin
    kids := rfl.children;
    chk.equal(1, length(kids));
    kid := kids[0];
    chk.equal('TChild', kid.className);
    chk.equal('kid', kid['value']);
    kid['value'] := 999;
    chk.equal(999, TChild(obj.components[0]).value);
  end;

finalization
  if Assigned(obj) then obj.Free;
end.
