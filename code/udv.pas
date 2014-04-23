// udbv : database-driven termview components
//
// Copyright © 2014 Michal J Wallace http://tangentstorm.com/
// Available for use under the MIT license. See LICENSE.txt
//
{$i xpc.inc}{$mode delphiunicode}
unit udv;
interface uses xpc, utv, udb, udc, kvm, classes, db, sqldb, ustr, kbd, cw,
  ug2d, umsg;

type
  TDBTreeGrid = class (TView)
    protected
      _top : cardinal;
      _cur : TDbCursor;
      procedure Render; override;
    public
      procedure Handle( msg : umsg.TMsg ); override;
    published
      property DataCursor : TDbCursor read _cur write _cur;
    end;

  TDBMenu = class (utv.TTermView)
    public
      rs : TRecordSet;
      key: string;
      OnSave : procedure (val:variant) of object;
      function Choose : variant;
    end;


implementation

{---------------------------------------------------------------}
{ TDbTreeGrid                                                   }
{---------------------------------------------------------------}
procedure TDbTreeGrid.Render;
  var sigil : char = ' '; count : cardinal = 0; rs : TRecordSet;
begin
  bg('b'); fg('W');   rs := _cur.RecordSet.open.first;
  while (count < yMax) and not rs.eof do
    begin
      if rs['leaf'] then sigil := ' '
      else if rs['collapsed'] then sigil := '+'
      else sigil := '-';
      { draw visible nodes }
      if rs['hidden'] then ok
      else begin
	if _cur.AtMark then if _focused then bg(hibar) else bg(lobar)
	else bg(nobar);
	gotoxy(0,count);
        { draw the outline controls }
	if rs['depth']>0 then write(ntimes(' ', rs['depth']*2));
	fg('r'); write(sigil +  ' ');
        { draw the node itself }
        fg('c'); write(rs['kind'],' ');
	fg('W'); write(rs['node']);
        { clear the rest of the line }
	clreol; inc(count);
      end;
      rs.Next;
    end;
  bg('k'); { clear to bottom of screen }
  while count < kvm.yMax do begin
    gotoxy(0,count); clreol; inc(count)
  end
end;



procedure TDbTreeGrid.Handle( msg : umsg.TMsg );
  begin if msg.code = msg_nav_up.code then _cur.Prev
   else if msg.code = msg_nav_dn.code then _cur.Next
   else if msg.code = msg_nav_top.code then _cur.ToTop
   else if msg.code = msg_nav_end.code then _cur.ToEnd
   else ok
  end;


{---------------------------------------------------------------}
{ TDbMenu                                                       }
{---------------------------------------------------------------}
//  TODO : finish refactoring TDBMenu, extract themes.
function TDBMenu.Choose : variant;
  var
    _rs : TRecordSet;    // the data to choose from
    _cr : TDbCursor;     //
    _ws : array of byte; // column widths
    done:boolean=false; cancel:boolean = false;
  procedure SetUp;
    begin
      _rs := rs.Open.First;
      _cr := TDbCursor.Create(self).Attach(_rs, key);
      _ws := bytes([0, 16]);
    end;
  procedure DrawMenu;
    var i : integer; f : TField;
    begin
      cwrite('|@0000|!K|W|$'); i := 0;
      for f in _rs.fields do write(rfit(f.DisplayName, _ws[vinc(i)]));
      _rs.First;
      while not _rs.EOF do
        begin
          i:=0; cwriteln('|k');
          if _cr.AtMark then bg('B') else bg('w');
          for f in _rs.fields do write(rfit(f.DisplayText, _ws[vinc(i)]));
          _rs.Next;
        end;
      _cr.ToMark;
    end; { DrawMenu }
  procedure interact;
    var ch : char;
    begin repeat until keypressed;
      case readkey(ch) of
	'n', ^N : _cr.Next;    ^M : done := true;
	'p', ^P : _cr.Prev;    ^C: cancel := true;
        else cwritexy(15, 0, '|Gch: |g' +ch)
      end
    end; { interact }
  procedure TearDown;
    begin _cr.RecordSet:=nil; _cr.Free;
    end;
  begin { choosetype }
    SetUp;
    repeat DrawMenu; Interact until cancel or done;
    if cancel then result := nil
    else begin
      result := rs[key];
      if assigned(OnSave) then OnSave(result);
    end;
    TearDown;
  end;

initialization
  RegisterClass(TDbMenu);
  RegisterClass(TDbTreeGrid);
end.
