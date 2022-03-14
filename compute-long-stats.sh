#!/bin/bash

## top variables
template_base=`jq -r '.freesurfer_template_base' config.json`
freesurfers=($(jq -r '.freesurfers' config.json  | tr -d '[]," '))
subjectID=`jq -r '._inputs[0].meta.subject' config.json`
timeframe=(`jq -r '.timeframe' config.json`)
fsaverage=`jq -r '.fsaverage' config.json`
stats_compute_surface="area volume thickness curv"
stats_compute="area volume thickness thicknessstd thickness.T1 meancurv gauscurv foldind curvind"
hemi="lh rh"
aparcs="aparc aparc.a2009s aparc.DKTatlas"
output_measures="avg rate pc1fit pc1 spc"

# make directories if needed
[ ! -d ./tmpstats ] && mkdir -p ./tmpstats

## define functions
function callLongStats() {
  long_mris_slopes --qdec ./qdec/long.qdec.table.dat --meas $1 --hemi $2 --do-avg --do-rate --do-pc1 --do-pc1fit --do-spc --do-label --time years --qcache $3 $4 --sd ./
}

## copy over freesurfers (long)
for (( i=1; i<=${#freesurfers[*]}; i++ ))
do
  cp -R ${freesurfers[$i-1]} ./${subjectID}_${i}.long.${subjectID} && chmod -R +w ./${subjectID}_${i}.long.${subjectID}
done

# copy over template (base)
cp -R ${template_base} ./${subjectID}
chmod -R +w ./${subjectID}

# copy over fsaverage dir
# cp -R ${SUBJECTS_DIR}/${fsaverage} ./${fsaverage}
# chmod -R +w ./${fsaverage}

## create table
mkdir ./qdec
echo "fsid fsid-base years" >> ./qdec/long.qdec.table.dat

for (( i=1; i<=${#freesurfers[*]}; i++ ))
do
  if [[ ${i} == 1 ]]; then
    year=0
  else
    year=${timeframe[$i-1]}
  fi
  echo "${subjectID}_${i} ${subjectID} ${year}" >> ./qdec/long.qdec.table.dat
done

## generate surface files of measures. useful to create cortexmap data from
for i in ${stats_compute_surface}
do
  # check if stat is area or volume. if so, pass jacobian flag
  if [[ ${i} == "area" ]] | [[ ${i} == "volume" ]]; then
    jac_flag="--jac"
  else
    jac_flag=""
  fi

  for h in ${hemi}
  do
    if [ ! -f ./${subjectID}/surf/${h}.long.${i}-spc.fwhm25.${fsaverage}.mgh ]; then
      callLongStats $i $h ${fsaverage} $jac_flag
    fi
  done
done

## loop through aparcs, hemispheres, and stats to compute, generate stats table, and then output the data into a txt file that's easier to work with in python3
for a in ${aparcs}
do
  for h in ${hemi}
  do
    for i in ${stats_compute}
    do
      # generate stats table
      [ ! -f ./${subjectID}/stats/long.${h}.${a}.stats.${i}-spc.dat ] && long_stats_slopes --qdec ./qdec/long.qdec.table.dat --stats ${h}.${a}.stats --meas $i --sd ./ --do-avg --do-rate --do-pc1fit --do-pc1 --do-spc --time years --out-rate long.${h}.${a}.stats.${i}-rate.dat --out-avg long.${h}.${a}.stats.${i}-avg.dat --out-pc1fit long.${h}.${a}.stats.${i}-pc1fit.dat --out-pc1 long.${h}.${a}.stats.${i}-pc1.dat --out-spc long.${h}.${a}.stats.${i}-spc.dat

      # grab data and output intot text file
      for j in ${output_measures}
      do
        if [ ! -f ./tmpstats/${h}.${a}.stats.${i}-${j}.txt ]; then
          tmp=`cat ${subjectID}/stats/long.${h}.${a}.stats.${i}-${j}.dat | grep "Measure"` # to grab the labels

          echo ${tmp#"Measure:${i}-${j}"} >> ./tmpstats/${h}.${a}.stats.${i}-${j}.txt # export labels

          tmp=`cat ${subjectID}/stats/long.${h}.${a}.stats.${i}-${j}.dat | grep "${subjectID}"` # to grab data
          echo ${tmp#"${subjectID}"} >> ./tmpstats/${h}.${a}.stats.${i}-${j}.txt # export data
        fi
      done
    done
  done
done

## file check at end
if [ ! -f ./tmpstats/${h}.${a}.stats.${i}-${j}.txt ]; then
  echo "something went wrong. check logs and derivatives"
  # exit 1
fi


### to do
# 1. write code to compute stats for subcortical segmentation (aseg.mgz)
# 2. beta testing multiple subjects
