{$mode delphi}{$i xpc.inc}
unit ureflection;
interface uses classes, typinfo, rttiutils, sysutils;

type

  IProperty = interface
    function GetName : string;
    property name : string read GetName;

    function GetTypeKind : TTypeKind;
    property typeKind : TTypeKind read GetTypeKind;

    function GetTypeName : string;
    property typeName : string read GetTypeName;

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
      function GetName : string;
      function GetTypeKind : TTypeKind;
      function GetTypeName : string;
      function GetValue : variant;
      procedure SetValue( v : variant );
    end;

  TStringArray = array of string;
  TProperties = array of IProperty;

  IReflection = interface;
  TChildren = array of IReflection;

  IReflection = interface
    function GetClassName : string;
    function GetInstance : TObject;
    procedure SetInstance(obj : TObject);
    property instance : TObject read GetInstance write SetInstance;
    function PropNames : TStringArray;
    function GetProp( s : string ) : variant;
    procedure SetProp( s : string; v : variant );
    property prop[ s : string ]: variant read GetProp write SetProp; default;
    property ClassName : string read GetClassName;
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
      function GetClassName : string;
      function GetInstance : TObject;
      procedure SetInstance(obj : TObject);
      property instance : TObject read GetInstance write SetInstance;
      function PropNames : TStringArray;
      function GetProp( s : string ) : variant;
      procedure SetProp( s : string; v : variant );
      property prop[ s : string ]: variant read GetProp write SetProp; default;
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

function TProperty.GetName : string;
  begin
    result := _propinfo.name;
  end;

function TProperty.GetTypeKind : TTypeKind;
  begin
    result := _propinfo.proptype.kind;
  end;

function TProperty.GetTypeName : string;
  begin
    result := _propinfo.proptype.name;
  end;

{-- TReflection -------------------------------------------------}

function TReflection.GetInstance : TObject;
  begin
    result := _instance
  end;

function TReflection.GetClassName : string;
  begin
    result := _instance.ClassName;
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
      result[i] := _proplist.items[i].name;
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

function TReflection.GetProp( s : string ) : variant;
  begin
    result := GetPropValue(_instance, s);
  end;

procedure TReflection.SetProp( s : string; v : variant );
  begin
    SetPropValue(_instance, s, v);
  end;

function reflect(obj : TObject ) : IReflection;
  begin
    result := TReflection.Create(nil);
    result.instance := obj;
  end;

begin
end.
