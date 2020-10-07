import matplotlib.pyplot as plt
from math import sin, cos, pi, sqrt, atan2
from random import randint

two_pi = 2 * pi
accuracy = 1000

class Wave:
	def __init__(self, x = 0, y = 0, freq = 1):
		self.x = x
		self.y = y
		self.freq = freq
		self.amp = sqrt(x * x + y * y)
		self.phase = atan2(y, x)

# generate a sin wave with specific characteristics
def genSinWave(freq, amplitude):
	return [amplitude + amplitude * sin(c / accuracy * freq * two_pi) for c in range(accuracy)]

# adding multiple waves to make a composite signal
def addWaves(waves):
	newWave = [0] * len(waves[0])
	for j in range(len(newWave)):
		for i in range(len(waves)):
			newWave[j] += waves[i][j]
	return newWave

# discrete fourier transform algorithm
def dft(wave):
	newWave = []	# array of sinusoids
	N = len(wave)
	for k in range(N):	# looping through frequencies
		real = 0		# real part of the sinusoid
		imag = 0		# imaginary part of the sinusoid
		for n in range(N):	# summming the values
			angle = (two_pi * k * n) / N
			real += wave[n] * cos(angle)
			imag -= wave[n] * sin(angle)
		w = Wave(real / N * 2, imag / N * 2, k)	# creating wave object
		newWave.append(w)	# adding sinusoid to the array
	return newWave

# define wave characteristics
graphs = 5
freqs 	= [randint(1, 50) for i in range(0, graphs)]
amps 	= [randint(1, 20) for i in range(0, graphs)]
waves 	= []
# create waves
for i in range(len(freqs)):
	waves.append(genSinWave(freqs[i], amps[i]))
xplot = [c / accuracy for c in range(accuracy)]

# generate composite signal
wsum = addWaves(waves)

# do dft on the composite signal
newWaves = dft(wsum)
# find the waves with the highest frequencies
newWaves.sort(key=lambda a : a.amp, reverse=True)

# showing the results
plt.figure()

subplots = (len(waves) + 1) * 100 + 11
plt.subplot(subplots)
subplots += 1
plt.plot(xplot, wsum)

wsumMax = max(wsum)

for i in range(0, 10):
	print("{0} : {1}".format(newWaves[i].freq, newWaves[i].amp))

for i in range(1, 1 + graphs * 2, 1):
	if accuracy - newWaves[i].freq in freqs:
		continue
	plt.subplot(subplots)
	subplots += 1
	plt.ylim(-0.05 * wsumMax, wsumMax + 0.05 * wsumMax)
	plt.plot(xplot, genSinWave(newWaves[i].freq, newWaves[i].amp))

plt.show()



