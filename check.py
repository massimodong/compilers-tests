import json
from os import system
from itertools import count

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

for data_in, data_out, ret_val in json.load(open(f_json)):
    with open(spim_in, 'w') as to_spim_w:
        for i in data_in:
            to_spim_w.write(str(i) + '\n')

    ret = system(f"{program} {spim_file} < {spim_in} 2>/dev/null | grep --invert-match 'Enter an integer:' > {spim_out}")
    # Suppose irsim is compiled by run.sh
    if ret != 0:
        with open(spim_out, 'r') as from_spim_r:
            err(data_in,
                "runtime error occured when running your IR code\n"
                + from_spim_r.read().splitlines()[-1]);
    with open(spim_out, 'r') as from_spim_r:
        list(zip(range(5), from_spim_r))
        # Filter out the first line "load ./workdir/a.ir"
        try:
            for idx, expect, user_out in zip(count(1), data_out, from_spim_r):
                user_out = int(user_out)
                if expect != user_out:
                    err(data_in, "Output mismatch! expected %d, found %d at line %d" % (expect, user_out, idx));
            else:
                pass
                #if "ret with 0, reason 0\n" != from_spim_r.readline():
                #    err(data_in, "Output mismatch!(you output more than supposed?)")
                #with open("./workdir/count", "r+") as f:
                #    cnt = int(from_spim_r.readline()) + int(f.read())
                #    f.seek(0)
                #    f.write(str(cnt))
        except ValueError:
            err(data_in, "Output mismatch!(you output less than supposed?)")

exit(0)
