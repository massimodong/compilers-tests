import json
from os import system
from itertools import count, zip_longest

def msg(s):
    print('\033[1m\033[91m' + s + '\033[0m\033[0m');
def err(data_in, s):
    msg("Wrong on input " + str(data_in) + "\n" + s)
    exit(1)

spim_file = "./workdir/a.s";
f_json    = "./workdir/a.json";
program   = "spim -file"
spim_in   = './workdir/spim_in'
spim_out  = './workdir/spim_out'
flags = ''

def only_nums(g):
    for s in g:
        try:
            i = int(s)
            yield i
        except ValueError:
            pass

for data_in, data_out, ret_val in json.load(open(f_json)):
    with open(spim_in, 'w') as to_spim_w:
        for i in data_in:
            to_spim_w.write(str(i) + '\n')

    ret = system(f"{program} {flags} {spim_file} < {spim_in} 2>/dev/null | sed -e s/'\(Enter an integer:\)\+'/''/ > {spim_out}")
    # Suppose irsim is compiled by run.sh
    if ret != 0:
        with open(spim_out, 'r') as from_spim_r:
            err(data_in,
                "runtime error occured when running your IR code\n")
    with open(spim_out, 'r') as from_spim_r:
        # Filter out the first line "load ./workdir/a.ir"
        try:
            for idx, (expect, user_out) in enumerate(zip_longest(data_out, only_nums(from_spim_r))):
                if expect != user_out:
                    err(data_in, "Output mismatch! expected %d, found %d at line %d" % (expect, user_out, idx));
            else:
                pass
        except ValueError:
            err(data_in, "Output mismatch!(you output less than supposed?)")

exit(0)
