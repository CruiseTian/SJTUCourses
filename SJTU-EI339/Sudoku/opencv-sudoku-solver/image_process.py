import cv2
import numpy as np
import os
from tensorflow.keras.datasets import mnist
import random
import matplotlib.pyplot as plt

debug=False
path='dataset/EI339-CN/'

def single_image(img):
    img=cv2.cvtColor(img,cv2.COLOR_RGB2GRAY)
    img=cv2.resize(img,(28,28))
    for x in range(28):
        for y in range(28):
            img[x,y]=255-img[x,y]
    return img

def generate_CN_Data():
    trainData=[]
    testData=[]
    trainLabel=[]
    testLabel=[]
    for num in range (1,11):
        trainfilename=os.listdir(path+str(num)+'/training')
        testfilename=os.listdir(path+str(num)+'/testing')
        for filename in trainfilename:
            try:
                img=cv2.imread(path+str(num)+'/training/'+filename)
                img=single_image(img)
                if debug:
                    print(filename)
                    cv2.namedWindow('train-img', cv2.WINDOW_NORMAL)
                    cv2.imshow('train-img', img)
                    cv2.waitKey(0)
                trainData.append(img)
                trainLabel.append(9+num)
            except Exception as e:
                print(e)
        for filename in testfilename:
            try:
                img=cv2.imread(path+str(num)+'/testing/'+filename)
                img=single_image(img)
                if debug:
                    print(filename)
                    cv2.namedWindow('test-img', cv2.WINDOW_NORMAL)
                    cv2.imshow('test-img', img)
                    cv2.waitKey(0)
                testData.append(img)
                testLabel.append(9+num)
            except Exception as e:
                print(e)
    # print(len(trainData),len(testData))
    return trainData,trainLabel, testData,testLabel


def merge_minist_EI339():
    ((mtrainData, mtrainLabels), (mtestData, mtestLabels)) = mnist.load_data()
    mtrainData = mtrainData.reshape((mtrainData.shape[0], 28, 28))
    mtestData = mtestData.reshape((mtestData.shape[0], 28, 28))
    mtrainData=mtrainData.tolist()
    mtrainLabels=mtrainLabels.tolist()
    mtestData=mtestData.tolist()
    mtestLabels=mtestLabels.tolist()
    CNtrainData, CNtrainLabel, CNtestData, CNtestLabel=generate_CN_Data()
    trainData=mtrainData+CNtrainData
    testData=mtestData+CNtestData
    trainLabel=mtrainLabels+CNtrainLabel
    testLabel=mtestLabels+CNtestLabel
    random.seed(1)
    random.shuffle(trainData)
    random.seed(1)
    random.shuffle(testData)
    random.seed(1)
    random.shuffle(trainLabel)
    random.seed(1)
    random.shuffle(testLabel)
    # for i in range (10):
    #     print(trainLabel[i])
    #     plt.imshow(trainData[i])
    #     plt.show()
    return np.array(trainData),np.array(trainLabel), np.array(testData),np.array(testLabel)