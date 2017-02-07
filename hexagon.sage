#!/usr/bin/python

import math
import itertools
from copy import deepcopy
from munkres import Munkres, print_matrix
import numpy
import cProfile
import re

class Hexagon:
    def __init__(self, a, b, d, x=0, y=0, z=0, nodes = True):
        self.a = a 
        self.b = b 
        self.d = d 
        self.nodes = nodes
        self.x = x
        self.y = y
        self.z = z
        self.l, self.w = self.find_dimensions()
        self.picture = self.make_hexagon()
        self.find_all_X()
        self.find_all_O()
        self.n = len(self.X_list)
        self.matrix = self.make_weighted_matrix()
	self.nodelist = self.make_nodelist()
	self.connectlist = self.make_connectlist()
        
    def __str__(self):
        output = ""
        for row in self.picture:
            output += "".join(row) + "\n"
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
        
    def find_dimensions(self):
        a = self.a
        b = self.b
        d = self.d
        if (a%2 == 0):
            t = 2 #row of top right corner of hexagon
        else:
            t = 0
        w = 6*a + 6*(b-1)+3 #number of columns needed
        m = max(a, b)
        l = t+4*d + (m-1)*4+1 #this is too many rows when a \neq b
        return l, w
        
    def make_hexagon(self):
        picture = []
        a = self.a
        b = self.b
        d = self.d
	x = self.x
        y = self.y
	z = self.z
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
        if not self.nodes:
	    for j in range(y): #upper right and right nodes
		picture[t + 2*j][6*(a+j)] = "*" #top right node
		for i in range(3):
		    picture[t +2*j][6*(a+j)-1-i] = " "
		picture[t+2*j + 1][6*(a+j) +1] = " "
		picture[s+4*d + 2*(b-a)-2 -4*j][w-1] = "*" #right node
		picture[s+4*d + 2*(b-a)-1 - 4*j][w-2] = " " 
		picture[s+4*d + 2*(b-a)-3 - 4*j][w-2] = " " 
	    for j in range(x):
		picture[t+2*j][6*(a-j) -4] = "*" #top left node
		for i in range(3):
		    picture[t+2*j][6*(a-j)-4+i+1] = " "
		picture[t+2*j+1][6*(a-j) - 4 -1] = " "
		picture[s+4*d -2-4*j][0] = "*" #left node
		picture[s+4*d-1 - 4*j][1] = " "
		picture[s+4*d -3- 4*j][1] = " "
	    for j in range(z):
		picture[s+4*d +2*j][2+6*j] = "*" #lowest left node
		for i in range(3):
		    picture[s+4*d+2*j][2+i+1 +6*j] = " "
		picture[s+4*d-1 +2*j][1+6*j] = " "
		picture[s+4*d + 2*(b-a)+2*j][w-3-6*j] = "*" #lowest right node
		picture[s+4*d + 2*(b-a)-1+2*j][w-2-6*j] = " "
		for i in range(3):
		    picture[s+4*d + 2*(b-a)+2*j][w-3-1-i-6*j] = " " 
        return picture


#Appends nodes to a list in the correct order

    def make_nodelist(self):
	nodelist = []
	a = self.a
	b = self.b
	d = self.d
	x = self.x
	y = self.y
	z = self.z
	s = 4* int(math.floor(a/2)) #row of upper left corner of hexagon. 
        if (a%2 == 0):
            t = 2 #row of top right corner of hexagon
        else:
            t = 0
	w = 6*a + 6*(b-1)+3 #number of columns needed
	for j in range(z):
	    nodelist.append((s+4*d +2*j,2+6*j))
	for j in reversed(range(z)):
	    nodelist.append((s+4*d + 2*(b-a)+2*j, w-3-6*j))
	for j in range(y):
	    nodelist.append((s+4*d + 2*(b-a)-2 -4*j,w-1))
	for j in reversed(range(y)):
	    nodelist.append((t + 2*j,6*(a+j)))
	for j in range(x):
	    nodelist.append((t+2*j,6*(a-j) -4))
	for j in reversed(range(x)):
	    nodelist.append((s+4*d -2-4*j,0))
	return nodelist

#Says which nodes should be connected (not using locations of nodes, using
#the order of the nodes in the list)
    def make_connectlist(self):
	connectlist = []
	x = self.x
	y = self.y
	z = self.z
	for i in range(z):
	    connectlist.append((i, 2*z-1-i))
	for i in range(y):
	    connectlist.append((2*z+i, 2*y+2*z - 1 - i))
	for i in range(x):
	    connectlist.append((2*z + 2*y + i, 2*x+2*y+2*z-1-i))
	return connectlist
	

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
 
