// Written by greenfish (2012)
// Released into public domain

unit MapCntnr;

{$mode delphi}

interface

uses
  SysUtils, Contnrs;

type
  TMapNode<TKey, TValue> = class
  private
    IsBlack: boolean;
    Left, Right, Parent: TMapNode<TKey, TValue>;

    FKey: TKey;
  public
    Value: TValue;
    property Key: TKey read FKey;

    constructor Create;
    destructor Destroy; override;
  end;

  TMapNodeEnumerator<TKey, TValue> = class
  private
    Root: TMapNode<TKey, TValue>;
    Stack: TStack;

    function GetCurrent: TMapNode<TKey, TValue>;
  public
    constructor Create(ARoot: TMapNode<TKey, TValue>); virtual;
    destructor Destroy; override;

    function MoveNext: Boolean;
    property Current: TMapNode<TKey, TValue> read GetCurrent;
  end;

  // Implements a map with a red-black tree
  TMap<TKey, TValue> = class
  protected
    FCount: integer;
    Root: TMapNode<TKey, TValue>;

    function TreeSearch(const Key: TKey;
      out Parent: TMapNode<TKey, TValue>): TMapNode<TKey, TValue>;
    procedure LeftRotate(x: TMapNode<TKey, TValue>);
    procedure RightRotate(x: TMapNode<TKey, TValue>);
    function TreeInsertIfNotExist(const Key: TKey): TMapNode<TKey, TValue>;

    function GetValue(const Key: TKey): TValue;
    procedure SetValue(const Key: TKey; const Value: TValue);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear;

    function SafeGet(const Key: TKey): TValue;
    function ContainsKey(const Key: TKey): boolean;
    function GetEnumerator: TMapNodeEnumerator<TKey, TValue>;

    property Count: integer read FCount;
    property Values[Key: TKey]: TValue read GetValue write SetValue; default;
  end;

implementation

// TMapNode

constructor TMapNode<TKey, TValue>.Create;
begin
  IsBlack := False;
  Left := nil;
  Right := nil;
  Parent := nil;
  FKey := Default(TKey);
  Value := Default(TValue);
end;

destructor TMapNode<TKey, TValue>.Destroy;
begin
  if Left <> nil then Left.Free;
  if Right <> nil then Right.Free;

  inherited;
end;

// TMap

function TMap<TKey, TValue>.TreeSearch;
begin
  Result := Root;
  Parent := nil;

  while Result <> nil do
  begin
    if Key = Result.Key then Break;
    
    Parent := Result;
    if Key < Result.Key then Result := Result.Left else Result := Result.Right;
  end;

  // Result = nil -> not found
end;

procedure TMap<TKey, TValue>.LeftRotate;
var
  y: TMapNode<TKey, TValue>;

begin
  y := x.Right;

  x.Right := y.Left;
  if y.Left <> nil then y.Left.Parent := x;
  
  y.Parent := x.Parent;

  if x.Parent = nil then Root := y else
    if x = x.Parent.Left then
      x.Parent.Left := y else
      x.Parent.Right := y;

  y.Left := x;
  x.Parent := y;
end;

procedure TMap<TKey, TValue>.RightRotate;
var
  y: TMapNode<TKey, TValue>;

begin
  y := x.Left;

  x.Left := y.Right;
  if y.Right <> nil then y.Right.Parent := x;

  y.Parent := x.Parent;

  if x.Parent = nil then Root := y else
    if x = x.Parent.Left then
      x.Parent.Left := y else
      x.Parent.Right := y;

  y.Right := x;
  x.Parent := y;
end;

function TMap<TKey, TValue>.TreeInsertIfNotExist;
var
  Node, Parent, y: TMapNode<TKey, TValue>;

