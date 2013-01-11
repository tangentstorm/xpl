{ xpc.inc : include to ease cross-compiler portability }
{$IFDEF FPC}
  {$mode objfpc}
  {$modeswitch nestedprocvars}

  {$assertions on}
  {$goto off}
  {$longstrings on}
  {$objectchecks on}
  {$overflowchecks on}
  {$rangechecks on}
  {$macro on}

  {$writeableconst off}
  {$typedaddress on}
{$ENDIF}
