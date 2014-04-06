#!/usr/bin/env python
"""
this program generates test stubs in ../test for units in ../code
"""
import os.path
test_dir = os.path.join(os.path.dirname(__file__), '../test/')
code_dir = os.path.join(os.path.dirname(__file__), '../code/')

tests = [item for item in os.listdir(test_dir)
         if item.startswith('test_') and item.endswith('.pas')]

for item in os.listdir(code_dir):
    if item.endswith('pas'):
        test_unit = 'test_' + item
        unit_name = '.'.join(item.split( '.' )[:-1])
        if test_unit not in tests:
            f = open(os.path.join(test_dir, test_unit), 'w')
            f.write('{$mode delphiunicode}{$i xpc.inc}{$i test_%s.def}\n'
                    % unit_name)
            f.write('implementation uses %s;\n' % unit_name)
            f.write('\n')
            f.write('end.\n')
            f.close()
