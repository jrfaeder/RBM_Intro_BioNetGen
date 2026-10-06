Slides and material introducing rule-based modeling with BioNetGen and Python. Uses the VS Code extension for BioNetGen and the PyBioNetGen library with libRoadRunner for simulations. The [fit_data.ipynb](notebooks/fit_data.ipynb) notebook shows how to set up estimation of model parameters from data using the [PyPesto](https://github.com/icb-dcm/pypesto) package.

## Layout

- `models/` — BNGL model files
- `notebooks/` — Jupyter notebooks, plus the data file used for fitting (`mm.csv`) and SBML exports. Notebooks load models from `../models/`, so run them from inside `notebooks/`.
- `Slides/` — lecture slides
