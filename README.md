Slides and material introducing rule-based modeling with BioNetGen and Python. Uses the VS Code extension for BioNetGen and the PyBioNetGen library with libRoadRunner for simulations. The [fit_data.ipynb](notebooks/fit_data.ipynb) notebook shows how to set up estimation of model parameters from data using the [PyPesto](https://github.com/icb-dcm/pypesto) package.

## Layout

- `models/` — BNGL model files. `stat_step1_binding.bngl` … `stat_step6_feedback.bngl` build the Module 1 cytokine–STAT–SOCS model one reaction step at a time.
- `notebooks/` — Jupyter notebooks, plus the data file used for fitting (`mm.csv`) and SBML exports. Notebooks load models from `../models/`, so run them from inside `notebooks/`.
- `Slides/` — lecture slides. `Slides/theme/` holds the shared beamer theme; each module (e.g. `Slides/module1-kinetics/`) has its own folder. The 2025 PowerPoint deck is kept for reference.
- `BNG-results/` — output from running models with the BioNetGen VS Code extension (see Setup below; not tracked in git)

## Setup

To have the BioNetGen VS Code extension write simulation results to `BNG-results/`:

1. Copy the template to create your own settings file:

   ```
   cp .vscode/settings.example.json .vscode/settings.json
   ```

   (On Windows, copy and rename the file in File Explorer, or use `copy .vscode\settings.example.json .vscode\settings.json`.)

2. Open `.vscode/settings.json` and replace `/ABSOLUTE/PATH/TO/RBM_Intro_BioNetGen` with the full path to this folder on your computer. To find it, right-click the folder in the VS Code Explorer and choose **Copy Path**. The path must be absolute; the extension does not understand `${workspaceFolder}` or relative paths. On Windows, use forward slashes (`C:/Users/you/RBM_Intro_BioNetGen/BNG-results`) or doubled backslashes.

3. Open this folder as the workspace in VS Code (**File > Open Folder**). Each model run will then be saved to `BNG-results/<model>/<timestamp>/`.

Your `.vscode/settings.json` is ignored by git, so your path stays local. If you skip this step, the extension writes results to the top level of the workspace instead.

## Building the slides

The slides are beamer (pdflatex) and need a standard TeX Live, MacTeX, or MiKTeX install.

```
cd Slides/module1-kinetics
latexmk module1-kinetics.tex      # PDF is written to build/
```

The plots are drawn from simulation output in `data/`. To regenerate it after changing a model, run `./make_data.sh` (requires `bionetgen` on your PATH).
