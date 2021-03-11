# import the necessary packages
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D
from tensorflow.keras.layers import MaxPooling2D
from tensorflow.keras.layers import Activation
from tensorflow.keras.layers import Flatten
from tensorflow.keras.layers import Dense
from tensorflow.keras.layers import Dropout

class LeNet:
	@staticmethod
	def build(width, height, depth, classes):
		# initialize the model
		model = Sequential()
		inputShape = (height, width, depth)

		# first set of CONV => RELU => POOL layers
		model.add(Conv2D(6, (5, 5), padding="same",
			input_shape=inputShape))
		model.add(Activation("relu"))
		model.add(MaxPooling2D(pool_size=(2, 2)))

		# second set of CONV => RELU => POOL layers
		model.add(Conv2D(16, (5, 5), padding="valid"))
		model.add(Activation("relu"))
		model.add(MaxPooling2D(pool_size=(2, 2)))

        # conv layer3
		model.add(Conv2D(120, (5, 5), padding="valid"))
		model.add(Activation("relu"))

		# first set of FC => RELU layers
		model.add(Flatten())
		model.add(Dense(84))
		model.add(Activation("relu"))
		model.add(Dropout(0.5))

		# # second set of FC => RELU layers
		# model.add(Dense(64))
		# model.add(Activation("relu"))
		# model.add(Dropout(0.5))

		# softmax classifier
		model.add(Dense(classes))
		model.add(Activation("softmax"))

		# return the constructed network architecture
		return model