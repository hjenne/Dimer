#!/usr/bin/python

import math

def is_X(r, c):
    r1 = r % 4
    c1 = c % 12
    return( (r1, c1) in [(0, 2), (2, 8)])

def is_O(r, c):
    r1 = r % 4
    c1 = c % 12
    return( (r1, c1) in [(2, 0), (0, 6)])

def is_diag1(r, c):
    r1 = r % 4
    c1 = c % 12
    return( (r1, c1) in [(1, 1), (3, 7)])

def is_diag2(r, c):
    r1 = r % 4
    c1 = c % 12
    return( (r1, c1) in [(3, 1), (1, 7)])

def is_horiz(r, c):
    r1 = r % 4
    c1 = c % 12
    return( (r1, c1) in [(2, 9), (0, 3)])

def make_hexagon(a,b,d):
    picture = []
    s = 4* int(math.floor(a/2)) #row of upper left corner of hexagon. 
    if (a%2 == 0):
        t = 2 #row of top right corner of hexagon
    else:
        t = 0
    u = 18+6*(a-3) #column of top right corner of hexagon
    w = 6*a + 6*(b-1)+3 #number of columns needed
    m = max(a, b)
    l = t+4*d + (m-1)*4+1 #this is too many rows when a \neq b
    for r in range(l):
        picture.append([" "]*w)
    for r in range(l):
        for c in range(w):
            if (c +3*r >= 2+3*s) and (c - 3*r <=  u - 3*t) and (c-3*r >= 2-3*s -12*d) and (c+3*r <= w-3 + 3*(s+4*d+2*(b-a))):
                if is_X(r, c):
                    picture[r][c] = "X"
                if is_O(r, c):
                    picture[r][c] = "O"
                if is_diag1(r, c):
                    picture[r][c] = "/"
                if is_diag2(r, c):
                    picture[r][c] = "\\"
                if is_horiz(r, c):
                    for i in range(3):
                        picture[r][c+i] = "-"
    for row in picture:
        print " ".join(row)
    return picture, l, w

picture, l, w = make_hexagon(5,4,6)
matrix = {}
for r in range(l):
	for c in range(w):
		if picture[r][c] == "X":
			if c <= w-3 and picture[r][c+4] == "O":
				matrix[((r,c), (r,c+4))] = 1
			if r <=l-2 and c>= 2 and picture[r+2][c-2] == "O":
				matrix[((r,c), (r+2,c-2))] = 1
			if r >=2 and c >=2 and picture[r-2][c-2] == "O":
				matrix[((r,c), (r-2,c-2))] = 1
print matrix
