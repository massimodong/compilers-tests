import json;

def msg(s):
    print('\033[1m\033[91m' + s + '\033[0m\033[0m');

f_ir = "./workdir/a.ir";
f_json = "./workdir/a.json";

ref_list = json.load(open(f_json));

for data_in, data_out, ret_val in ref_list:
    if False:
        msg("Something wrong happens");
        exit(1);

exit(0);
