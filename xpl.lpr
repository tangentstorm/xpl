{$i xpc.inc}
program xpl;

// This program is only here to allow compiling all the units at once
// and navigating inside lazarus. For actual demos, see the demo/ diretory.
// ( also see https://github.com/tangentstorm/silverware )


uses
{ unit     | problem? | notes/description                                     }
{ ----------------------------------------------------------------------------}
  arrays,  // -docs?  | generic arrays
  ascii,   // ..!     | ascii character codes
  bp,      // -org    | b+ trees (untangled from org-mode... need to clean up)
  { brx }  // ??(.inc)| experimental generic type thing
  build,   // -path   | tree builder ... dotted paths not laz-friendly yet
  chk,     // -docs?  | assertion/unit test helpers
  cli,     // -silly  | a few colorful command line interface routines ( is this useful?)
  cr,      // ..      | generic cursor interface
  cw,      // -old    | colorwrite (quite useful but probably needs to be modernized)
  cx,      // -docs?  | colored expection tracebacks
  di,      // -weak   | simple dictionary-like type. TODO: see olliebol's type
  { dm, }  // !bad.py | doc model... (half-ported python code wrapped in pascal)
  fs,      // ?old    | file system
  fx,      // ?old    | user interface effects
  { gn, }  // !bad.py | generators (unfinished)
  grids,   // ..      | grids
  gt,      // ..      | graph theory routines
  { hz, }  // ??      | sound -- TODO: broken old dos stuff. won't compile. see gh:badsector/pasaudio?
  kbd,     // ..      | keyboard routine (makes new keyboard unit look more like old crt)
  kvm,     // (dup)   | kvm all-in-one TOOD: merge with vt,kbd,mou maybe kvm = interfaces?
  li,      // -weak   | lisp "interpreter"  TODO: use variants... also rename to sx ?
  ll,      // ~style  | linked list / tree data structure  TODO : clean up code and rename (...to???)
  log,     // -weak   | rudimentarylogging system
  mou,     // ??      | ancient mouse stuff TODO : replace / integrate with new mouse unit
  num,     // -old    | old numeric routines. probably good but need docs.
  oo,      // -weak   | this is not useful yet (i think brx uses it, and it does define vo,ru,na,ti)
  os,      // -weak   | os.thisdir TODO: port python style stuff
  posix,   // -weak   | only has 1 function: posix.time -> int64 TODO: either expand or delet this
  sq,      // 2.7.1   | generic sequences / interfaces. I like this but it won't compile in 2.6.2 :/
  stacks,  // style   | generic stacks. TODO: extract interface... object -> class
  stri,    // -old    | string routines. TODO: cf http://freepascal.org/docs-html/rtl/strutils/
  tm,      // -silly  | my old "startdate" date format :) (see output of this)
  ui,      // mixed   | tex-based/semigraphic UI widgets . Good stuff but needs work.
  utf8,    // -weak   | rudimentary utf8 encode/decode. probably not useful.
  vid,     // (dup)   | ovelaps with vt
  vt,      // ..      | virtual terminal + interface. mostly good/working. TODO: write/writeln
  xpc;     // ...     | general handy routines

begin
  Writeln( tm.StarDate, ' - hello world' );
end.

