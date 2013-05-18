// red black trees

// found at:
//    http://www.lazarus.freepascal.org/index.php?topic=17902.0
// Written by greenfish (2012)
// Released into public domain

// changes by @tangentstorm
// - search and replace TMap -> TRBMap
// - reformatted
// - switched to my generic stack class

{$mode delphi}
unit rb;
interface uses SysUtils, stacks;

  type
  TRBMapNode<TKey, TValue> = class
  private
    IsBlack: boolean;
    Left, Right, Parent: TRBMapNode<TKey, TValue>;
    FKey: TKey;
  public
    Value: TValue;
    property Key: TKey read FKey;
    constructor Create;
    destructor Destroy; override;
  end;

  TRBMapNodeEnumerator<TKey, TValue> = class
  private
    type TNode  = TRBMapNode<TKey, TValue>;
    type TStack = GStack<TNode>;
  private
    Root:  TNode;
    Stack: TStack;
    function GetCurrent: TRBMapNode<TKey, TValue>;
  public
    constructor Create(ARoot: TRBMapNode<TKey, TValue>); virtual;
    destructor Destroy; override;
    function MoveNext: Boolean;
    property Current: TRBMapNode<TKey, TValue> read GetCurrent;
  end;

  // Implements a map with a red-black tree
  TRBMap<TKey, TValue>= class
   protected
    FCount : integer;
    Root   : TRBMapNode<TKey, TValue>;
    function TreeSearch(const Key	 : TKey;
			      out Parent : TRBMapNode<TKey, TValue>): TRBMapNode<TKey, TValue>;
    procedure LeftRotate(x: TRBMapNode<TKey, TValue>);
    procedure RightRotate(x: TRBMapNode<TKey, TValue>);
    function TreeInsertIfNotExist(const Key: TKey): TRBMapNode<TKey, TValue>;
    function GetValue(const Key: TKey): TValue;
    procedure SetValue(const Key: TKey; const Value: TValue);
   public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear;
    function SafeGet(const Key: TKey): TValue;
    function ContainsKey(const Key: TKey): boolean;
    function GetEnumerator: TRBMapNodeEnumerator<TKey, TValue>;
    property Count: integer read FCount;
    property Values[Key: TKey]: TValue
      read GetValue write SetValue; default;
  end;

implementation

// TRBMapNode

  constructor TRBMapNode<TKey, TValue>.Create;
    begin
      IsBlack := False;
      Left := nil;
      Right := nil;
      Parent := nil;
      FKey := Default(TKey);
      Value := Default(TValue);
    end;

  destructor TRBMapNode<TKey, TValue>.Destroy;
    begin
      if Left <> nil then Left.Free;
      if Right <> nil then Right.Free;
      inherited;
    end;

