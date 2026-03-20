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


##########################################################################
# Read in expected values + config from file
##########################################################################

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

def sim_agu(l1,l2,l3,l4,j0,j1,j2,j3,j4,length):
    res = []
    addr_out = 0
    while True:
        for i1 in range(l1+1,0,-1):
            for i2 in range(l2+1,0,-1):
                for i3 in range(l3+1,0,-1):
                    for i4 in range(l4+1,0,-1):
                        res.append(addr_out)
                        if len(res) >= length:
                            return res
                        addr_out += j4 ; addr_out %= 2**BWADDR
                    addr_out += j3-j4 ; addr_out %= 2**BWADDR
                addr_out += j2-j3 ; addr_out %= 2**BWADDR
            addr_out += j1-j2 ; addr_out %= 2**BWADDR
        addr_out += j0-j1 ; addr_out %= 2**BWADDR

for i in sim_agu(l1,l2,l3,l4,j0,j1,j2,j3,j4,length=len(expected)):
    check_output(i)
print("All good")


# Inputs
a = sim_agu(
    l1=30     -1,    # 30 convolutions per row (32-2 because of edges)
    l2=8*8    -1,    # repeat a patch 64 times to get all bits of precision
    l3=3      -1,    # patch is 3x3
    l4=3      -1,    # patch is 3x3
    j0=-63*8, # jump to new row of patches
    j1=-65*8, # jump to new patch in this row of patches
    j2=-66*8, # return to start of patch (to iterate over bits of precision)
    j3= 30*8, # jump to next row in patch
    j4=  1*8, # jump to next pixel
    length=1024*8
)

def display_grid(highlight_cell):
    """
    Display a 32x32 grid and highlight a specific cell.
    
    Args:
        highlight_cell: Integer between 0 and 1023 indicating which cell to highlight
    """
    if not (0 <= highlight_cell <= 1023):
        raise Exception(f"Error: Cell number must be between 0 and 1023, got {highlight_cell}")

    # Convert 1-indexed cell number to 0-indexed row and column
    highlight_row = highlight_cell // 32
    highlight_col = highlight_cell % 32
    
    out = ""

    # Print column headers
    out += "    "
    for col in range(32):
        out += f"{col:2d} "
    out += "\n    " + "---" * 32 + "\n"
    
    # Print grid
    for row in range(32):
        out += f"{row:2d} |"
        for col in range(32):
            if row == highlight_row and col == highlight_col:
                out += " ■ "  # Highlighted cell
            else:
                out += " □ "  # Empty cell
        out += "\n"
    
    out += f"\nHighlighted cell: {highlight_cell} (Row {highlight_row}, Col {highlight_col})\n"
    print(out)

for i in a:
    display_grid(i//8)
    input()
