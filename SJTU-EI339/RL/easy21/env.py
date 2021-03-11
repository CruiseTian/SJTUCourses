import numpy as np
import pandas as pd

action = [0,1] #0:hit 1:stick

def update(s, i):
    """
    Parameters
    ----------
    s : state array
    i : index

    Returns
    -------
    None.
    """
    # 生成概率
    p = np.random.rand()
    v = np.random.randint(1, 11)
    if p < 1 / 3:
        if i==0:
            return ([s[0]-v,s[1]])
        else:
            return ([s[0],s[1]-v])
    else:
        if i == 0:
            return ([s[0] + v, s[1]])
        else:
            return ([s[0], s[1] + v])

def isOver(s, i):
    #判断是否结束
    if s[i] > 21 or s[i] < 1:
        return True
    return False

def get_action():
    return np.random.randint(2)

def init():
    return np.random.randint(1, 11, 2)

class Easy21():
    def step(self, s, a):
        """
        Parameters
        ----------
        s : state array, dealer s[0], player s[1]
        a : action, hit: 0; stick: 1

        Returns
        -------
        next state s'
        reward r
        terminal flag
        """
        # 判断是否结束
        flag = False
        r = 0
        if a == 0:
            s=update(s, 1)
            if isOver(s, 1):
                r = -1
                flag = True
        else:
            flag = True
            while s[0] < 16 and s[0] > 0:
                s=update(s, 0)
            if isOver(s, 0):
                r = 1
            else:
                if s[0] < s[1]:
                    r = 1
                elif s[0] == s[1]:
                    r = 0
                else:
                    r = -1

        return s, r, flag

def epsilon_greedy(Q, key):
    p = np.random.rand()
    if p >= 0.9:
        if Q[key][0] == Q[key][1]:
            a = 0
        a = np.argmax(Q[key])
    else:
        a = get_action()
    return a
# def epsilon_greedy(Q, N, key, N0):
#     n = N[key].sum()
#     epsilon = N0 / (N0 + n)
#     p = np.random.rand()
#     if p >= epsilon:
#         a = np.argmax(Q[key])
#     else:
#         a = get_action()
        
#     return a

def get_dict():
    X = np.arange(1, 11)
    Y = np.arange(1, 22)
    res = dict()
    for x in X:
        for y in Y:
            res[(x, y)] = np.array([0.0, 0.0])
    return res