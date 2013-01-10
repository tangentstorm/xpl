(*
// brx : generic ("brand x") container types
// ----------------------------------------------
//  usage:
//
//  type generic TWhatever<t> = class
//    {$i brx.inc}
//    // or, to wrap in a namespace:
//    public class brx = {$i brx.inc} end;
//  end;
//
//---------------------------------------------- *)

type brx = class

 private type  
   brx_t = t;

  public type

    {$ifdef brx_stacks}
    stack    = specialize stacks.stack<brx_t>;
    {$endif} 
    {$ifdef brx_lists}
    list     = specialize ll.list<brx_t>;
    {$endif}

    {$ifdef brx_custom}
    {$define brx_section := functags}
    {$i brx_custom.def}
    {$else}
    type brx_sigtype = ( _vo, _ru, _na, _ti );
    {$endif}

    dynarray = array of brx_t;
    func     = record
		 case brx_sigtype of
		   {$ifdef brx_custom}
		   {$define brx_section := funcsigs}
		   {$i brx_custom.def}
		   {$else}
		   _vo : ( vo : procedure is nested );
		   _ru : ( ru : function( obj : brx_t ) : brx_t is nested );
		   _na : ( na : procedure( obj : brx_t ) is nested );
		   _ti : ( ti : function : brx_t is nested );
		   {$endif}
	       end;
end;
