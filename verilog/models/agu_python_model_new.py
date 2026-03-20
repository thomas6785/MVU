BWADDR = 21

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

def display_grid(highlight_cell,side_length=32):
    """
    Display a 32x32 grid and highlight a specific cell.
    
    Args:
        highlight_cell: Integer between 0 and 1023 indicating which cell to highlight
    """
    if not (0 <= highlight_cell <= (side_length**2 - 1)):
        raise Exception(f"Error: Cell number must be between 0 and {side_length**2-1}, got {highlight_cell}")

    # Convert 1-indexed cell number to 0-indexed row and column
    highlight_row = highlight_cell // side_length
    highlight_col = highlight_cell % side_length
    
    out = ""

    # Print column headers
    out += "    "
    for col in range(side_length):
        out += f"{col:2d} "
    out += "\n    " + "---" * side_length + "\n"
    
    # Print grid
    for row in range(side_length):
        out += f"{row:2d} |"
        for col in range(side_length):
            if row == highlight_row and col == highlight_col:
                out += " ■ "  # Highlighted cell
            else:
                out += " □ "  # Empty cell
        out += "\n"
    
    out += f"\nHighlighted cell: {highlight_cell} (Row {highlight_row}, Col {highlight_col})\n"
    print(out)

# Inputs
# 3x3 kernel (weight AGU) (8 bit precision)
#a = sim_agu(
#    l1=1    -1,    # 30 convolutions per row (32-2 because of edges)
#    l2=1    -1,    # repeat a patch 64 times to get all bits of precision
#    l3=8*8  -1,    # patch is 3x3
#    l4=9    -1,    # patch is 3x3
#    j0= -8*8, # jump to new row of patches
#    j1= -8*8, # jump to new patch in this row of patches
#    j2= -8*8, # return to start of patch (to iterate over bits of precision)
#    j3= -8*8, # jump to next row in patch
#    j4=  1*8, # jump to next pixel
#    length=1024*8
#)

# 32x32 image through a 3x3 kernel (input AGU) (8 bit precision)
#a = sim_agu(
#    l1=30    -1,    # 30 convolutions per row (32-2 because of edges)
#    l2=8*8   -1,    # repeat a patch 64 times to get all bits of precision
#    l3=3     -1,    # patch is 3x3
#    l4=3     -1,    # patch is 3x3
#    j0= -63*8, # jump to new row of patches
#    j1= -65*8, # jump to new patch in this row of patches
#    j2= -66*8, # return to start of patch (to iterate over bits of precision)
#    j3= 30*8, # jump to next row in patch
#    j4= 1*8, # jump to next pixel
#    length=1024*8
#)

# 10x10 image through a 3x3 kernel (input AGU) (8 bit precision)
a = sim_agu(
    l1=  7,
    l2=  2,
    l3=  2,
    l4=  2,
    j0= -19*8,
    j1= -21*8,
    j2= -22*8,
    j3=   8*8,
    j4=   1*8,
    length=1024*8
)




for i in a:
    display_grid(i//8,10) # //8 because each cell has 8 addresses in memory for the 8 bits in MSB-transposed format
    input()
