from env import *
import pandas as pd
import matplotlib.pyplot as plt
import pickle
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

# def train(Q, N, N0=100, gamma=0.9, lr = 0.1):
def train(Q, gamma=0.9, lr = 0.01):
    flag = False
    s = init()
    key = tuple(s)
    # a = epsilon_greedy(Q, N, key, N0)
    a = epsilon_greedy(Q, key)
    env = Easy21()
    while not flag:
        key = tuple(s)
        #执行动作
        s_, r, flag = env.step(s, a)
        #更新计数
        # N[key][a] += 1
        #计算delta
        delta = r - Q[key][a]
        #选择下一步动作
        if not flag:
            key1 = tuple(s_)
            # a1 = epsilon_greedy(Q, N, key1, N0)
            a1 = epsilon_greedy(Q, key1)
            delta += gamma * max(Q[key1][0], Q[key1][1])
        #更新Q
        Q[key][a] += lr * delta
        
        #赋值
        if not flag:
            a = a1
            s = s_
    return r

def test(Q):
    flag = False
    s = init()
    key = tuple(s)
    a = np.argmax(Q[key])
    env = Easy21()
    while not flag:
        #执行动作
        key = tuple(s)
        s, r, flag = env.step(s, a)
        #选择下一步动作
        if not flag:
            a = np.argmax(Q[tuple(s)])
    return r

def plot(filename, title):
    with open(filename, "rb") as file:
        Q = pickle.load(file)
        
    X = np.arange(1, 11)
    Y = np.arange(1, 22)
    Z = np.zeros((21, 10))
    
    for key in Q:
        x = key[0]
        y = key[1]
        Z[y - 1][x - 1] = np.max(Q[key])
        
    X, Y = np.meshgrid(X, Y)
    fig = plt.figure()
    ax = Axes3D(fig)
    ax.plot_surface(X, Y, Z, cmap=cm.coolwarm)
    ax.set_xlabel('Dealer showing')
    ax.set_ylabel('Play sum')
    ax.set_zlabel('value')
    plt.title(title)
    plt.savefig(title+'.jpg')
    plt.show()

        
EPISODE = 100000

if __name__ == "__main__":
    Q = get_dict()
    # N = get_dict()
    test_win = 0
    train_win = 0
    for episode in range(EPISODE):
        # reward = train(Q, N)
        reward = train(Q)
        if reward == 1:
            train_win += 1
    for k in range(100000):
        reward = test(Q)
        if reward == 1:
            test_win += 1
    filename = "q-learning.pickle"
    with open(filename, "wb") as file:
        pickle.dump(Q, file)

    q_learning = "q-learning.pickle"

    # plot(q_learning, "q-learning")
    print("train_win:", float(train_win)/EPISODE)
    print("win_rate:", float(test_win)/100000)

# lg_epoch = [np.log10(10), np.log10(100), np.log10(1000), np.log10(5000), np.log10(10000), np.log10(50000), np.log10(100000), np.log10(1000000)]
# epoch = [10,100,1000,10000,50000,100000,1000000]
# winningrate = [0.05791, 0.28506, 0.43211, 0.46255, 0.47433, 0.47384, 0.47757]
# fig = plt.figure()
# plt.plot(epoch, winningrate, color = 'b', marker="s")
# plt.xlabel("eposide")
# plt.ylabel("winning rate")
# plt.savefig("winrate.png")
# plt.show()