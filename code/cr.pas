{$mode objfpc}{$i xpc.inc}
unit cr; { cursor interfaces }
interface

  { here we describe a number of interfaces for traversing data types,
    independend of the data types themselves.

    A Cursor does the actual work of navigating back and
    forth along a Sequence. A Sequence can have any number
    of cursors moving around on it.
  }
  type
    generic reference<t> = interface
      function get_value : t;
      procedure set_value( v : t );
      property value : t read get_value write set_value;
      function is_readable : boolean;
      function is_writable : boolean;
    end;

    { iterator : 1-dimensional, but no index (ex: network streams) }
    generic IIterator<t> = interface( specialize reference<t> )
      function next( out val : t ) : boolean; { true result = success }
      function next : t; { raises exception on failure }
    end;

    { enumerator : 1-dimensional, indexed by number }
    generic Enumerator<t> = interface ( specialize IIterator<t> )
      procedure reset;
      function get_index : cardinal;
      property index : cardinal read get_index;
    end;

    { slider : 1-dimensinon, can move back and forth from origin }
    generic ISlider<t,idx> = interface( specialize Enumerator<t> )
      function prev( out val : t ) : boolean;
      function prev : t;
      procedure set_index( anIndex : idx );
      property index : idx read get_index write set_index;
    end;

    { abstract cursor : adds support for remembering positions }
    generic ICursor<t> = interface( specialize ISlider<t,cardinal> )
      procedure mark;
      procedure back;
    end;

implementation
end.
