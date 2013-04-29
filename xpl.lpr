{$i xpc.inc}
program xpl;

// This program is only here to allow compiling all the units at once
// and navigating inside lazarus. For actual demos, see the demo/ diretory.
// ( also see https://github.com/tangentstorm/silverware )

uses
  sysutils,
  {--- xpc stuff --}
  arrays,
  ascii,
  bp,
  build,
  chk,
  cli,
  cr,
  cw,
  cx,
  di,
  { dm, }
  fs,
  fx,
  { gn, }
  Grids,
  gt,
  { hz, }
  kbd,
  kvm,
  li,
  ll,
  log,
  mou,
  num,
  oo,
  os,
  posix,
  sq,
  stacks,
  stri,
  tm,
  ui,
  utf8,
  vid,
  vt,
  xpc;

begin
  Writeln( tm.StarDate, ' - hello world' );
end.

