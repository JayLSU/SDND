import csv
import cv2
import numpy as np

lines = []
with open('../simulator_data/driving_log.csv') as csvfile:
	reader = csv.reader(csvfile)
	for line in reader:
		lines.append(line)

imgs = []
measurements = []
for line in lines:
	source_path = line[0]
	filename = source_path.split('\\')[-1]
	current_path = '../simulator_data/IMG/' + filename
	image = cv2.imread(current_path)
	imgs.append(image)
	measurement = float(line[3])
	measurements.append(measurement)

X_train = np.array(imgs)
y_train = np.array(measurements)
print(X_train.shape, y_train[1])

from keras.models import Sequential
from keras.layers import Flatten, Lambda, Dense, Convolution2D, MaxPooling2D
in_size = X_train[0].shape
print(X_train[0].shape)
model = Sequential()
model.add(Lambda(lambda x: x/255.0 - 0.5, input_shape = in_size))
model.add(Convolution2D(96,11,11,subsample = (4,4), activation='relu', border_mode = 'same'))
model.add(MaxPooling2D(pool_size = (3,3), strides = (2,2)))
model.add(Convolution2D(256,5,5,subsample = (1,1), activation='relu',border_mode = 'same'))
model.add(MaxPooling2D(pool_size = (3,3), strides = (2,2)))
model.add(Convolution2D(384,3,3,subsample = (1,1), activation='relu',border_mode = 'same'))
model.add(MaxPooling2D(pool_size = (3,3), strides = (2,2)))
model.add(Flatten())
model.add(Dense(4096))
model.add(Dense(2048))
model.add(Dense(1))
model.compile(loss = 'mse', optimizer = 'adam')
model.fit(X_train, y_train, validation_split = 0.2, shuffle = True, nb_epoch = 10)
model.save('model.h5')
exit()