#Checks if X or O is already in the matching. Returns true if it is
#Maybe you don't need this anymore??
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
            
            
#Makes weighted adjacency matrix for the hexagonal grid with nodes removed
#Horizontal lines have weight (0.9)^(r+2), all other lines have weight 1
#Note: Weight was originally (0.9)^r, but this was an issue with row 0 and
#messed up the minimal matching for hexagons with odd side length. 
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
                if self.picture[r][c] == "X":
                    if c <= w-3 and self.picture[r][c+4] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r,c+4)])] = (0.9)**(r+2)
                    if r <=l-2 and c>= 2 and self.picture[r+2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r+2,c-2)])] = 1
                    if r >=2 and c >=2 and self.picture[r-2][c-2] == "O":
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


#input is a Hexagon, with nodes or without nodes. For one without nodes, should also input a matrix
class Matching():
    def __init__(self, H, matrix=None):
        self.H = H
        self.n = len(H.X_list)
        self.l = H.l
        self.w = H.w
        self.picture = H.picture
        if matrix == None:
            self.matching = self.find_smallest_matching()
        else:
            self.matrix = matrix
            self.matching, self.indexes = self.find_minimal_matching()

    def __str__(self):
        output = ""
        for row in self.matching:
            output += "".join(row) + "\n"
        return output

    def __repr__(self):
       return str(self)

#Finds smallest matching using the Munkres algorithm   
    def find_minimal_matching(self):
        B = self.matrix
        w = self.w
        l = self.l
        n = self.n
        H = self.H
        picture = self.picture
        matching = []
        m = Munkres()
        indexes = m.compute(B)
        for r in range(l):
            matching.append([" "]*w)
        for r in range(l):
            for c in range(w):
                if picture[r][c] == "X":
                    matching[r][c] = "X"
                if picture[r][c] == "O":
                    matching[r][c] = "O"
        for i in range(len(indexes)):
            a = indexes[i][0]
            b = indexes[i][1]
            (r1, c1) = H.X_list[a]
            (r2, c2) = H.O_list[b]
            if r1 - r2 < 0:
                if r1 < l-1 and c1 > 1:
                    matching[r1+1][c1-1] = "/"
            if r1 - r2 == 0: 
                if c1 < w-3:
                    for i in range(3):
                        matching[r1][c1 + i + 1] = "-"
            if r1 - r2 > 0:
                if r1 > 1 and c1 > 1:
                    matching[r1-1][c1-1] = "\\"
        return matching, indexes

#Finds smallest matching of a hexagon with nodes included
    def find_smallest_matching(self):
        matching = []
        H = self.H
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
        
    def find_indexes(self, matching):
        indexes = []
        l = self.l
        w = self.w
        for r in range(l):
            for c in range(w):
                if matching[r][c] == "X":
                    if c <= w-3 and matching[r][c+1] == "-" and matching[r][c+4] == "O":
                        indexes.append((self.H.X_dict[(r,c)], self.H.O_dict[(r,c+4)]))
                    if r <=l-2 and c>= 2 and matching[r+1][c-1] == "/" and matching[r+2][c-2] == "O":
                        indexes.append((self.H.X_dict[(r,c)], self.H.O_dict[(r+2,c-2)]))
                    if r >=2 and c >=2 and matching[r-1][c-1] == "\\" and matching[r-2][c-2] == "O":
                        indexes.append((self.H.X_dict[(r,c)], self.H.O_dict[(r-2,c-2)]))
        return indexes                  
                    
                    
                
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

#Finds all configurations with n boxes, starting from the minimal matching
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
        return l       

#Hexagon with nodes:
H1 = Hexagon(6,6,6,0,0,0,True)
A = H1.make_weighted_matrix()
M1 = Matching(H1, A)

#Hexagon without nodes:
H2 = Hexagon(6,6,6,2,2,1,False)
B = H2.make_weighted_matrix()
M2 = Matching(H2, B)
nodelist = H2.nodelist
connectlist = H2.connectlist

#for item in matchinglist2:
#    for row in item:
#        print "".join(row)

a = H1.a
b = H1.b
d = H1.d
w = H1.w
l = H1.l
n = H1.n
s = 4* int(math.floor(a/2)) 
if (a%2 == 0):
    t = 2 
else:
    t = 0

def make_doublematching(nodematching, nonodematching):
    doublematching = []
    for r in range(l):
        doublematching.append([" "]*w)
    for r in range(l):
        for c in range(w):
            if nodematching[r][c] == "X":
                doublematching[r][c] = "X"
            if nodematching[r][c] == "O":
                doublematching[r][c] = "O"
            if nodematching[r][c] == "/":
                doublematching[r][c] = "/"
            if nodematching[r][c] == "\\":
                doublematching[r][c] = "\\"
            if nodematching[r][c] == "-":
                doublematching[r][c] = "-"
            if nonodematching[r][c] == "/":
                doublematching[r][c] = "/"
            if nonodematching[r][c] == "\\":
                doublematching[r][c] = "\\"
            if nonodematching[r][c] == "-":
                doublematching[r][c] = "-"
    #for row in doublematching:
        #print "".join(row)
    return doublematching

