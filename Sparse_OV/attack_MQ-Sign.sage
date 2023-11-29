# Params setup

q = 2^8
v = 72
m = 46

__SEC_LEVEL__ = 1

if __SEC_LEVEL__ == 3:
    v = 112
    m = 72

if __SEC_LEVEL__ == 5:
    v = 148
    m = 96

n = v + m
K = GF(q)

#Defining a tower of finite fields
#  using the moduli specified in
#  comments of the reference implementation
#  of MQ-Sign.
#GF2.<u> = GF(2)
#RR.<x> = PolynomialRing(GF2)
#GF4.<z> = GF2.extension(x^2+x+1)
#RR.<y> = PolynomialRing(GF4)
#GF16.<w> = GF4.extension(y^2+y+z)
#RR.<X> = PolynomialRing(GF16)
#GF256.<X> = GF16.extension(X^2+X+z*w)
#K = GF256


# Functions for MQ-Sign keygen

def V2(i, s):
    return ((((i+1)+(s+1)-1) % v))

def O2(i, s):
    return ((((i+1)+(s+1)-2) % m) + v)

def Upper(M, nn):
  for i in range(0, nn):
      for j in range(i, nn):
          M[i, j] += M[j, i]
          M[j, i] = 0
  return M

def MQSignCentralMap():
    F = []
    for s in range(0, m):
        M = zero_matrix(K, n, n)
        for i in range(0, v):
            M[i, V2(i, s)] = K.random_element()
            M[i, O2(i, s)] = K.random_element()
        M = Upper(M, n)
        F.append(M)
    return F

def UpperTriangularS():
    S = block_matrix([ [identity_matrix(K,v), random_matrix(K, v, m)], [zero_matrix(K,m,v), identity_matrix(K,m)] ])
    return S

def GetPublicKey(F, S):
  S = S.submatrix(0, v, v, m)
  F1 = [F[s].submatrix(0, 0, v, v) for s in range(0, m)]
  F2 = [F[s].submatrix(0, v, v, m) for s in range(0, m)]
  P1 = [F1[s] for s in range(0, m)]
  P2 = [(F1[s] + F1[s].transpose())*S + F2[s] for s in range(0, m)]
  P3 = [Upper(S.transpose()*F1[s]*S+S.transpose()*F2[s], m) for s in range(0, m)]
  P = [block_matrix([[P1[s], P2[s]], [zero_matrix(K, m, v), P3[s]]]) for s in range(0, m)]
  return P


# Functions used for the attack

def MQSignHeatMap(s):
    H = zero_matrix(K, n, n)
    for i in range(0, v):
        H[i, V2(i, s)] = 1
        H[i, O2(i, s)] = 1
    H = Upper(H, n)
    return H

def GetSolution(P):
    P1 = [P[s].submatrix(0, 0, v, v) for s in range(0, m)]
    P2 = [P[s].submatrix(0, v, v, m) for s in range(0, m)]

    P1_tilde = [P1[s] + P1[s].transpose() for s in range(0, m)]
    BigP = block_matrix([ P1_tilde[s] for s in range(0, m) ] , ncols=1)

    H = [MQSignHeatMap(s) for s in range(0, m)]
    H2 = [H[s].submatrix(0, v, v, m) for s in range(0, m)] #Heat map of F2

    cols = []
    for j in range(0, m):
        b = block_matrix([ P2[s].submatrix(0, j, v, 1) for s in range(0, m) ] , ncols=1)
        A = BigP
        #remove non valid rows
        cpt_removed = 0
        for s in range(0, m):
            for i in range(0, v):
                if H2[s][i][j] != 0:
                    A = A.delete_rows([s*v+i-cpt_removed])
                    b = b.delete_rows([s*v+i-cpt_removed])
                    cpt_removed += 1
        cols = cols + [A.solve_right(b)]

    S_sol = block_matrix([ cols[j] for j in range(0, m) ] , nrows=1)

    return S_sol


# MAIN

F = MQSignCentralMap()
S = UpperTriangularS()
P = GetPublicKey(F, S)

S_sol = GetSolution(P)
print(S_sol == S.submatrix(0, v, v, m))
