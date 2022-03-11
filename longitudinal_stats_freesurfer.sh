#!/bin/bash

# top variables
template_base=`jq -r '.freesurfer_template_base' config.json`
freesurfers=($(jq -r '.freesurfers' config.json  | tr -d '[]," '))
subjectID=`jq -r '._inputs[0].meta.subject' config.json`
timeframe=(`jq -r '.timeframe' config.json`)
fsaverage=`jq -r '.fsaverage' config.json`
stats_compute=(`jq -r '.stats' config.json`) #area, volume, thickness, thickness, thicknessstd, meancurv, gauscurv, foldind, curvind
hemi="lh rh"
aparcs="aparc aparc.a2009s aparc.DKTatlas"

# copy over freesurfers (long)
for (( i=1; i<=${#freesurfers[*]}; i++ ))
do
  cp -R ${freesurfers[$i-1]} ./${subjectID}_${i}.long.${subjectID} && chmod -R +w ./${subjectID}_${i}.long.${subjectID}
done

# copy over template (base)
cp -R ${template_base} ./${subjectID}
chmod -R +w ./${subjectID}

# copy over fsaverage dir
cp -R ${SUBJECTS_DIR}/${fsaverage} ./${fsaverage}
chmod -R +w ./${fsaverage}

# create table
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

# generate surface files of measures. useful to create cortexmap data from
for i in ${stats_compute[*]}
do
  for h in ${hemi}
  do
    long_mris_slopes --qdec ./qdec/long.qdec.table.dat ${i} --hemi ${h} --do-avg --do-rate --do-pc1 --do-spc --do-label --time years --qcache ${fsaverage} --sd ./
  done
done

#### NEED TO FIGURE OUT CORTEXMAP STUFF

output_measures="avg rate pc1fit pc1 spc"
# generate stats files

for a in ${aparcs}
do
  for h in ${hemi}
  do
    for i in ${stats_compute[*]}
    do
      [ ! -f ./${subjectID}/stats/long.${h}.${a}.stats.${i}-spc.dat ] && long_stats_slopes --qdec ./qdec/long.qdec.table.dat --stats ${h}.${a}.stats --meas $i --sd ./ --do-avg --do-rate --do-pc1fit --do-pc1 --do-spc --time years --out-rate long.${h}.${a}.stats.${i}-rate.dat --out-avg long.${h}.${a}.stats.${i}-avg.dat --out-pc1fit long.${h}.${a}.stats.${i}-pc1fit.dat --out-pc1 long.${h}.${a}.stats.${i}-pc1.dat --out-spc long.${h}.${a}.stats.${i}-spc.dat

      # grab data
      for j in ${output_measures}
      do
        if [ ! -f ./${h}.${a}.stats.${i}-${j}.txt ]; then
          tmp=`cat ${subjectID}/stats/long.${h}.${a}.stats.${i}-${j}.dat | grep "Measure"`
          echo ${tmp#"Measure:${i}-${j}"} >> ./${h}.${a}.stats.${i}-${j}.txt

          tmp=`cat ${subjectID}/stats/long.${h}.${a}.stats.${i}-${j}.dat | grep "${subjectID}"`
          echo ${tmp#"${subjectID}"} >> ./${h}.${a}.stats.${i}-${j}.txt
        fi
      done
    done
  done
done

### to do
# 1. write script to convert surface data into cortexmap datatype
# 2. create repo on github and app on bl
# 3. beta testing multiple subjects
