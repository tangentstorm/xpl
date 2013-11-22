{$mode objfpc}
unit udir;
interface uses sysutils;

type
  TFileWalker = class
    private
      _done  : boolean;
      stack : array of TSearchRec;
      depth : cardinal;
      _mask : string;
      first : boolean;
      justPopped : boolean;
      function GetCurrent : TSearchRec;
    public
      property Done : boolean read _done;
      constructor Create( mask : String );
      function next : TSearchRec;
    public { Enumerable Interface }
      property Current : TSearchRec read GetCurrent;
      function GetEnumerator : TFileWalker;
      function MoveNext : boolean;
    end;

  function find( mask : string ) : TFileWalker;

implementation
constructor TFileWalker.Create( mask : String );
  begin
    SetLength(stack, 1);
    _mask := mask;
    depth := 0;
    _done  := false;
    first := true;
  end;

function TFileWalker.GetCurrent : TSearchRec;
   begin
     result := stack[ depth ]
   end;

function TFileWalker.GetEnumerator : TFileWalker;
  begin
    result := self;
  end;

function isDir(sr:TSearchRec): boolean;
  begin
    result := sr.Attr and faDirectory = faDirectory
  end;

function TFileWalker.MoveNext : boolean;
  procedure proceed(justPopped:boolean = false);
    function unvisited : boolean;
      begin
        result := IsDir(current) and not justPopped
                  and (current.name<>'.')
                  and (current.name<>'..')
      end;
    begin
      if first then
        begin
          _done  := FindFirst( _mask, faAnyFile and faDirectory, stack[ depth ]) <> 0;
          first := false;
        end
      else if unvisited then
        begin
          SetCurrentDir(current.name);
          inc(depth); setlength(stack, depth + 1);
          FindFirst( _mask, faAnyFile and faDirectory, stack[ depth ]);
        end
      else if FindNext(stack[ depth ]) = 0 then
        begin end { normal case. nothing more to do. yay. }
      else
        begin
          if depth = 0 then _done := true
          else
            begin
              FindClose(stack[depth]);
              setlength(stack, depth);
              dec(depth);
              SetCurrentDir('..');
              proceed(true);
            end
        end;
    end;
  begin
    proceed( false );
    result := not _done
  end;

function TFileWalker.next : TSearchRec;
  begin
    MoveNext; result := current;
  end;

function find( mask : string ) : TFileWalker;
  begin
    result := TFileWalker.Create( mask )
  end;

begin
end.
