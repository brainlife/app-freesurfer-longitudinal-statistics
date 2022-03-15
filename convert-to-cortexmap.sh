#!/bin/bash

# set top variables
subjectID=`jq -r '._inputs[0].meta.subject' config.json`
fsaverage=`jq -r '.fsaverage' config.json`
spaces="native fsaverage"
surfaces="white pial inflated"
smooths="0 5 10 15 20 25"
aparcs="aparc aparc.a2009s aparc.DKTatlas"
hemi="lh rh"
output_measures="avg rate pc1fit pc1 spc"
stats_compute="area volume thickness curv"

# make cortexmap directory if hasn't been made yet
[ ! -d ./cortexmap/cortexmap/label ] && mkdir -p ./cortexmap ./cortexmap/cortexmap ./cortexmap/cortexmap/surf ./cortexmap/cortexmap/surf/mni ./cortexmap/cortexmap/func ./cortexmap/cortexmap/label

# loop through hemispheres and set anatomical structure tag
for h in ${hemi}
do
  echo "converting "$h" hemisphere data"
  if [[ ${h} == 'lh' ]]; then
    STRUCTURE="CORTEX_LEFT"
  else
    STRUCTURE="CORTEX_RIGHT"
  fi

  # loop through native and fsvaerage files
  for space in ${spaces}
  do
    echo "converting "$space" space data"
    if [[ ${space} == "native" ]]; then
      stem=".mgh"
      stem_dir=./${subjectID}
      out_stem=".native.func.gii"
      out_stem_dir=./cortexmap/cortexmap/surf
    else
      stem="."${fsaverage}".mgh"
      stem_dir=./${fsaverage}
      out_stem=".mni.func.gii"
      out_stem_dir=./cortexmap/cortexmap/surf/mni
    fi

    # convert surfaces (pial, inflated, white) and move to cortexmap datatype
    echo "converting surfaces"
    for surfs in ${surfaces}
    do
      if [ ! -f ./${out_stem_dir}/${h}.${surfs}.surf.gii ]; then
        mris_convert ./${stem_dir}/surf/${h}.${surfs} ./${out_stem_dir}/${h}.${surfs}.surf.gii

        wb_command -set-structure ./${out_stem_dir}/${h}.${surfs}.surf.gii ${STRUCTURE} -surface-type ANATOMICAL
      fi
    done

    echo "creating midthickness"
    # create midthickness surfaces
    if [ ! -f ./${out_stem_dir}/${h}.midthickness.surf.gii ]; then
      wb_command -surface-average \
        ./${out_stem_dir}/${h}.midthickness.surf.gii \
        -surf ./${out_stem_dir}/${h}.white.surf.gii \
        -surf ./${out_stem_dir}/${h}.pial.surf.gii

      wb_command -set-structure \
        ./${out_stem_dir}/${h}.midthickness.surf.gii \
        ${STRUCTURE} \
        -surface-type ANATOMICAL \
        -surface-secondary-type MIDTHICKNESS
    fi

    echo "converting labels"
    # convert labels
    for aparc in ${aparcs}
    do
      if [[ ${aparc} == "aparc.DKTatlas" ]] && [[ ${space} == 'fsaverage' ]]; then
        echo "skipping"
      else
        if [ ! -f ./cortexmap/cortexmap/label/${h}.${aparc}.${space}.label.gii ]; then
          mris_convert --annot ./${stem_dir}/label/${h}.${aparc}.annot ${stem_dir}/surf/${h}.pial ./cortexmap/cortexmap/label/${h}.${aparc}.${space}.label.gii

          wb_command -set-structure ./cortexmap/cortexmap/label/${h}.${aparc}.${space}.label.gii ${STRUCTURE}

          wb_command -set-map-names ./cortexmap/cortexmap/label/${h}.${aparc}.${space}.label.gii -map 1 "${h}"_"${aparc}"_"${space}"

          wb_command -gifti-label-add-prefix ./cortexmap/cortexmap/label/${h}.${aparc}.${space}.label.gii "${h}_" ./cortexmap/cortexmap/label/${h}.${aparc}.${space}.label.gii
        fi
      fi
    done

    # convert output surfaces to cortexmap datatype
    for i in ${stats_compute}
    do
      echo "converting "$i" stat"
      for j in ${output_measures}
      do
        for k in ${smooths}
        do
          if [ ! -f ./cortexmap/cortexmap/func/${h}.long.${i}.${j}.fwhm${k}${out_stem} ]; then
            # convert to gifti
            mris_convert -c ./${subjectID}/surf/${h}.long.${i}-${j}.fwhm$k${stem} ./${stem_dir}/surf/${h}.white ./cortexmap/cortexmap/func/${h}.long.${i}.${j}.fwhm${k}${out_stem}

            # set structure
            wb_command -set-structure ./cortexmap/cortexmap/func/${h}.long.${i}.${j}.fwhm${k}${out_stem} ${STRUCTURE}

            # set map name
            wb_command -set-map-names ./cortexmap/cortexmap/func/${h}.long.${i}.${j}.fwhm${k}${out_stem} -map 1 "${h}".long."${i}"."${j}".fwhm."${space}"

            # # set palette
            # wb_command -metric-palette ./cortexmap/cortexmap/func/${h}.long.${i}.${j}.fwhm${k}${out_stem} \
            #   MODE_AUTO_SCALE_PERCENTAGE \
            #   -pos-percent 4 96 \
            #   -interpolate true \
            #   -palette-name videen_style \
            #   -disp-pos true \
            #   -disp-neg true \
            #   -disp-zero true
            fi
        done
      done
    done
  done
done
