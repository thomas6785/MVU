"""
Expects an output from AGU test in an output.txt file

Run:
    xvlog -sv agu.sv
    xelab test_agu -s tb_sim
    xsim tb_sim -runall -sv_seed 2 # change seed to anything (but don't leave it out - it will default to the same thing every time...)
    python3 models/agu_python_model.py

It should print "All good" if the model matches the SV output

Note:
- the 'lengths' are actually one less than the number of iterations
- only one jump takes place on any given clock cycle - they don't 'stack' in one clock cycle (which I suppose makes sense because of hardware limitations)
- if the address under/overflows it wraps around (modulo 2^BWADDR)
"""

addr_out = 0
BWADDR = 21

with open("output.txt", "r") as f:
    lines = f.readlines()

# config line has format (e.g.):
# l='{2,3,4,1} j='{8,1,1,3,2}
config_line = lines[0].replace("l='","").replace("j='","")
config_line = config_line.replace("{","").replace("}","")
l_raw,j_raw = config_line.split(" ")
ls = [int(i) for i in l_raw.split(",")]
js = [int(i) for i in j_raw.split(",")]
l4,l3,l2,l1 = ls
j4,j3,j2,j1,j0 = js

print("Configuration:" \
    f"\n\tl1={l1} l2={l2} l3={l3} l4={l4}" \
    f"\n\tj0={j0} j1={j1} j2={j2} j3={j3} j4={j4}")

expected = [int(line.strip()) for line in lines[2:]] # skip line 1 which is an x

verbose = False
def check_output(addr_out):
    if len(expected) == 0:
        raise StopIteration("No more expected outputs to check")
    this_exp = expected.pop(0)
    if verbose:
        print(f"Checking output: expected {this_exp}, got {addr_out}")
    if addr_out == this_exp:
        return
    else:
        print(f"Error: expected {this_exp}, got {addr_out}")
        exit(1)

try:
    while expected:
        for i1 in range(l1+1,0,-1):
            for i2 in range(l2+1,0,-1):
                for i3 in range(l3+1,0,-1):
                    for i4 in range(l4+1,0,-1):
                        check_output(addr_out)
                        addr_out += j4 ; addr_out %= 2**BWADDR
                    addr_out += j3-j4 ; addr_out %= 2**BWADDR
                addr_out += j2-j3 ; addr_out %= 2**BWADDR
            addr_out += j1-j2 ; addr_out %= 2**BWADDR
        addr_out += j0-j1 ; addr_out %= 2**BWADDR
except StopIteration:
    print(f"All good")