#nodelist = [(s+4*d, 2), (s+4*d +2*(b-a), w-3), (s+4*d + 2*(b-a)-2, w-1),\
# (s+4*d + 2*(b-a)-6, w-1), (t+2, 6*(a+1)), (t, 6*a), (t, 6*a-4), \
# (t+2, 6*(a-1)-4), (s+4*d-6, 0), (s+4*d-2, 0) ] 


#find coordinates of the O that X is adjacent to, given:
#-the matching with nodes included
#-The coordinates of X
#-The list of indexes of the matching
def find_adj_O((r,c), indexes1):
    a = H1.X_dict[(r, c)]
    for i in range(len(indexes1)):
        if indexes1[i][0] == a:
            b = indexes1[i][1] #this is O
    return H1.O_list[b]

#find coordinates of the X that O is adjacent to, given:
#-the matching without nodes included
#-The coordinates of O
#-The list of indexes of the matching

def find_adj_X((r, c), indexes2):
    b = H2.O_dict[(r,c)]
    for i in range(len(indexes2)):
        if indexes2[i][1] == b:
            a = indexes2[i][0] #this is X
    return H2.X_list[a]

#Checks if two nodes are connected
#Uses nodelist defined above (better to make this an input to the function?)
def is_connected(u, v, indexes1, indexes2):
    (r1, c1) = nodelist[u] #row and column of node u
    i = 0
    for i in range(40):
        (r2, c2) = find_adj_O((r1, c1), indexes1)
        if (r2, c2) == nodelist[v]:
            return True
        elif (r2, c2) in nodelist:
            return False
        else:
            (r1,c1) = find_adj_X((r2, c2), indexes2)
            i = i+1


#Checks if all nodes are connected
def all_paths(indexes1, indexes2, connlist):
    for i in range(len(connlist)):
	if not is_connected(connlist[i][0], connlist[i][1], indexes1, indexes2):
	    return False
    else: return True

#Checks symmetry
def is_symmetric(matching):
    for r in range(l):
        for c in range(6*a-4):
            if matching[r][c] == "/":
                if matching[r][w-c-1] != "\\":
                    return False
            if matching[r][c] == "\\":
                if matching[r][w-c-1] != "/":
                    return False
            if matching[r][c] == "-":
                if matching[r][w-c-1] != "-":
                    return False
    return True

def find_count(n1, n2):
    count = 0
    matchinglist1 = M1.find_all_config(n1)
    #print "Matching List 1"
    #for item in matchinglist1:
	#for row in item:
	 #   print "".join(row)
    matchinglist2 = M2.find_all_config(n2)
    #print "Matching List 2"
    #for item in matchinglist2:
	#for row in item:
	 #   print "".join(row)
    for item in matchinglist1:
	indexes_one = M1.find_indexes(item)
	for item2 in matchinglist2:
	    F = make_doublematching(item, item2)
	    indexes_two = M2.find_indexes(item2)
	    if all_paths(indexes_one, indexes_two,connectlist) and is_symmetric(F):
		count = count + 1
    return count



#print find_count(0,1)

cProfile.run('find_count(0,5)')

#x6 = find_count(0,6) + find_count(1,5) + find_count(2, 4) + find_count(3, 3)
#print x6
#x7 = find_count(0,7) + find_count(1, 6) + find_count(2, 5) + find_count(3, 4) + find_count(4,3)
#print x7

#x0 = find_count(0,0)
#x1 = find_count(0,1)
#x2 = find_count(0,2)
#x3 = find_count(0,3) + find_count(1,2)
#x4 = find_count(0,4) + find_count(1,3)
#x5 = find_count(0,5) + find_count(1,4) + find_count(2,3)
#print x5
#print "0 boxes:"
#print x0
#print "1 boxes"
#print x1
#print "2 boxes:"
#print x2
#print "3 boxes:"
#print x3
#print "4 boxes:"
#print x4
#print "5 boxes:"
#print x5

#R.<x> = PowerSeriesRing(QQ)
#M = prod(1/(1-x^i)^i for i in range(20))
#generating function for plane partitions: prod(1/(1-x^i)^i for i in range(20))
#generating function for plane partitions inside a 3x3x2 box: prod( prod( (1-x^(i+j+2-1) )/(1-x^(i+j-1) ) for j in range(1,4) ) for i in range(1, 4) )
#generating function for symmetric plane partitions: prod( (1/( 1-x^(2*i-1) ) )*( 1/(1-x^(2*i) )^(floor(i/2)) ) for i in range(1,20) )
#generating function for symmetric plane partitions inside a 3x3x2 box:
#prod( prod( (1-x^(1+2*i+k-2) )/(1-x^(2*i+k -2) ) for k in range(1, 3) ) for i in range(1, 4) )
#prod(prod( (1-x^(2 + 2*(i +j+k -2) ) )/(1-x^(2*(i+j+k-2) ) ) for k in range (1, 3) ) for i in range(1, 3) for j in range(i+1, 4) )
