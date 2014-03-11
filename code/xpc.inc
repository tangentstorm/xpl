{ xpc.inc : include to ease cross-compiler portability }
{$IFDEF FPC}

  // language tweaks
  {$coperators on}              // += , etc.
  {$longstrings on}             // strings act as dynamic arrays
  {$macro on}                   // allow simple compiler macros
  {$modeswitch nestedprocvars}  // allow 'is nested'
  {$modeswitch unicodestrings}

  // memory layout
  {$packset 1}

  // safety
  {$assertions on}

  {$objectchecks on}
  {$overflowchecks on}
  {$rangechecks on}
  {$typedaddress on}
  {$checkpointer on}            // checks pointers for nil (when -gh used)

  // things to disallow because they're bad practice
  {$writeableconst off} // ancient. use initialized vars instead
  {$goto off}

{$ENDIF}
