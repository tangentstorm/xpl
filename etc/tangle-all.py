"""
Tangles all items in the ./text (or dir specified in environ['ORG'])

This writes hidden *.last-tangled files that act as timestamps, because
the tangling process is a bit slow.

It writes them to the ./text directory rather than to ./gen
because I don't want to force a dependency on emacs, and thus
include the tangled files and the timestamps in the git repo.

Eventually, I will have an org-compatable tangling tool in
pascal and all of this will just go away.
"""
import os, sys

orgdir = os.environ.get('ORG', 'org')
tangle = os.environ.get('TANGLE', 'etc/tangle.el')
always_regen = '-f' in sys.argv

for filename in os.listdir(os.path.expanduser(orgdir)):
    if filename.endswith('.org'):
        timepath = os.path.join('etc/stamps',
                                "." + filename[:-4] + '.last-tangled')
        filepath = os.path.join(orgdir, filename)
        regen =(always_regen
                or not os.path.exists(timepath)
                or os.path.getmtime(timepath) < os.path.getmtime(filepath))
        if regen:
            os.system('{0} {1}'.format(tangle, filepath))
            with open(timepath, 'w'): pass
