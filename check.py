import json;
from os import system, pipe, close, fdopen

def msg(s):
    print('\033[1m\033[91m' + s + '\033[0m\033[0m');
def err(data_in, s):
    msg("Wrong on input " + str(data_in) + "\n" + s)
    exit(1)

f_ir = "./workdir/a.ir";
f_json = "./workdir/a.json";
program = "irsim/build/irsim"

for data_in, data_out, ret_val in json.load(open(f_json)):
    to_irsim_r  , to_irsim_w   = pipe()
    from_irsim_r, from_irsim_w = pipe()
    with fdopen(to_irsim_w, 'w') as to_irsim_w:
        for i in data_in:
            to_irsim_w.write(str(i) + '\n')

    ret = system(program + " " + f_ir + " <&" + str(to_irsim_r) + " >&" + str(from_irsim_w))
    # Suppose irsim is compiled by run.sh
    close(to_irsim_r)
    close(from_irsim_w)
    if ret != 0:
        err(data_in, "runtime error occured when running your IR code");
    with fdopen(from_irsim_r, 'r') as from_irsim_r:
        from_irsim_r.readline()
        # Filter out the first line "load ./workdir/a.ir"
        try:
            for i in data_out:
                if i != int(from_irsim_r.readline()):
                    err(data_in, "Output mismatch!(you output a wrong number?)")
            else:
                if "ret with 0, reason 0\n" != from_irsim_r.readline():
                    err(data_in, "Output mismatch!(you output more than supposed?)")
        except ValueError:
            err(data_in, "Output mismatch!(you output less than supposed?)")

exit(0);
