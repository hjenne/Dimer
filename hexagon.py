#!/usr/bin/python

import math

class Hexagon:
    def __init__(self, a, b, d):
        self.a = a 
        self.b = b 
        self.d = d 
        self.picture, self.l, self.w = self.make_hexagon()
        self.matching = self.find_smallest_matching()
        self.find_all_X()
        self.find_all_O()
        self.n = len(self.X_list)

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

    def __str__(self):
        output = ""
        for row in self.picture:
            output += " ".join(row) + "\n"
        for row in self.matching:
            output += " ".join(row) + "\n"
        return output

    def __repr__(self):
        return str(self)

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

#Makes adjacency matrix assuming all of the edges are there:
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

#Makes adjacency matrix only for edges that are there 
#This makes adjacency matrix for the minimal matching 
    def make_matching_matrix(self):
        matrix = {}
        w = self.w
        l = self.l
        for r in range(l):
            for c in range(w):
                if self.matching[r][c] == "X":
                    if c <= w-3 and self.matching[r][c+1] == "-" and self.matching[r][c+4] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r,c+4)])] = 1
                    if r <=l-2 and c>= 2 and self.matching[r+1][c-1] == "/" and self.matching[r+2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r+2,c-2)])] = 1
                    if r >=2 and c >=2 and self.matching[r-1][c-1] == "\\" and self.matching[r-2][c-2] == "O":
                        matrix[(self.X_dict[(r,c)], self.O_dict[(r-2,c-2)])] = 1
        return matrix
        
#Makes a list of edges in the minimal matching. 
#Not sure if this is useful
    def make_edge_list(self):
        edge_list = []
        w = self.w
        l = self.l
        for r in range(l):
            for c in range(w):
                if self.matching[r][c] == "X":
                    if c <= w-3 and self.matching[r][c+1] == "-" and self.matching[r][c+4] == "O":
                        edge_list.append((self.X_dict[(r,c)], self.O_dict[(r,c+4)]))
                    if r <=l-2 and c>= 2 and self.matching[r+1][c-1] == "/" and self.matching[r+2][c-2] == "O":
                        edge_list.append((self.X_dict[(r,c)], self.O_dict[(r+2,c-2)]))
                    if r >=2 and c >=2 and self.matching[r-1][c-1] == "\\" and self.matching[r-2][c-2] == "O":
                        edge_list.append((self.X_dict[(r,c)], self.O_dict[(r-2,c-2)]))
        return edge_list


#Finds smallest matching. Pretty much the same as make_hexagon, but with more inequalities
    def find_smallest_matching(self):
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
                    if (c < 6*a) and (c+3*r <= 2 + 3*(s+4*d) or c - 3*r >= w-3 - 3*(s+4*d+2*(b-a)) ):
                        if self.is_diag1(r, c):
                            matching[r][c] = "/"
                    if (c > 6*a) and ((c+3*r <= 2 + 3*(s+4*d)) or (c - 3*r >= w-3 - 3*(s+4*d+2*(b-a))) ):
                        if self.is_diag2(r, c):
                            matching[r][c] = "\\"
                    if (c+3*r >= 2 + 3*(s+4*d)) and (c - 3*r <= w-3 - 3*(s+4*d+2*(b-a))):
                        if self.is_horiz(r, c):
                            for i in range(3):
                                matching[r][c+i] = "-"
        return matching


class Matching():
    def __init__(self, H, edges=None):
        self.H = H
        self.picture, self.l, self.w = H.make_hexagon()
        if edges == None:
            self.matching = H.find_smallest_matching()
        else:
            self.edges = edges

    def __str__(self):
        output = ""
        for row in self.matching:
            output += " ".join(row) + "\n"
        return output

    def __repr__(self):
       return str(self)

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
#this isn't working, the list it returns is just the last item it put in the list repeated three times
    def make_bigger_matching(self, matching):
        coordinates = self.find_bigger_matching(matching)
        n = len(coordinates)
        l = []
        for i in range(n):
            r, c = coordinates[i][0], coordinates[i][1]
            newmatching = matching
            newmatching = self.add_box(newmatching, r, c)
            l.append(newmatching)
            print "This is list " + str(i)
            for row in l[i]:
                print " ".join(row)
        return l
                        

H = Hexagon(4,4,4)
M = Matching(Hexagon(4, 4,4))
firstmatchinglist = M.make_bigger_matching(M.matching)
#print "After one box is added:"
#for row in firstmatchinglist[0]:
   # print " ".join(row)
l = M.make_bigger_matching(firstmatchinglist[0])
print "This is the first item in the list:"
for row in l[0]:
    print " ".join(row)
print "This is the second item in the list:"
for row in l[1]:
    print " ".join(row)
print "This is the third item in the list:"
for row in l[2]:
    print " ".join(row)
