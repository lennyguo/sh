#!/bin/bash
# Copyright 2013   Daniel Povey
#           2014   David Snyder
# Apache 2.0.
#
# Modified by Jinxi Guo 2017
#
# See README.txt for more info on data required.
# Results (EERs) are inline in comments below.

# This example script is still a bit of a mess, and needs to be
# cleaned up, but it shows you all the basic ingredients.
echo ==========================================================================
echo "save TFrecords"  `date`
echo ==========================================================================

# set up the configuration
#. ./cmd.sh
#. ./path.sh
. ./cmd.sh
. ./path.sh
set -e
#export PATH=~/tfkaldi:$PATH

cmd="run.pl"

## split scp inside data folder
datadir=~/aurora4_s5_new/features/train/40fbank

python ~/tfkaldi/main_shuffle.py

mv ~/aurora4_s5_new/features/train/40fbank/feats.scp ~/aurora4_s5_new/features/train/40fbank/feats_old.scp 

mv ~/aurora4_s5_new/features/train/40fbank/feats_shuffled.scp ~/aurora4_s5_new/features/train/40fbank/feats.scp

nj=4
utils/split_data.sh $datadir $nj || exit 1;
sdata=$datadir/split$nj;
## feats_dir
feats_dir=~/aurora4_s5_new/features/train/40fbank

echo ==========================================================================
echo "start saving TFrecord"  `date`
echo ==========================================================================

# run parallel feature extraction using python code
$cmd JOB=1:$nj $sdata/log/split.JOB.log \
    python ~/tfkaldi/main_save_tfrecord_job4.py JOB $nj

# move the tfrecord to the train files
mkdir -p $feats_dir/data_tf_train
for job in $(seq $nj); do
   mv $feats_dir/split$nj/$job/labels_data_$job.tfrecords $feats_dir/data_tf_train/
done
# move the validation data to the correct folder
mkdir -p $feats_dir/data_eval
mv $feats_dir/split$nj/1/val_data.pkl $feats_dir/data_eval
mv $feats_dir/split$nj/1/val_labels.pkl $feats_dir/data_eval

echo ==========================================================================
echo "finish saving TFrecord"  `date`
echo ==========================================================================
