[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/soichih/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.609-blue.svg)](https://doi.org/10.25663/brainlife.app.609)

# Freesurfer Longitudinal Statistics
This app will compute statistics using the Freesurfer Longitudinal pipeline (https://surfer.nmr.mgh.harvard.edu/fswiki/LongitudinalProcessing). For this, a Freesurfer template output needs to be created from multiple Freesurfer recon-all outputs for a given participant. On brainlife.io, this can be accomplished by running the Freesurfer 7.1.1 Longitudinal Apps (Step 1 (https://doi.org/10.25663/brainlife.app.602) & 2 (https://doi.org/10.25663/brainlife.app.603)). The first of these steps creates a 'base' template, where both Freesurfer timepoints can then be transferred to in the second step. Once these are generated, this app can then be used to gather information about changes in measures between the timepoints in given cortical parcellations. This app will output a parc-stats datatype containing .csv files of all of the available statistics for each of the three Freesurfer parcellations. In combination with this, the surface measures will be converted to a cortexmap datatype to be used in visualizations and to perform analyzes across the surfaces of many participants.

### Authors
- Brad Caron (bacaron@iu.edu)

### Contributors
- Soichi Hayashi (hayashi@iu.edu)
- Franco Pestilli (franpest@indiana.edu)

### Funding
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)

### Citations

Please cite the following articles when publishing papers that used data, code or other resources created by the brainlife.io community.

1. Highly Accurate Inverse Consistent Registration: A Robust Approach, M. Reuter, H.D. Rosas, B. Fischl. NeuroImage 53(4), pp. 1181-1196, 2010. https://doi.org/10.1016/j.neuroimage.2010.07.020

2. Avoiding Asymmetry-Induced Bias in Longitudinal Image Processing, M. Reuter, B. Fischl. NeuroImage 57(1), pp. 19-21, 2011. https://doi.org/10.1016/j.neuroimage.2011.02.076

3. Within-Subject Template Estimation for Unbiased Longitudinal Image Analysis, M. Reuter, N.J. Schmansky, H.D. Rosas, B. Fischl. NeuroImage 61(4), pp. 1402-1418, 2012. https://doi.org/10.1016/j.neuroimage.2012.02.084

## Running the App

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.609](https://doi.org/10.25663/brainlife.app.609) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
    "freesurfers": [
        "./freesurfers/output",
        "./freesurfers/output_2"
    ],
    "timeframe":	"0 1.5",
    "freesurfer_template_base":	"./freesurfers/output_template/template",
    "fsaverage":  "fsaverage6",
    "validator_csv":  "longitudinal_stats_aparc",
    "_inputs": [
        {
            "id": "t1",
            "task_id": "62212f8eff10f482daba7b57",
            "subdir": "5e800dcbfa1b6328ce0df89c",
            "meta": {
                "subject": "subj001",
                "session": "1"
            }
	}
    ]
}
```

<!-- ### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bcd9059cf900271924f7 && mv 5b96bcd9059cf900271924f7 input/dwi

``` -->


3. Launch the App by executing `main`

```bash
./main
```

## Output

The main output of this App are a parc-stats directory containing three .csv files: longitudinal_stats_aparc, longitudinal_stats_aparc.a2009s, longitudinal_stats_aparc.DKTatlas. The second main output is a cortexmap datatype.


#### Product.json
The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing.

### Dependencies

This App requires the following libraries when run locally.

  - Freesurfer: https://surfer.nmr.mgh.harvard.edu/
  - Connectome Workbench: https://www.humanconnectome.org/software/connectome-workbench
  - Python 3.6>: https://www.python.org/downloads/
  - Pandas: https://pandas.pydata.org/
  - jsonlab: https://github.com/fangq/jsonlab.git
