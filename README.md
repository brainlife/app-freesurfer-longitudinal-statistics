<h1 align="center">FreeSurfer Longitudinal Statistics</h1>

<p align="center">
  Per-region tables and cortical surface maps of change between timepoints, from FreeSurfer longitudinal outputs of one participant.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.609"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.609-blue.svg" alt="Run on brainlife.io"></a>
  <a href="https://github.com/brainlife/app-freesurfer-longitudinal-statistics/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> 📍 **This branch, `v1.0-free_7_1_1-wb_1_5_0`, is the brainlife.io App Freesurfer Longitudinal Statistics** ([doi:10.25663/brainlife.app.609](https://doi.org/10.25663/brainlife.app.609)).

This App computes statistics with the [FreeSurfer longitudinal pipeline](https://surfer.nmr.mgh.harvard.edu/fswiki/LongitudinalProcessing) to measure how cortical area, volume, thickness and curvature change between timepoints within each region of the three FreeSurfer parcellations. It also converts the surface measures to a cortexmap dataset for visualisation and for analyses across the surfaces of many participants.

## 🧠 At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Computes longitudinal cortical change (average, rate, percent change, symmetrised percent change) with FreeSurfer long_mris_slopes from longitudinally processed timepoints, and outputs parcellation CSVs and a cortexmap.**

Builds a qdec table from the longitudinal timepoints and the timeframe, runs long_mris_slopes for the surface measures on fsaverage, then converts the results to GIFTI with Connectome Workbench and summarises them per region of the aparc, aparc.a2009s and DKT parcellations. Use it after running the FreeSurfer longitudinal base and long steps to quantify change between timepoints. Needs the longitudinal FreeSurfer outputs of each timepoint and the base template of the same subject.

| | |
|---|---|
| 📥 **Inputs** | `neuro/freesurfer` · `neuro/freesurfer/longitudinal-template` |
| 📤 **Outputs** | `neuro/parc-stats` · `neuro/cortexmap` |
| 🐳 **Container** | `brainlife/freesurfer:7.1.1` |
| ⚙️ **Resources** | 1 CPUs |
| 🔑 **Requires** | `FREESURFER_LICENSE` |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.609](https://doi.org/10.25663/brainlife.app.609) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `freesurfers` | `neuro/freesurfer` (longitudinal) | yes | FreeSurfer longitudinal (long) outputs of each timepoint of the subject, in time order. |
| `freesurfer_template_base` | `neuro/freesurfer/longitudinal-template` | yes | FreeSurfer longitudinal base template of the subject, built from the same timepoints. |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `parc_stats` | `neuro/parc-stats` | this will contain stats from all three freesurfer parcellations |
| `cortexmap` | `neuro/cortexmap` | this will contain surface versions of computed stats for visualizations and group analyses on the surface |

<details>
<summary><b>⚙️ Parameters</b> (3)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `fsaverage` | enum | `fsaverage6` | fsaverage space for statistic computation Options: `fsaverage`, `fsaverage4`, `fsaverage5`, `fsaverage6`, `fsaverage3`. |
| `validator_csv` | enum | `longitudinal_stats_aparc.a2009s` | this is the csv to be used by the validator Options: `longitudinal_stats_aparc`, `longitudinal_stats_aparc.a2009s`, `longitudinal_stats_aparc.DKTatlas`. |
| `timeframe` | string |  | this is a space separated list of timepoint sampling to compute the rate of change |

</details>

<!-- brainlife-app:end -->

## 🚀 Running the App

### ☁️ On brainlife.io

This App is the last step of a longitudinal workflow. First run the FreeSurfer 7.1.1 longitudinal Apps on the recon-all outputs of each participant:

1. [Step 1](https://doi.org/10.25663/brainlife.app.602) creates a within-subject `base` template from all timepoints.
2. [Step 2](https://doi.org/10.25663/brainlife.app.603) processes each timepoint against that template (`long` runs).

Then open this App at [doi.org/10.25663/brainlife.app.609](https://doi.org/10.25663/brainlife.app.609), choose the `long` outputs of every timepoint in time order (`neuro/freesurfer`, tag `longitudinal`) and the base template (`neuro/freesurfer/longitudinal-template`), and set:

- `timeframe`: the time of each timepoint in years, separated by spaces (for example `0 1.5`); the first timepoint is always taken as 0.
- `fsaverage`: the fsaverage surface used for the surface maps (`fsaverage3` to `fsaverage6`, or `fsaverage`; default `fsaverage6`).
- `validator_csv`: the table brainlife.io shows as a preview.

The App archives a `neuro/parc-stats` dataset and a `neuro/cortexmap` dataset to your project.

### 💻 Locally

You need [Singularity/Apptainer](https://apptainer.org/), [`jq`](https://jqlang.github.io/jq/), a [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/registration.html), and `SUBJECTS_DIR` pointing to a FreeSurfer subjects directory that contains the chosen fsaverage subject (it is copied into the working directory). `main` uses the `brainlife/freesurfer:7.1.1`, `brainlife/connectome_workbench:1.5.0` and `brainlife/freesurfer-stats:1.2` containers.

1. Clone this repository and check out the registered version (`git checkout v1.0-free_7_1_1-wb_1_5_0`).
2. Create `config.json` (see `config.json.sample`). The subject ID is read from `_inputs[0].meta.subject`:

   ```json
   {
       "freesurfers": [
           "./freesurfers/output",
           "./freesurfers/output_2"
       ],
       "timeframe": "0 1.5",
       "freesurfer_template_base": "./freesurfers/output_template/template",
       "fsaverage": "fsaverage6",
       "validator_csv": "longitudinal_stats_aparc",
       "_inputs": [
           { "id": "t1", "meta": { "subject": "subj001", "session": "1" } }
       ]
   }
   ```

3. Export your license and run the App:

   ```bash
   export FREESURFER_LICENSE="$(cat ~/freesurfer/license.txt)"
   ./main
   ```

### 🔬 How it works

1. `compute-long-stats.sh` builds a qdec table from the timepoints and `timeframe`, runs `long_mris_slopes` for area, volume, thickness and curvature (smoothed surface maps on fsaverage) and `long_stats_slopes` for the regional statistics of each parcellation. Each measure is reported as the temporal average (`avg`), rate of change (`rate`), percent change (`pc1`, `pc1fit`) and symmetrised percent change (`spc`).
2. `convert-to-cortexmap.sh` converts surfaces, labels and measure maps (FWHM 0 to 25 mm) to GIFTI with Connectome Workbench.
3. `createParcellationCSVs.py` writes one table per parcellation.

## 📦 Outputs

```text
parc_stats/parc-stats/
├── longitudinal_stats_aparc.csv
├── longitudinal_stats_aparc.a2009s.csv
└── longitudinal_stats_aparc.DKTatlas.csv
cortexmap/cortexmap/
├── surf/        white, pial and inflated surfaces (native; fsaverage under surf/mni/)
├── label/       aparc, aparc.a2009s and DKT labels (*.label.gii)
└── func/        <hemi>.long.<measure>.<avg|rate|pc1fit|pc1|spc>.fwhm<0–25>.<native|mni>.func.gii
```

## 🩺 Troubleshooting

- **`stats computations failed somewhere. please check logs and derivatives`**: the DKT table was not produced. Make sure the timepoints and the base template come from the FreeSurfer longitudinal Apps for the same subject, and that `timeframe` has one value per timepoint.
- **`Please set FREESURFER_LICENSE in .bashrc`**: export your FreeSurfer license text in `FREESURFER_LICENSE` before running `main`.

## 📚 Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Reuter M, Rosas HD, Fischl B. Highly accurate inverse consistent registration: a robust approach. *NeuroImage* 53(4):1181–1196 (2010). [doi:10.1016/j.neuroimage.2010.07.020](https://doi.org/10.1016/j.neuroimage.2010.07.020)
- Reuter M, Fischl B. Avoiding asymmetry-induced bias in longitudinal image processing. *NeuroImage* 57(1):19–21 (2011). [doi:10.1016/j.neuroimage.2011.02.076](https://doi.org/10.1016/j.neuroimage.2011.02.076)
- Reuter M, Schmansky NJ, Rosas HD, Fischl B. Within-subject template estimation for unbiased longitudinal image analysis. *NeuroImage* 61(4):1402–1418 (2012). [doi:10.1016/j.neuroimage.2012.02.084](https://doi.org/10.1016/j.neuroimage.2012.02.084)
- Freesurfer Longitudinal Statistics. brainlife.io App. [doi:10.25663/brainlife.app.609](https://doi.org/10.25663/brainlife.app.609)
- Fischl. FreeSurfer. *NeuroImage* 62:774-781 (2012). [doi:10.1016/j.neuroimage.2012.01.021](https://doi.org/10.1016/j.neuroimage.2012.01.021)
- Marcus et al. Informatics and Data Mining Tools and Strategies for the Human Connectome Project. *Frontiers in Neuroinformatics* 5 (2011). [doi:10.3389/fninf.2011.00004](https://doi.org/10.3389/fninf.2011.00004)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## 👥 Authors

- Brad Caron

**Contributors:** Soichi Hayashi, Franco Pestilli

## 💰 Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## ⚖️ License

MIT. FreeSurfer is distributed under its own [license](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense).
