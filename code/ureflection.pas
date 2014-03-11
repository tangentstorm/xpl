{$mode delphiunicode}{$i xpc.inc}
unit ureflection;
interface uses xpc, classes, typinfo, rttiutils, sysutils;

type

  IProperty = interface
    function GetName : TStr;
    property name : TStr read GetName;

    function GetTypeKind : TTypeKind;
    property typeKind : TTypeKind read GetTypeKind;

    function GetTypeName : TStr;
    property typeName : TStr read GetTypeName;

    function GetValue : variant;
    procedure SetValue( v : variant );
    property Value : variant read GetValue write SetValue;
  end;

  TProperty = class (TComponent, IProperty)
    protected
      _instance : TObject;
      _propinfo : PPropInfo;
    published
      constructor Create(instance : TObject; info : PPropInfo); overload;
      function GetName : TStr;
      function GetTypeKind : TTypeKind;
      function GetTypeName : TStr;
      function GetValue : variant;
      procedure SetValue( v : variant );
    end;

  TStringArray = array of TStr;
  TProperties = array of IProperty;

  IReflection = interface;
  TChildren = array of IReflection;

  IReflection = interface
    function GetClassName : TStr;
    function GetInstance : TObject;
    procedure SetInstance(obj : TObject);
    property instance : TObject read GetInstance write SetInstance;
    function PropNames : TStringArray;
    function GetProp( s : TStr ) : variant;
    procedure SetProp( s : TStr; v : variant );
    property prop[ s : TStr ]: variant read GetProp write SetProp; default;
    property ClassName : TStr read GetClassName;
    function GetProperties : TProperties;
    property properties : TProperties read GetProperties;
    function GetInstanceChildren : TChildren;
    property children : TChildren read GetInstanceChildren;
  end;

  TReflection = class (TComponent, IReflection)
    protected
      _instance : TObject;
      _proplist : TPropInfoList;
    published
      function GetClassName : TStr;
      function GetInstance : TObject;
      procedure SetInstance(obj : TObject);
      property instance : TObject read GetInstance write SetInstance;
      function PropNames : TStringArray;
      function GetProp( s : TStr ) : variant;
      procedure SetProp( s : TStr; v : variant );
      property prop[ s : TStr ]: variant read GetProp write SetProp; default;
      function GetProperties : TProperties;
      function GetInstanceChildren : TChildren;
    end;

  function reflect(obj : TObject ) : IReflection;

implementation

constructor TProperty.Create(instance : TObject; info : PPropInfo);
  begin
    _instance := instance;
    _propinfo := info;
  end;

function TProperty.GetValue : variant;
  begin
    result := GetPropValue(_instance, _propinfo.name);
  end;

procedure TProperty.SetValue( v : variant );
  begin
    SetPropValue(_instance, _propinfo.name, v);
  end;

function TProperty.GetName : TStr;
  begin
    result := Utf8Decode(_propinfo.name);
  end;

function TProperty.GetTypeKind : TTypeKind;
  begin
    result := _propinfo.proptype.kind;
  end;

function TProperty.GetTypeName : TStr;
  begin
    result := Utf8Decode(_propinfo.proptype.name);
  end;

{-- TReflection -------------------------------------------------}

function TReflection.GetInstance : TObject;
  begin
    result := _instance
  end;

function TReflection.GetClassName : TStr;
  begin
    result := Utf8Decode(_instance.ClassName);
  end;

procedure TReflection.SetInstance(obj : TObject);
  begin
    _instance := obj;
    if Assigned(_proplist) then _proplist.Free;
    _proplist := TPropInfoList.Create(obj, tkAny);
  end;

function TReflection.PropNames : TStringArray;
  var i : cardinal;
  begin
    SetLength(result, _proplist.count);
    for i := 0 to _proplist.count - 1 do
      result[i] := Utf8Decode(_proplist.items[i].name);
  end;

function TReflection.GetProperties : TProperties;
  var i : cardinal;
  begin
    SetLength(result, _proplist.count);
    for i := 0 to _proplist.count - 1 do result[i] := TProperty.Create(_instance, _proplist[i]);
  end;

function TReflection.GetInstanceChildren : TChildren;
  var c : TComponent; i, len : cardinal;
  begin
    SetLength(result, 0);
    if _instance is TComponent then
      begin
        c := TComponent(_instance);
        len := c.ComponentCount;
        SetLength(result, len);
        for i := len - 1 downto 0 do result[i] := Reflect(c.components[i]);
      end
  end;

function TReflection.GetProp( s : TStr ) : variant;
  begin
    result := GetPropValue(_instance, Utf8Encode(s));
  end;

procedure TReflection.SetProp( s : TStr; v : variant );
  begin
    SetPropValue(_instance, UTF8Encode(s), v);
  end;

function reflect(obj : TObject ) : IReflection;
  begin
    result := TReflection.Create(nil);
    result.instance := obj;
  end;

begin
end.
