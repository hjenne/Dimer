#!/usr/bin/python

import math
import itertools
from copy import deepcopy
from munkres import Munkres, print_matrix
import numpy

class Hexagon:
    def __init__(self, a, b, d):
        self.a = a 
        self.b = b 
        self.d = d 
        self.picture, self.l, self.w = self.make_hexagon()
        self.other_matching = self.find_other_matching()
        self.find_all_X()
        self.find_all_O()
        self.n = len(self.X_list)
        
    def __str__(self):
        output = ""
        for row in self.picture:
            output += "".join(row) + "\n"
        #for row in self.other_matching:
         #   output += "".join(row) + "\n"
        return output

    def __repr__(self):
        return str(self)

    def is_X(self,r, c):
        r1 = r % 4
        c1 = c % 12
        return( (r1, c1) in [(0, 2), (2, 8)])

    def is_O(self,r, c):
        r1 = r % 4
        c1 = c % 12
        return( (r1, c1) in [(2, 0), (0, 6)])

    def is_diag1(self, r, c):
        r1 = r % 4
        c1 = c % 12
        return( (r1, c1) in [(1, 1), (3, 7)])

    def is_diag2(self, r, c):
        r1 = r % 4
        c1 = c % 12
        return( (r1, c1) in [(3, 1), (1, 7)])

    def is_horiz(self, r, c):
        r1 = r % 4
        c1 = c % 12
        return( (r1, c1) in [(2, 9), (0, 3)])

    def make_hexagon(self):
        picture = []
        a = self.a
        b = self.b
        d = self.d
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
                    if self.is_X(r, c):
                        picture[r][c] = "X"
                    if self.is_O(r, c):
                        picture[r][c] = "O"
                    if self.is_diag1(r, c):
                        picture[r][c] = "/"
                    if self.is_diag2(r, c):
                        picture[r][c] = "\\"
                    if self.is_horiz(r, c):
                        for i in range(3):
                            picture[r][c+i] = "-"
        return picture, l, w

#Makes a list of the X's and O's
    def find_all_X(self):    
        self.X_list = []
        self.X_dict = {}
        for r in range(self.l):
            for c in range(self.w):
                if self.picture[r][c] == "X":
                    self.X_list.append((r,c))
        for i,X in enumerate(self.X_list):
            self.X_dict[X] = i

    def find_all_O(self):    
        self.O_list = []
        self.O_dict = {}
        for r in range(self.l):
            for c in range(self.w):
                if self.picture[r][c] == "O":
                    self.O_list.append((r,c))
        for i,O in enumerate(self.O_list):
            self.O_dict[O] = i

#Makes adjacency matrix for the hexagonal grid 
#(This doesn't check if the edges are actually there)
#You might just want to delete this
    def make_matrix(self):
        matrix = {}
        w = self.w
        l = self.l
        for r in range(l):
            for c in range(w):
                if self.picture[r][c] == "X":
                    if c <= w-3 and self.picture[r][c+4] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r,c+4)])] = 1
                    if r <=l-2 and c>= 2 and self.picture[r+2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r+2,c-2)])] = 1
                    if r >=2 and c >=2 and self.picture[r-2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r-2,c-2)])] = 1
        return matrix
 
#Checks if X or O is already in the matching. Returns true if it is
    def is_adj(self, r, c, matching):
        a = self.a
        b = self.b
        d = self.d
        s = 4* int(math.floor(a/2)) #row of upper left corner of hexagon. 
        if (a%2 == 0):
            t = 2 #row of top right corner of hexagon
        else:
            t = 0
        u = 18+6*(a-3) #column of top right corner of hexagon
        w = 6*a + 6*(b-1)+3 #number of columns needed
        m = max(a, b)
        l = t+4*d + (m-1)*4+1 #this is too many rows when a \neq b
        if ( (c < w-3 and matching[r][c+1] == "-") or
        (r <=l-2 and c>= 2 and matching[r+1][c-1] == "/") or
        (r >= 2 and c >=2 and matching[r-1][c-1] == "\\")  or
        (c > 1 and matching[r][c-1] == "-") or
        (r <= l-2 and c< w-1 and matching[r+1][c+1] == "\\") or
        (r >= 2 and c< w-1 and matching[r-1][c+1] == "/") ):
            return True
        else:
            return False

