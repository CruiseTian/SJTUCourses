# USAGE
# python train_digit_classifier.py --model output/digit_classifier.h5

# import the necessary packages
from pyimagesearch.models import SudokuNet
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.datasets import mnist
from sklearn.preprocessing import LabelBinarizer
from sklearn.metrics import classification_report
import argparse
from output_log import Logger
import os, time, sys
import matplotlib.pyplot as plt

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-m", "--model", required=True,
	help="path to output model after training")
args = vars(ap.parse_args())

# initialize the initial learning rate, number of epochs to train
# for, and batch size
INIT_LR = 1e-3
EPOCHS = 10
BS = 128

# log
timestamp = time.strftime('%Y%m%d_%H%M%S', time.localtime())
logSavePath = './test' + str(INIT_LR) + '_bs' + str(BS) + '_epoch' + str(EPOCHS) + '_' + timestamp
if not os.path.exists(logSavePath):
    	os.mkdir(logSavePath)
figureSavePath = logSavePath + '/figure'
if not os.path.exists(figureSavePath):
	os.mkdir(figureSavePath)
sys.stdout = Logger(os.path.join(logSavePath, "output.txt"), sys.stdout)
sys.stderr = Logger(os.path.join(logSavePath, "error.txt"), sys.stderr)

# grab the MNIST dataset
print("[INFO] accessing MNIST...")
((trainData, trainLabels), (testData, testLabels)) = mnist.load_data()

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
model = SudokuNet.build(width=28, height=28, depth=1, classes=10)
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