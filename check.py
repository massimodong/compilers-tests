import json;
from os import system, pipe, close, fdopen

def msg(s):
    print('\033[1m\033[91m' + s + '\033[0m\033[0m');
def err(data_in, s):
    msg("Wrong on input" + str(data_in) + "\n")
    msg(s)
    exit(1)

f_ir = "./workdir/a.ir";
f_json = "./workdir/a.json";
program = "irsim/build/irsim"

ref_list = json.load(open(f_json));

for data_in, data_out, ret_val in ref_list:
    to_irsim_r, to_irsim_w = pipe()
    from_irsim_r, from_irsim_w = pipe()
    to_irsim_w= fdopen(to_irsim_w, 'w')
    from_irsim_r= fdopen(from_irsim_r, 'r')
    for i in data_in:
        to_irsim_w.write(str(i) + '\n')
    to_irsim_w.close()

    print program + " " + f_ir + " <&" + str(to_irsim_r) + " >&" + str(from_irsim_w)
    ret = system(program + " " + f_ir + " <&" + str(to_irsim_r) + " >&" + str(from_irsim_w))
    # suppose irsim is compiled by run.sh
    close(from_irsim_w)
    if ret != 0:
        err(data_in, "Return value of irsim is %d instead of"%(ret));
    from_irsim_r.readline()
    # filter out first line "load ./workdir/a.ir"
    try:
        for i in data_out:
            if i != int(from_irsim_r.readline()):
                err(data_in, "Output mismatch!(you output a wrong number?)")
        else:
            if "ret with 0, reason 0\n" != from_irsim_r.readline():
                err(data_in, "Output mismatch!(you output more than supposed?)")
    except ValueError:
        err(data_in, "Output mismatch!(you output less than supposed?)")
    from_irsim_r.close()

exit(0);