#Finds other smallest matching.
    def find_other_matching(self):
        matching = []
        a = self.a
        b = self.b
        d = self.d
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
            matching.append([" "]*w)
        for r in range(l):
            for c in range(w):
                if (c +3*r >= 2+3*s) and (c - 3*r <=  u - 3*t) and (c-3*r >= 2-3*s -12*d) and (c+3*r <= w-3 + 3*(s+4*d+2*(b-a))):
                    if self.is_X(r, c):
                        matching[r][c] = "X"
                    if self.is_O(r, c):
                        matching[r][c] = "O"
                    #the vertical strip of diagonal lines:
                    if (c >= 6*(a-1)) and (c <= 6*(a-1) +2) and (c+3*r <= 2 + 3*(s+4*d-4)):
                        if self.is_diag2(r, c):
                            matching[r][c] = "\\"
                    if (c >= 6*a) and (c <= 6*a + 2) and (c - 3*r >= w-3 - 3*(s+4*d+2*(b-a)-4)):
                        if self.is_diag1(r, c):
                            matching[r][c] = "/"
                    #horizontal lines above diagonal lines: 
                    if (c < 5*a) and (c+3*r <= 2 + 3*(s+4*d)) and (c+3*r >= 2 + 3*(s+4*d-4)):
                        if self.is_horiz(r, c):
                            for i in range(3):
                                matching[r][c+i] = "-"
                    if (c > 6*a) and (c - 3*r >= w-3 - 3*(s+4*d+2*(b-a))) and (c - 3*r <= w-3 - 3*(s+4*d+2*(b-a)-4)):
                        if self.is_horiz(r, c):
                            for i in range(3):
                                matching[r][c+i] = "-"
                    #diagonal lines above the bottom horizontal lines:  
                    if (c < 6*a) and (c+3*r <= 2 + 3*(s+4*d+4)) and (c+3*r >= 2 + 3*(s+4*d)):
                        if self.is_diag1(r, c):
                            matching[r][c] = "/"
                    if (c > 6*a) and (c - 3*r >= w-3 - 3*(4+s+4*d+2*(b-a))) and (c - 3*r <= w-3 - 3*(s+4*d+2*(b-a))):
                        if self.is_diag2(r, c):
                            matching[r][c] = "\\"   
                    #bottom horizontal lines
                    if (c+3*r >= 2 + 3*(s+4*d+4)) and (c - 3*r <= w-3 - 3*(4+s+4*d+2*(b-a))):
                        if self.is_horiz(r, c):
                            for i in range(3):
                                matching[r][c+i] = "-"
        #delete nodes:
        matching[s+4*d][2] = "*"
        matching[s+4*d -2][0] = "*"
        matching[s+4*d -6][0] = "*"
        matching[s+4*d + 2*(b-a)][w-3] = "*" 
        matching[s+4*d + 2*(b-a)-2][w-1] = "*" 
        matching[s+4*d + 2*(b-a)-6][w-1] = "*" 
        matching[t][6*a] = "*"
        matching[t][6*a-4] = "*"
        matching[t+2][6*(a+1)] = "*"
        matching[t+2][6*(a-1)-4] = "*"
        # puts in edges in column 2 and w-1
        for r in range(l):
            for c in range(w):
                if matching[r][c] == "X":
                    if not self.is_adj(r, c, matching):
                        if c == 2 and matching[r+2][c-2] == "O":
                            matching[r+1][c-1] = "/"
                        if c == w-1 and matching[r-2][c-2] == "O":
                            matching[r-1][c-1] = "\\"
        #Puts in other diagonal edges:
        for r in range(l):
            for c in range(w):
                if matching[r][c] == "X":
                    if not self.is_adj(r, c, matching):
                        for i in range(a-3):
                            if c == 8+i*6 and r == 6-2*i and matching[r+2][c-2] == "O":
                                matching[r+1][c-1] = "/"
                            if c == w-1-6 - 6*i and r == 8-2*i and matching[r-2][c-2] == "O":
                                matching[r-1][c-1] = "\\"
        #Only works for 3 x 3 x 3 case
        for r in range(l):
            for c in reversed(range(w)):
                if matching[r][c] == "X":
                    if not self.is_adj(r, c, matching):                
                        if matching[r-2][c-2] == "O":
                            if not self.is_adj(r-2, c-2, matching):
                                matching[r-1][c-1] = "\\"
                    if not self.is_adj(r, c, matching):
                        if matching[r][c+4] == "O":
                            if not self.is_adj(r, c+4, matching):
                                for i in range(3):
                                    matching[r][c+i+1] = "-"
                    if not self.is_adj(r, c, matching):
                        if matching[r+2][c-2] == "O":
                            if not self.is_adj(r+2, c-2, matching):
                                matching[r+1][c-1] = "/"
        return matching
        