begin
  // already exists?
  Node := TreeSearch(Key, Parent);
  if Node <> nil then Exit(Node);

  // create the node
  Node := TMapNode<TKey, TValue>.Create;
  inc(FCount);
  Result := Node;
  Node.FKey := Key;

  // link
  if Parent <> nil then
  begin
    if Key < Parent.Key then Parent.Left := Node else Parent.Right := Node;
    Node.Parent := Parent;
  end else
    Root := Node;

  // Now restore the red-black property
  while (Node.Parent <> nil) and not Node.Parent.IsBlack do
  if Node.Parent = Node.Parent.Parent.Left then
  begin
    y := Node.Parent.Parent.Right;

    if (y <> nil) and not y.IsBlack then
    begin
      Node.Parent.IsBlack := True;
      y.IsBlack := True;
      Node.Parent.Parent.IsBlack := False;

      Node := Node.Parent.Parent;
    end else
    // y is a black node
    begin
      if Node = Node.Parent.Right then
      begin
         Node := Node.Parent;
         LeftRotate(Node);
      end;

      Node.Parent.IsBlack := True;
      Node.Parent.Parent.IsBlack := False;
      RightRotate(Node.Parent.Parent);
    end;
  end else
  begin
    y := Node.Parent.Parent.Left;

    if (y <> nil) and not y.IsBlack then
    begin
      Node.Parent.IsBlack := True;
      y.IsBlack := True;
      Node.Parent.Parent.IsBlack := False;

      Node := Node.Parent.Parent;
    end else
    // y is a black node
    begin
      if Node = Node.Parent.Left then
      begin
         Node := Node.Parent;
         RightRotate(Node);
      end;

      Node.Parent.IsBlack := True;
      Node.Parent.Parent.IsBlack := False;
      LeftRotate(Node.Parent.Parent);
    end;
  end;

  Root.IsBlack := True;
end;

function TMap<TKey, TValue>.GetValue;
var
  Node, Parent: TMapNode<TKey, TValue>;

begin
  Node := TreeSearch(Key, Parent);
  if Node = nil then
    raise Exception.Create('Map key does not exist')
    else Result := Node.Value;
end;

procedure TMap<TKey, TValue>.SetValue;
begin
  TreeInsertIfNotExist(Key).Value := Value;
end;

constructor TMap<TKey, TValue>.Create;
begin
  FCount := 0;
  Root := nil;
end;

destructor TMap<TKey, TValue>.Destroy;
begin
  Clear;
  inherited;
end;

procedure TMap<TKey, TValue>.Clear;
begin
  FCount := 0;
  FreeAndNil(Root);
end;

function TMap<TKey, TValue>.SafeGet;
var
  Node, Parent: TMapNode<TKey, TValue>;

begin
  Node := TreeSearch(Key, Parent);
  if Node = nil then
    Result := Default(TValue)
    else Result := Node.Value;
end;

function TMap<TKey, TValue>.ContainsKey;
var
  Node, Parent: TMapNode<TKey, TValue>;

begin
  Node := TreeSearch(Key, Parent);
  Result := (Node <> nil);
end;

function TMap<TKey, TValue>.GetEnumerator;
begin
  Result := TMapNodeEnumerator<TKey, TValue>.Create(Root);
end;

// TMapEnumerator

constructor TMapNodeEnumerator<TKey, TValue>.Create(ARoot: TMapNode<TKey, TValue>);
begin
  Root := ARoot;
  Stack := TStack.Create;
end;

destructor TMapNodeEnumerator<TKey, TValue>.Destroy;
begin
  Stack.Free;
end;

function TMapNodeEnumerator<TKey, TValue>.GetCurrent;
begin
  if not Stack.AtLeast(1) then
    raise Exception.Create('GetCurrent called before MoveNext');
  Result := Stack.Peek;
end;

function TMapNodeEnumerator<TKey, TValue>.MoveNext;
var
  Node: TMapNode<TKey, TValue>;

begin
  // empty container?
  if Root = nil then Exit(False);

  // first MoveNext?
  if not Stack.AtLeast(1) then
  begin
    Stack.Push(Root);
    Exit(True);
  end;

  Node := Stack.Peek;
  if Node.Left <> nil then
  begin
    Stack.Push(Node.Left);
    Exit(True);
  end;
  if Node.Right <> nil then
  begin
    Stack.Push(Node.Right);
    Exit(True);
  end;

  while Stack.AtLeast(1) do
  begin
    Node := Stack.Pop;
    if (Node.Parent <> nil) and
      (Node = Node.Parent.Left) and (Node.Parent.Right <> nil) then
    begin
      Stack.Push(Node.Parent.Right);
      Exit(True);
    end;
  end;

  Exit(False); // reached end
end;

end.

