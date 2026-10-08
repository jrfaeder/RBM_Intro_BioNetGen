"""Make the figures for the worksheets (run from Worksheets/)."""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import bngsim

model = bngsim.Model.from_bngl("../models/stat_step6_feedback.bngl")
sim = bngsim.Simulator(model, method="ode")
model.reset()
res = sim.run(t_span=(0, 600), n_points=6001)
t, y = res.time, res.observables["pSTAT"]
i = int(np.argmax(y))

fig, ax = plt.subplots(figsize=(5.2, 2.6))
ax.plot(t, y, color="#1B365D", lw=2)
ax.set_xlim(0, 150)
ax.set_ylim(0, 3.8)
ax.set_xlabel("time (min)")
ax.set_ylabel("total pSTAT (µM)")
ax.spines[["top", "right"]].set_visible(False)
# time of peak
ax.plot([t[i], t[i]], [0, y[i]], ls=":", color="#C8102E", lw=1.2)
ax.annotate("time of peak", xy=(t[i], 0.05), xytext=(t[i] + 6, 0.35),
            color="#C8102E", fontsize=9, arrowprops=dict(arrowstyle="->", color="#C8102E", lw=0.8))
# peak height
ax.annotate("peak height", xy=(t[i], y[i]), xytext=(t[i] + 14, y[i] + 0.2),
            color="#C8102E", fontsize=9, arrowprops=dict(arrowstyle="->", color="#C8102E", lw=0.8))
# adapted level
ax.axhline(y[-1], xmin=0.55, xmax=1, ls="--", color="#1F7A8C", lw=1.2)
ax.annotate("adapted level\n(late steady state)", xy=(120, y[-1]), xytext=(95, 1.4),
            color="#1F7A8C", fontsize=9, ha="center",
            arrowprops=dict(arrowstyle="->", color="#1F7A8C", lw=0.8))
fig.tight_layout()
fig.savefig("figures/pstat_pulse.svg")
print("wrote figures/pstat_pulse.svg")
