import json;
import re;

def msg(s):
    print('\033[1m\033[91m' + s + '\033[0m\033[0m');

f_out = "./workdir/a.out";
f_json = "./workdir/a.json";
pattern = re.compile(r"Error type (\d+) at Line (\d+): .*\.");

ref_list = json.load(open(f_json));
out = open(f_out);

require = {};
resolve = {};
allow = {};

if "require" in ref_list:
    for err in ref_list["require"]:
        require[err] = 0;
        for x, y in ref_list["require"][err]:
            if (x, y) in resolve:
                resolve[(x, y)].append(err);
            else:
                resolve[(x, y)] = [err];

if "allow" in ref_list:
    for x, y in ref_list["allow"]:
        allow[(x, y)] = True;

while True:
    l = out.readline();
    if(l == ""):
        break;

    m = pattern.match(l);
    if(not m):
        msg("Wrong output format!")
        exit(1);
    x, y = m.groups();
    pos = (int(x), int(y))

    if pos in resolve:
        for err in resolve[pos]:
            require[err] = 1;
    elif pos in allow:
        pass;
    else:
        msg("Not allowed error %d at line %d.\nPlease add it to corresponding .json file if you think your output is reasonable." % (pos));
        exit(1);

for err in require:
    if require[err] == 0:
        msg("You should output at least one of the following erros:");
        for x, y in ref_list["require"][err]:
            msg("- Error %d at line %d." % (int(x), int(y)));
        exit(1);

exit(0);
