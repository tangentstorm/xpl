{$mode delphiunicode}{$i xpc.inc}{$i test_kvm.def}
implementation uses kvm, num;

type
  TSubroutine =  procedure (reps : byte) is nested;
  TMemData    = record before, after: cardinal; diff : integer end;

function HeapReport(sub : TSubroutine; x : byte= 1) : TMemData;
  var mgr : TMemoryManager;
  begin
    GetMemoryManager(mgr);
    result.before := mgr.GetHeapStatus.TotalAllocated;
    sub(x);
    result.after := mgr.GetHeapStatus.TotalAllocated;
    result.diff := result.after - result.before;
  end;

{ there was a massive memory leak when using subterm/popterm. }

procedure test_memleaks_0;
  procedure subtermRamUsage(numterms : byte);
    var i : byte;
    begin for i := 1 to numterms do subterm(0, 0, 10, 10);
          for i := 1 to numterms do popterm;
    end;
  var report : TMemData;
  begin
    report := HeapReport(subtermRamUsage, 1);
    { it's not clear to me what the units are, but the result should be 0... }
    chk.equal(0, report.diff, 'memory grew when using 1 subterm');

    
    { the leak only occurred with nested subterms. }
    { this was because each subterm kept a reference to its surrounding term }
    report := HeapReport(subtermRamUsage, 2);
    chk.equal(0, report.diff, 'memory grew when using 2 subterms');
  end;

{ it looked like the culprit might be TGridTerm... }
procedure test_memleaks_1;
  procedure cycle_gridterm_as_class(_ :byte);
    begin TGridTerm.Create(10, 10).free
    end;
  procedure cycle_gridterm_interface(n:byte);
    var i : byte; term : ITerm;
    begin for i := 1 to n do term := TGridTerm.Create(10, 10)
    end;
  procedure cycle_gridterm_asterm(n:byte);
    var i : byte; core : TGridTerm; term : ITerm;
    begin
      for i := 1 to n do begin
	core := TGridTerm.Create(10, 10);
	term := core.asterm; term := nil;
	core.free;
      end;
    end;
  var report : TMemData;
  begin
    report := HeapReport(cycle_gridterm_as_class);
    chk.equal(0, report.diff, 'cycle_gridterm_as_class grew ram');
    report := HeapReport(cycle_gridterm_interface);
    chk.equal(0, report.diff, 'cycle_gridterm_interface grew ram');
  end;



procedure test_memleaks_2;
  procedure cycle_gridterm_asterm(n:byte);
    var i : byte; core : TGridTerm; term : ITerm;
    begin
      for i := 1 to n do begin
	term := TGridTerm.Create(10, 10).asterm;
	term := nil;
      end;
    end;
  var report : TMemData;
  begin
    report := HeapReport(cycle_gridterm_asterm);
    chk.equal(0, report.diff, 'cycle_gridterm_asterm grew ram');
  end;


procedure test_hookterm;
  var base : kvm.TBaseTerm; hook : kvm.THookTerm; old : word;
  begin
    old := kvm.textattr;
    try
      hook := THookTerm.Create;

      // by default, hooks should read from kvm.work
      chk.equal(old, hook.textattr);
      kvm.textattr := $abcd;             // update kvm
      chk.equal($abcd, hook.textattr);   // ... and the hook should see it
      
      hook.textattr := $1234;           // update the hook
      chk.equal($1234, kvm.textattr);   // ... and kvm changes too
      chk.equal($1234, hook.textattr);
      chk.equal($1234, hook.asterm.textattr);

      // we can hook other objects, too:
      base := TBaseTerm.Create(10,10);
      base.textattr := $9999;
      chk.equal($9999, base.textattr);

      hook.subject := base;
      hook.textattr := $1234;
      chk.equal($1234, base.textattr);
      hook.asTerm.textattr := $2345;
      chk.equal($2345, base.textattr);

//      base.free;
    finally kvm.textattr := old end;
  end;


begin 
end.
