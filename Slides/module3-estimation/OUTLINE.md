# Module 3: Sensitivity analysis and parameter estimation — lecture outline

Worked example: [notebooks/stat1_stat3_fitting.ipynb](../../notebooks/stat1_stat3_fitting.ipynb)
Model: [models/stat1_stat3.bngl](../../models/stat1_stat3.bngl)
Adapted from: COBB Foundations 2025, *Parameterizing Models* and *Brief Intro to Parameter Estimation* (FcεRI example replaced by the STAT model).

Section numbers in brackets refer to the notebook.

## Goals

By the end of this module you should be able to

- say where the parameters of a signaling model come from, and set plausible ranges when they are unknown
- convert concentrations and rate constants to copy-number units
- compute and interpret local and global sensitivities
- explain the difference between a parameter that affects the outputs and one the data can determine (identifiability)
- set up a fit as minimization of $\chi^2$, run multistart optimization, and judge the result with profile likelihoods
- use the model to decide which additional experiment would constrain the parameters

## 1. Where parameters come from (≈ 5 slides)

1. **Two kinds of parameters**: initial concentrations and rate constants. Model behavior depends on both, and on the model structure. *(reuse: ParameterEst-2025 slide 3)*
2. **Sources**: copy numbers from quantitative proteomics or flow cytometry; binding kinetics from biophysical measurements; the rest from fitting to dynamic data. *(reuse: ParameterizingModels-2025 slides 2–3, FcεRI parameter table as the historical example)*
3. **Copy numbers**: concentration → molecules ($cN_AV$); second-order rate constants → per-molecule rates ($k/N_AV$), with $V$ the volume where the reaction happens (medium per cell for ligand, cytoplasm, nucleus). BNGL parameter block from the model. Our setting: copy numbers known, 18 rate constants unknown.
4. **Plausible ranges by class of process**, in standard units: association $10^4$–$10^8$ M⁻¹s⁻¹, dissociation $10^{-4}$–$10$ s⁻¹, catalysis/synthesis $10^{-3}$–$10$ s⁻¹, decay $10^{-5}$–$10^{-2}$ s⁻¹. Set without looking at the particular values. Work in $\log_{10}$. *[1]*
5. **The model**: STAT1 and STAT3 compete for the receptor docking site; pSTAT3 induces SOCS3, which blocks the kinase. Built from Module 2 version 3. Rules figure or contact map; pSTAT1, pSTAT3, SOCS3 time courses. Biology hook: IL-6 signals mainly through STAT3; without SOCS3 the STAT1 response is prolonged (Croker et al. 2003). *[1]*
6. **Synthetic data**: 15 time points, 10% + floor noise; why synthetic data are the right way to test a method (we know the answer). *[2]*

## 2. Sensitivity analysis (≈ 7 slides)

1. **Parameter sweeps** as the simplest analysis (callback to Module 1/2 scans). *(reuse: ParameterizingModels-2025 slides 5–6)*
2. **Goals of sensitivity analysis**: which parameters matter most and least; use it to guide estimation. *(reuse: slide 7)*
3. **Local sensitivity**: normalized derivative $S_{ij} = \partial \ln O_i / \partial \ln p_j$; finite differences vs. forward sensitivity equations (exact, one run, what bngsim does). *(reuse: slides 8–9)*
4. **Local results for the STAT model**: ranking bar chart and $S(t)$ curves. Points to make: each STAT's own dephosphorylation dominates late times; competition makes `kS3on` lower pSTAT1; `ktx` and `ktl` have identical curves; ligand binding is irrelevant at saturating dose. *[3a]*
5. **Shortcomings of local analysis**: valid only near one point; misses interactions. *(reuse: slide 10)*
6. **Global sensitivity**: Latin hypercube sampling in log space; regression of output features on parameters; standardized coefficients and $R^2$. *(reuse: slides 11–12)*
7. **Global results**: heatmap across features (peak, time of peak, value at 60 min); where local and global disagree and why. *[3b]*

## 3. Identifiability (≈ 4 slides)

1. **Sensitive ≠ identifiable**: parameters can compensate for each other.
2. **Structural vs. practical non-identifiability**. Structural example from our model: only the product `ktx·ktl` affects any output.
3. **Fisher information matrix** $J^\mathsf{T}J$ from the sensitivities at the data points; eigenvalues ≈ inverse variances of parameter combinations. Computable before collecting data.
4. **Sloppiness**: eigenvalue spectrum spanning many decades, typical of systems biology models (Gutenkunst et al. 2007). STAT model spectrum and sloppiest/stiffest eigenvectors. *[4]*

## 4. Parameter estimation (≈ 9 slides)

1. **The estimation problem**: find $\mathbf{p}$ that minimizes the cost. *(reuse: ParameterEst-2025 slides 2–4)*
2. **Cost functions**: sum of squares; $\chi^2$ as $-2 \ln$ likelihood for Gaussian errors; goodness of fit ($\chi^2 \approx N - M$, $Q$ value) and the caveat about error estimates; estimating $\sigma$ from the best fit. *(reuse: slides 5–9, 13–14)*
3. **Optimizers**: gradient-free vs. gradient-based; least-squares methods (Gauss–Newton, Levenberg–Marquardt) use the residual Jacobian, which forward sensitivities provide. *(reuse: slides 10–12)*
4. **Multistart and the waterfall plot**: the landscape has many local minima; start from random points in the ranges. *[5]*
5. **Result 1: the fit is excellent** ($\chi^2$ below the value at the true parameters).
6. **Result 2: most parameters are not recovered.** Recovery plot across all good fits. Only the stiff combinations (dephosphorylation rates, `kact`) are pinned down, as the FIM predicted. *[5]*
7. **Profile likelihood**: definition, 95% threshold ($\Delta\chi^2 = 3.84$); STAT profiles for an identifiable, a one-sided, and a flat parameter. *(reuse: slide 15)* *[6]*
8. **A tempting shortcut**: fix insensitive parameters at a guess and fit the rest. It is safe only if they are insensitive at the guessed values. *[7]*
9. **Experimental design**: a dose-response experiment adds information in the sloppy directions; compare FIM spectra before running the experiment; refit and compare recovery. What still is not identifiable, and what experiment would address it. *[8]*

## 5. Wrap-up

- **Try it yourself**: notebook exercises (noise level; reparameterize `ktx·ktl`; add SOCS3 as a measured output; predict a SOCS3 knockout from each good fit).
- **Summary**
- **Additional reading**: Gutenkunst et al., *PLoS Comput. Biol.* 3, e189 (2007); Raue et al., *Bioinformatics* 25, 1923 (2009); Marino et al., *J. Theor. Biol.* 254, 178 (2008); Mitra & Hlavacek, *Curr. Opin. Syst. Biol.* 18, 9 (2019); Schälte et al., *Bioinformatics* 39, btad711 (2023, pyPESTO).

## Decisions

- The model counts molecules per cell and measures time in seconds; rate constants are given and fitted in standard units (M⁻¹ s⁻¹, s⁻¹) and converted in the model. A slide shows the conversions.
- MCMC and Bayesian uncertainty quantification move to a later module.
