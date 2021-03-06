{ brx : generic ("brand x") container types     }
{ ---------------------------------------------

  This file defines a bunch of specializations of
  generic types. The idea is that when you create
  a generic class parameterized on type <t>, you
  automatically have access to a bunch of other
  generic types, without having to specialize
  each one by hand.

  -------------------------------------------- }
{$ifdef brx_example_code}
    unit brx_example;
    interface uses cursors, lists;
      type
        generic TWhatever<t> = class
          {$i brx.inc}
          list : brx.list; // specialize ll.list<t>
          dyna : brx.dyna; // dynamic array of t
        end;
    implementation
    end. { of unit brx_example }
{$endif}
{ --------------------------------------------

  Supported types:

  Include the following units to automatically
  provide support for their corresponding
  generic types:

    - stacks
    - ll       (for linked lists/rings)

  Coming soon:

    - monads
    - cursors
    - dynamic arrays
    - hashmaps
    - trees

  custom types:

  You can also include your own types in this
  list, by defining the symbol =brx_custom=.

  -------------------------------------------- }

type brx = class

  {$ifndef brx_t}
  private type brx_t = t;
  {$endif}

  public type

    stack    = specialize stacks.stack<brx_t>;
    list     = specialize ll.list<brx_t>;

    {-- user-configurable generic types ----------}
    {$ifdef brx_custom}
      {$define brx_section := functags}
      {$i brx_custom.def}
    {$else}
      {$ifndef brx_vorunati}
        type brx_sigtype = vorunati;
      {$endif}
    {$endif}

    dynarray = array of brx_t;
    func     = record
		 case sig : brx_sigtype of
		   {$ifdef brx_custom}
                     {$define brx_section := funcsigs}
		     {$i brx_custom.def}
		   {$else}
		     vo : ( vo : procedure is nested );
		     ru : ( ru : function( obj : brx_t ) : brx_t is nested );
		     na : ( na : procedure( obj : brx_t ) is nested );
		     ti : ( ti : function : brx_t is nested );
		   {$endif}
	       end;
end;
