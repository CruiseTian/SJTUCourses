# USAGE
# python train.py --model output/digit_classifier.h5

# import the necessary packages
from pyimagesearch.models import LeNet
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.datasets import mnist
from sklearn.preprocessing import LabelBinarizer
from sklearn.metrics import classification_report
import argparse
from image_process import merge_minist_EI339
from output_log import Logger
import os, time, sys
import matplotlib.pyplot as plt

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-m", "--model", required=True,
	help="path to output model after training")
ap.add_argument("-lr", "--learning_rate", type=float, default=0.001,
	help="learning rate")
ap.add_argument("-ep", "--epoch", type=int, default=20,
	help="epoch")
ap.add_argument("-bs", "--batch_size", type=int, default=128,
	help="batch size")
args = vars(ap.parse_args())
print(args)

# initialize the initial learning rate, number of epochs to train
# for, and batch size
INIT_LR = args["learning_rate"]
EPOCHS = args["epoch"]
BS = args["batch_size"]

# log
timestamp = time.strftime('%Y%m%d_%H%M%S', time.localtime())
logSavePath = './log/reludrop_lr' + str(args["learning_rate"]) + '_bs' + str(args["batch_size"]) + '_epoch' + str(args["epoch"]) + '_' + timestamp
if not os.path.exists(logSavePath):
	os.mkdir(logSavePath)
figureSavePath = logSavePath + '/figure'
if not os.path.exists(figureSavePath):
	os.mkdir(figureSavePath)
sys.stdout = Logger(os.path.join(logSavePath, "output.txt"), sys.stdout)
sys.stderr = Logger(os.path.join(logSavePath, "error.txt"), sys.stderr)

# grab the MNIST dataset
# print("[INFO] accessing MNIST...")
# ((trainData, trainLabels), (testData, testLabels)) = mnist.load_data()
print("[INFO] accessing dataset...")
(trainData, trainLabels, testData, testLabels) = merge_minist_EI339()

# add a channel (i.e., grayscale) dimension to the digits
trainData = trainData.reshape((trainData.shape[0], 28, 28, 1))
testData = testData.reshape((testData.shape[0], 28, 28, 1))

# scale data to the range of [0, 1]
trainData = trainData.astype("float32") / 255.0
testData = testData.astype("float32") / 255.0

# convert the labels from integers to vectors
le = LabelBinarizer()
trainLabels = le.fit_transform(trainLabels)
testLabels = le.transform(testLabels)

# initialize the optimizer and model
print("[INFO] compiling model...")
opt = Adam(lr=INIT_LR)
# model = SudokuNet.build(width=28, height=28, depth=1, classes=10)
model = LeNet.build(width=28, height=28, depth=1, classes=20)
model.compile(loss="categorical_crossentropy", optimizer=opt,
	metrics=["accuracy"])

# train the network
print("[INFO] training network...")
H = model.fit(
	trainData, trainLabels,
	validation_data=(testData, testLabels),
	batch_size=BS,
	epochs=EPOCHS,
	verbose=1)

epochs=range(len(H.history['accuracy']))
plt.figure()
plt.plot(epochs,H.history['accuracy'],'b',label='Training acc')
plt.plot(epochs,H.history['val_accuracy'],'r',label='Validation acc')
plt.title('Traing and Validation accuracy')
plt.legend()
plt.savefig(os.path.join(figureSavePath, 'epoch{}_bs{}_lr{}_acc.jpg'.format(EPOCHS, BS, INIT_LR)))

plt.figure()
plt.plot(epochs,H.history['loss'],'b',label='Training loss')
plt.plot(epochs,H.history['val_loss'],'r',label='Validation val_loss')
plt.title('Traing and Validation loss')
plt.legend()
plt.savefig(os.path.join(figureSavePath, 'epoch{}_bs{}_lr{}_loss.jpg'.format(EPOCHS, BS, INIT_LR)))

# evaluate the network
print("[INFO] evaluating network...")
predictions = model.predict(testData)
print(classification_report(
	testLabels.argmax(axis=1),
	predictions.argmax(axis=1),
	target_names=[str(x) for x in le.classes_]))

# serialize the model to disk
print("[INFO] serializing digit model...")
model.save(args["model"], save_format="h5")
# model.save(logSavePath, save_format="h5")