class Hexagon_Without_Nodes():
    def __init__(self, a, b, d):
        self.a = a 
        self.b = b 
        self.d = d 
        self.H = Hexagon(self.a, self.b, self.d) 
        self.picture, self.l, self.w = self.H.make_hexagon()        
        self.no_nodes = self.no_nodes()
        self.find_all_X()
        self.find_all_O()
        self.n = len(self.X_list)
    
    def __str__(self):
        output = ""
        for row in self.no_nodes:
            output += "".join(row) + "\n"
        return output

    def __repr__(self):
        return str(self)
        
    def no_nodes(self):
        a = self.a
        b = self.b
        d = self.d
        s = 4* int(math.floor(a/2)) #row of upper left corner of hexagon. 
        if (a%2 == 0):
            t = 2 #row of top right corner of hexagon
        else:
            t = 0
        u = 18+6*(a-3) #column of top right corner of hexagon
        w = 6*a + 6*(b-1)+3 #number of columns needed
        picture = deepcopy(self.picture)
        for i in range(4):
            picture[s+4*d][2+i] = " "
        picture[s+4*d-1][1] = " "
        picture[s+4*d -2][0] = " "
        picture[s+4*d -3][1] = " "
        picture[s+4*d -5][1] = " "
        picture[s+4*d -6][0] = " "
        picture[s+4*d -7][1] = " "
        for i in range(4):
            picture[s+4*d + 2*(b-a)][w-3-i] = " " 
        picture[s+4*d + 2*(b-a)-2][w-1] = " "
        picture[s+4*d + 2*(b-a)-1][w-2] = " " 
        picture[s+4*d + 2*(b-a)-3][w-2] = " " 
        picture[s+4*d + 2*(b-a)-6][w-1] = " " 
        picture[s+4*d + 2*(b-a)-7][w-2] = " "
        picture[s+4*d + 2*(b-a)-5][w-2] = " "  
        picture[t][6*a] = " "
        picture[t+1][6*a +1] = " "
        picture[t+1][6*a -4 -1] = " "
        for i in range(4):
            picture[t][6*a-4+i] = " "
        picture[t+3][6*(a+1) + 1] = " "
        for i in range(4):
            picture[t+2][6*(a+1) - i] = " "
        picture[t+3][6*(a-1) - 4 -1] = " "
        for i in range(4):
            picture[t+2][6*(a-1) -4 + i] = " "
        return picture

#Makes a list of the X's
    def find_all_X(self):    
        self.X_list = []
        self.X_dict = {}
        for r in range(self.l):
            for c in range(self.w):
                if self.no_nodes[r][c] == "X":
                    self.X_list.append((r,c))
        for i,X in enumerate(self.X_list):
            self.X_dict[X] = i

    def find_all_O(self):    
        self.O_list = []
        self.O_dict = {}
        for r in range(self.l):
            for c in range(self.w):
                if self.no_nodes[r][c] == "O":
                    self.O_list.append((r,c))
        for i,O in enumerate(self.O_list):
            self.O_dict[O] = i
            