// TRBMap

  function TRBMap<TKey, TValue>.TreeSearch;
    begin
      Result := Root;
      Parent := nil;
      while Result <> nil do
        begin
	  if Key = Result.Key then Break;
	  Parent := Result;
	  if Key < Result.Key then Result := Result.Left
	  else Result := Result.Right;
	end;
      // Result = nil -> not found
    end;

  procedure TRBMap<TKey, TValue>.LeftRotate;
    var
      y	: TRBMapNode<TKey, TValue>;
    begin
      y := x.Right;

      x.Right := y.Left;
      if y.Left <> nil then y.Left.Parent := x;

      y.Parent := x.Parent;

      if x.Parent = nil then Root := y
      else if x = x.Parent.Left then x.Parent.Left := y
      else x.Parent.Right := y;

      y.Left := x;
      x.Parent := y;
    end;

  procedure TRBMap<TKey, TValue>.RightRotate;
    var y: TRBMapNode<TKey, TValue>;
    begin
      y := x.Left;

      x.Left := y.Right;
      if y.Right <> nil then y.Right.Parent := x;

      y.Parent := x.Parent;

      if x.Parent = nil then Root := y
      else if x = x.Parent.Left then x.Parent.Left := y
      else x.Parent.Right := y;

      y.Right := x;
      x.Parent := y;
    end;

  function TRBMap<TKey, TValue>.TreeInsertIfNotExist;
    var Node, Parent, y: TRBMapNode<TKey, TValue>;
    begin
      // already exists?
      Node := TreeSearch(Key, Parent);
      if Node <> nil then Exit(Node);

      // create the node
      Node := TRBMapNode<TKey, TValue>.Create;
      inc(FCount);
      Result := Node;
      Node.FKey := Key;

      // link
      if Parent <> nil then
        begin
	  if Key < Parent.Key then Parent.Left := Node
	  else Parent.Right := Node;
	  Node.Parent := Parent;
	end else Root := Node;

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
	      end
	    else // y is a black node
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
	  end
	else
	  begin
	    y := Node.Parent.Parent.Left;
	    if (y <> nil) and not y.IsBlack then
	      begin
		Node.Parent.IsBlack := True;
		y.IsBlack := True;
		Node.Parent.Parent.IsBlack := False;
		Node := Node.Parent.Parent;
	      end
	    else // y is a black node
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

  function TRBMap<TKey, TValue>.GetValue;
    var Node, Parent: TRBMapNode<TKey, TValue>;
    begin
      Node := TreeSearch(Key, Parent);
      if Node = nil then
	raise Exception.Create('Map key does not exist')
      else Result := Node.Value;
    end;

  procedure TRBMap<TKey, TValue>.SetValue;
    begin
      TreeInsertIfNotExist(Key).Value := Value;
    end;

  constructor TRBMap<TKey, TValue>.Create;
    begin
      FCount := 0;
      Root := nil;
    end;

  destructor TRBMap<TKey, TValue>.Destroy;
    begin
      Clear;
      inherited;
    end;

  procedure TRBMap<TKey, TValue>.Clear;
    begin
      FCount := 0;
      FreeAndNil(Root);
    end;

  function TRBMap<TKey, TValue>.SafeGet;
    var Node, Parent : TRBMapNode<TKey, TValue>;
    begin
      Node := TreeSearch(Key, Parent);
      if Node = nil then
	Result := Default(TValue)
      else Result := Node.Value;
    end;

  function TRBMap<TKey, TValue>.ContainsKey;
    var Node, Parent: TRBMapNode<TKey, TValue>;
    begin
      Node := TreeSearch(Key, Parent);
      Result := (Node <> nil);
    end;

  function TRBMap<TKey, TValue>.GetEnumerator;
    begin
      Result := TRBMapNodeEnumerator<TKey, TValue>.Create(Root);
    end;

// TRBMapEnumerator

  constructor TRBMapNodeEnumerator<TKey, TValue>.Create(ARoot: TRBMapNode<TKey, TValue>);
    begin
      Root := ARoot;
      Stack := TStack.Create(256); // arbitrary height
    end;

  destructor TRBMapNodeEnumerator<TKey, TValue>.Destroy;
    begin
      Stack.Free;
    end;

  function TRBMapNodeEnumerator<TKey, TValue>.GetCurrent;
    begin
      if not Stack.count >= 1 then
	raise Exception.Create('GetCurrent called before MoveNext');
      Result := Stack.Peek;
    end;

  function TRBMapNodeEnumerator<TKey, TValue>.MoveNext;
    var Node : TRBMapNode<TKey, TValue>;
    begin
      // empty container?
      if Root = nil then Exit(False);

      // first MoveNext?
      if not Stack.count >= 1 then
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

      while Stack.count >= 1 do
        begin
	  Node := Stack.Pop;
	  if (Node.Parent <> nil)
	    and (Node = Node.Parent.Left)
	    and (Node.Parent.Right <> nil)
	  then
	    begin
	      Stack.Push(Node.Parent.Right);
	      Exit(True);
	    end;
	end;
      Exit(False); // reached end
    end;

end.
