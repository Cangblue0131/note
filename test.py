
##########
###1
##########
matrix = [[2,2,-1]]
k = 0
m = len(matrix)
n = len(matrix[0])
Sum = -999


#def F(Matrix,i,j,Sum,k):


H = 1
W = 1
while H <= m:
    for i in (range(m - H + 1)): #左上角位置m
        for j in (range(n - W + 1)): #左上角位置n
            Mat = matrix[i : i + H]
            S = 0
            print(Mat)
            for M in Mat:
                print(M[j : j + W])
                S += sum(M[j : j + W])
            if Sum < S and S <= k:
                Sum = S
    W += 1
    if W > n :
        W = 1
        H += 1
    
print(Sum)




#2
import numpy as np

#matrix = np.array([[i,i+1,i+2,i+3] for i in range(5)])
#k = 3
matrix = np.array([[2,2,-1]])
k = 0

m = len(matrix)
n = len(matrix[0])
Sum = float('-inf')

def sum_matrix(matrix,k):
    LM = len(matrix)
    S = np.zeros((LM - k + 1, len(matrix[0])), dtype = 'int')
    for i in range(k):
        S += matrix[ i : ( len(matrix) - k + 1 + i)]
    return S

for i in range(m):
    for j in range(n):
        new_matrix = sum_matrix(sum_matrix(matrix,i+1).T,j+1)
        ind = (new_matrix <= k)
        
        if np.sum(ind) > 0:
            max_S = np.max(new_matrix[new_matrix <= k])
            if Sum < max_S :
                Sum = max_S

print(Sum)



#3
import numpy as np

#matrix = np.array([[i,i+1,i+2,i+3] for i in range(5)])
#k = 3
matrix = np.array([[2,2,-1]])
k = 0



m = len(matrix)
n = len(matrix[0])
Sum = float('-inf')


matrix_i = np.zeros((n, m+1), dtype = 'int')
for i in range(m):
    New_h = (len(matrix_i.T)-1)
    matrix_i = (matrix_i.T[ : New_h] + matrix[i:]).T
    matrix_j = np.zeros(( n+1 , New_h), dtype = 'int')
    for j in range(n):
        matrix_j = (matrix_j[ : (len(matrix_j)-1)] + matrix_i[ j: ])
        ind = (matrix_j <= k)
        
        if np.sum(ind) > 0:
            max_S = np.max(matrix_j[matrix_j <= k])
            if Sum < max_S :
                Sum = max_S

print(Sum)