#Makes weighted adjacency matrix for the hexagonal grid with nodes removed
#Horizontal lines have weight (0.9)^r, all other lines have weight 1
#Changes 0 entries to 1000 so the algorithm will never pick them
#Changes the 1's to 0's since the weight of our matching is the product of the edges,
#and the algorithm adds up the edges
#Note: You still need to change the entries from (0.9)^r to ln(0.9)^r, and figure out what constant to add
    def make_weighted_matrix(self):
        matrix = {}
        w = self.w
        l = self.l
        for r in range(l):
            for c in range(w):
                if self.no_nodes[r][c] == "X":
                    if c <= w-3 and self.no_nodes[r][c+4] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r,c+4)])] = (0.9)**(r)
                    if r <=l-2 and c>= 2 and self.no_nodes[r+2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r+2,c-2)])] = 1
                    if r >=2 and c >=2 and self.no_nodes[r-2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r-2,c-2)])] = 1
        A = Matrix(self.n, self.n, matrix)
        for i in range(self.n):
            for j in range(self.n):
                if A[i,j] == 0:
                    A[i, j] = 1000
        for i in range(self.n):
            for j in range(self.n):
                if A[i, j] == 1:
                    A[i ,j] = 0
        B = numpy.array(A)
        return B

class Matching():
    def __init__(self, H, edges=None):
        self.H = H
        self.picture, self.l, self.w = H.make_hexagon()
        self.n = len(H.X_list)
        if edges == None:
            self.matching = self.find_smallest_matching()
        else:
            self.edges = edges

    def __str__(self):
        output = ""
        for row in self.matching:
            output += "".join(row) + "\n"
        return output

    def __repr__(self):
       return str(self)


#Finds smallest matching of a hexagon with nodes included
    def find_smallest_matching(self):
        matching = []
        a = H.a
        b = H.b
        d = H.d
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
            matching.append([" "]*w)
        for r in range(l):
            for c in range(w):
                if (c +3*r >= 2+3*s) and (c - 3*r <=  u - 3*t) and (c-3*r >= 2-3*s -12*d) and (c+3*r <= w-3 + 3*(s+4*d+2*(b-a))):
                    if H.is_X(r, c):
                        matching[r][c] = "X"
                    if H.is_O(r, c):
                        matching[r][c] = "O"
                    if (c < 6*a) and (c+3*r <= 2 + 3*(s+4*d) or c - 3*r >= w-3 - 3*(s+4*d+2*(b-a)) ):
                        if H.is_diag1(r, c):
                            matching[r][c] = "/"
                    if (c > 6*a) and ((c+3*r <= 2 + 3*(s+4*d)) or (c - 3*r >= w-3 - 3*(s+4*d+2*(b-a))) ):
                        if H.is_diag2(r, c):
                            matching[r][c] = "\\"
                    if (c+3*r >= 2 + 3*(s+4*d)) and (c - 3*r <= w-3 - 3*(s+4*d+2*(b-a))):
                        if H.is_horiz(r, c):
                            for i in range(3):
                                matching[r][c+i] = "-"
        return matching

#This makes adjacency matrix for self.matching (so usually the smallest matching)
    def make_matching_matrix(self):
        matrix = {}
        w = self.w
        l = self.l
        for r in range(l):
            for c in range(w):
                if self.matching[r][c] == "X":
                    if c <= w-3 and self.matching[r][c+1] == "-" and self.matching[r][c+4] == "O":
                        matrix[(H.X_dict[(r,c)], H.O_dict[(r,c+4)])] = 1
                    if r <=l-2 and c>= 2 and self.matching[r+1][c-1] == "/" and self.matching[r+2][c-2] == "O":
                        matrix[(H.X_dict[(r,c)], H.O_dict[(r+2,c-2)])] = 1
                    if r >=2 and c >=2 and self.matching[r-1][c-1] == "\\" and self.matching[r-2][c-2] == "O":
                        matrix[(H.X_dict[(r,c)], H.O_dict[(r-2,c-2)])] = 1
        return matrix
        
