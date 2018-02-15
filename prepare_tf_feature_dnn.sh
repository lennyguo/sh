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
echo "Prepare data"  `date`
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
datadir=~/aurora4_s5_new/data/train_si84_multi
nj=8
#utils/split_data.sh $datadir $nj || exit 1;
sdata=$datadir/split$nj;
## feats_dir
feats_dir=~/aurora4_s5_new/features/train/40fbank

echo ==========================================================================
echo "Feature extraction start!"  `date`
echo ==========================================================================

# run parallel feature extraction using python code
$cmd JOB=1:$nj $sdata/log_40fbank/split.JOB.log \
    python ~/tfkaldi/main_save_tfrecord_func.py JOB $nj


# combine the feats
for job in $(seq $nj); do
   cat $feats_dir/$job/feats.scp >> $feats_dir/feats.scp
   cat $feats_dir/$job/cmvn.scp >> $feats_dir/cmvn.scp
   cat $feats_dir/$job/spk2utt >> $feats_dir/spk2utt
   cat $feats_dir/$job/text >> $feats_dir/text
   cat $feats_dir/$job/utt2spk >> $feats_dir/utt2spk
   cat $feats_dir/$job/wav.scp >> $feats_dir/wav.scp
   #rm $sdata/$job/feats.txt
done

echo ==========================================================================
echo "Feature extraction done!"  `date`
echo ==========================================================================
