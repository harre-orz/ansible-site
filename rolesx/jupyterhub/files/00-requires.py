# ipywidgets
from __future__ import print_function
from ipywidgets import interact, interactive, fixed, interact_manual
import ipywidgets as widgets

# ref: https://gist.github.com/naka999/f1bcec9ea87b2870054fb8801509c352
from IPython import get_ipython

save_get_ipython_system = get_ipython().system
get_ipython().system = lambda x: get_ipython_system(x)

# interactiveshell.py's system_piped() function comment saids:
# "we store the exit_code in user_ns."
# this function check the exit_code and raise exception if it is not 0.
def get_ipython_system(cmd):
    save_get_ipython_system(cmd)
    if get_ipython().user_ns['_exit_code'] != 0:
        raise RuntimeError('Unexpected exit code: %d' % get_ipython().user_ns['_exit_code'])