#Makes a list of edges in self.matching
    def make_edge_list(self):
        edge_list = []
        w = self.w
        l = self.l
        for r in range(l):
            for c in range(w):
                if self.matching[r][c] == "X":
                    if c <= w-3 and self.matching[r][c+1] == "-" and self.matching[r][c+4] == "O":
                        edge_list.append((H.X_dict[(r,c)], H.O_dict[(r,c+4)]))
                    if r <=l-2 and c>= 2 and self.matching[r+1][c-1] == "/" and self.matching[r+2][c-2] == "O":
                        edge_list.append((H.X_dict[(r,c)], H.O_dict[(r+2,c-2)]))
                    if r >=2 and c >=2 and self.matching[r-1][c-1] == "\\" and self.matching[r-2][c-2] == "O":
                        edge_list.append((H.X_dict[(r,c)], H.O_dict[(r-2,c-2)]))
        return edge_list

#Looks for
#    X   O  
#   /     \ 
#  O       X
#            
#    X---O    
# and returns coordinates of the upper left X
    def find_bigger_matching(self, matching):
        w = self.w
        l = self.l
        coordinates = []
        for r in range(l):
            for c in range(w):
                if matching[r][c] == "X":
                    if (2 <= c <= w-3 and 2 <= r <=l-2 and 
                    matching[r][c+1] == " " and 
                    matching[r+1][c-1] == "/" and 
                    matching[r+1][c+5] == "\\" and 
                    matching[r+3][c-1] == " " and 
                    matching[r+3][c+5] == " " and 
                    matching[r+4][c+1] == "-"):
                        coordinates.append((r, c))
        return coordinates

#Replaces  
#    X   O  
#   /     \ 
#  O       X
#            
#    X---O 
#with
#    X---O  
#           
#  O       X
#   \     /  
#    X   O 
#based on the coordinates of the upper left X
    def add_box(self, matching, r, c):
        matching[r+1][c-1] = " " 
        matching[r+1][c+5] = " " 
        matching[r+3][c-1] = "\\" 
        matching[r+3][c+5] = "/" 
        for i in range(3):
            matching[r+4][c+i+1] = " "
        for i in range(3):
            matching[r][c+i+1] = "-"
        return matching

#make list of matchings    
    def make_bigger_matching(self, matching):
        coordinates = self.find_bigger_matching(matching)
        n = len(coordinates)
        l = []
        for i in range(n):
            r, c = coordinates[i][0], coordinates[i][1]
            newmatching = deepcopy(matching)
            newmatching = self.add_box(newmatching, r, c)
            l.append(newmatching)
        return l

#Finds all configurations with 1 box, starting from the minimal matching
    def find_all_config(self, n):
        matching = self.matching
        l = [matching]
        for j in range(n):
            l2 = []
            for i in range(len(l)):
                N = self.make_bigger_matching(l[i])
                l2.append(N)
            l = [item for sublist in l2 for item in sublist]
        l.sort()
        l = list(l for l,_ in itertools.groupby(l))
        print len(l)
        return l       

H = Hexagon(5,5,5)
N = Hexagon_Without_Nodes(5,5,5)

B = N.make_weighted_matrix()

m = Munkres()
indexes = m.compute(B)
print indexes

w = H.w
l = H.l
matching = N.no_nodes
for i in range(N.n):
	a = indexes[i][0]
	b = indexes[i][1]
	(r1, c1) = N.X_list[a]
	(r2, c2) = N.O_list[b]
	if r1 - r2 < 0:
		if c1 < w-3:
			for i in range(3):
				matching[r1][c1+ i +1] = " "
		matching[r1 - 1][c1 -1] = " "
	if r1 - r2 == 0:
		matching[r1 - 1][c1 -1] = " "
		if r1 < l-1:
			matching[r1 +1][c1 - 1] = " "
	if r1 - r2 > 0:
		if c1 < w-3: 
			for i in range(3):
				matching[r1][c1 + i + 1] = " "
		if r1 < l:
			matching[r1 +1][c1 - 1] = " "
for row in matching:
	print "".join(row)

#This is really stupid, you should write something that prints the edges rather than deleting ones that aren't there.			
#Write a function whose input is an adjacency matrix and whose output is a minimal matching. Put this in the matching class?
