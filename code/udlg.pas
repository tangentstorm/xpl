{ wrapper functions to invoke the 'dialog' command for freebsd/linux

  http://invisible-island.net/dialog/

  this unit is in the public domain.

  example usage:

  program dlg;
  uses udlg;
  begin
    writeln(udlg.menu('hello', 20, 50, 18, ['a','apple','b','banana']));
  end.

}
{$WARNING Parameters to dlg commands are not sanitized. do not use in real code! (TODO)}
{$i xpc}{$mode delphi}{ dialog example }
unit udlg;
interface
{$IFDEF UNIX}
uses unix, sysutils;

  type TStr = rawbytestring;
  var tmpfile : TStr = 'x.txt';
  function dialog(cmd, argfmt : TStr; argv : array of const) : TStr;
  function menu(title : TStr; h,w,mh : byte; options: array of TStr) : TStr;
  function fselect(path : TStr; h,w : byte) : TStr;
{$ENDIF}

implementation

{$IFDEF UNIX}
function readln(var f : textfile) : TStr;
  begin
    system.readln(f, result);
  end;

function contentsof(path : TStr) : TStr;
  var f : textfile;
  begin
    result := '';
    assign(f,path); reset(f);
    while not eof(f) do result += readln(f);
  end;

function strjoin(chunks : array of TStr; sep : TStr = '') : TStr;
  var i : integer;
  begin
    result := '';
    for i := low(chunks) to high(chunks)-1 do
      result += chunks[i] + sep;
    result += chunks[high(chunks)];
  end;

function dialog(cmd, argfmt : TStr; argv : array of const) : TStr;
  var args : TStr;
  begin
    args := format(argfmt, argv);
    fpsystem(format('dialog --%s %s 2> %s ', [cmd, args, tmpfile]));
    result := contentsof(tmpfile);
  end;

function menu(title : TStr; h,w,mh : byte; options: array of TStr) : TStr;
  begin
    result := dialog('menu', '"%s" %d %d %d %s',
		     [title, h, w, mh, strjoin(options, ' ')])
  end;

function fselect(path : TStr; h,w : byte) : TStr;
  begin
    result := dialog('fselect', '"%s" %d %d', [h, w])
  end;
{$ENDIF}
begin
end.