"""
this generates a a bunch of small include files
so that i can write tests just by writing new
procedures. ( it also generates the definitions )
"""
import os
import sys

GEN = sys.argv[ 1 ] if len( sys.argv ) == 2 else '.'

topuse = open( GEN + '/run-tests.use', 'w' )
toprun = open( GEN + '/run-tests.run', 'w' )
for path in map( str.strip, os.popen( 'ls test_*.pas' )):
    unit_name = '.'.join(path.split( '.' )[:-1])
    topuse.write(",%s\n" % unit_name)
    subdef = open( GEN + '/' + unit_name + '.def', 'w' )
    subdef.write( 'unit {0};\ninterface uses chk;\n'.format( unit_name ))
    has_setup = False
    for line in map( lambda s : s.lower().strip(), open( path )):
        if line.startswith( 'procedure setup' ):
            has_setup = True
            subdef.write(' %s\n' % line)
        if line.startswith( 'procedure test_' ):
            subdef.write(' %s\n' % line)
            test_name = line.split( ' ', 1 )[ 1 ]
            test_name = test_name[ : -1 ] # strip final ";"
            if has_setup:
                toprun.write("%s.setup;\n" % unit_name)
            toprun.write("run( '%s', '%s', @%s.%s );\n"
                         % ( unit_name, test_name, unit_name, test_name ))
    subdef.close()
topuse.close()
toprun.close()
