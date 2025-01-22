import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import PillowWriter

# load waves
ydata = np.loadtxt("y.csv", delimiter=",")

# init plot
fig, ax = plt.subplots()
x_data = np.arange(0, 512)
ax.set_ylim(-1, 1)
ln, = ax.plot(ydata[0])

# init writer
writer = PillowWriter(
    fps = 30,
    metadata={
        "title": "CMSE-401 HW-01 Wave Animation",
        "artist": "RandumbEmma"
    }
)

# animate waves
with writer.saving(fig, "wave.gif", 100):
    for i in range(0, ydata.shape[0], 500):
        ln.set_ydata(ydata[i])
        writer.grab_frame()
