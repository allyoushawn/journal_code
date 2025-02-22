#!/bin/bash

#[ -f path.sh ] && . ./path.sh

if [ $# != 11 ] ; then 
  echo "usage: train.sh <lr> <p_hidden_dim> <s_hidden_dim> <CUDA_DEVICE> <model type> <n_epochs for training> <seq_len> <batch_size> <feat_dim> <exp_dir> <feat_dir>"
  echo "model_type: default, noGAN, noGANspk"
  echo "e.g. train.sh 0.0005 128 128 0 default 20"
  exit 1
fi

# Speaker disentangle
# train.sh 0.0005 128 128 0 default 20

# Original Audio2Vec
# train.sh 0.0005 128 128 0 noGANspk 20


stack_num=3
#path=/home/grtzsohalf/Desktop/Audio-Word2Vec
#feat_dir=/home/grtzsohalf/Desktop/LibriSpeech
init_lr=$1
p_dim=$2
s_dim=$3
device_id=$4
model_type=$5
n_epochs=$6
seq_len=$7
batch_size=$8
feat_dim=$9

if [ "$model_type" != "default" ] && [ "$model_type" != "noGAN" ] && [ "$model_type" != "noGANspk" ] ; then
  echo "Invalid model_type!"
  exit 1
fi
exp_dir=${10}
feat_dir=${11}

mkdir -p $exp_dir
model_dir=$exp_dir/model_lr${init_lr}_$p_dim\_$s_dim\_$model_type
log_dir=$exp_dir/log_lr${init_lr}_$p_dim\_$s_dim\_$model_type

#model_dir=$path/exp/model_lr${init_lr}_$p_dim\_$s_dim\_$model_type
#log_dir=$path/exp/log_lr${init_lr}_$p_dim\_$s_dim\_$model_type
tf_model_dir=$model_dir/tf_model
tf_log_dir=$log_dir/tf_log

mkdir -p $feat_dir
mkdir -p $model_dir
mkdir -p $log_dir
mkdir -p $tf_model_dir
mkdir -p $tf_log_dir


### training ###
export CUDA_VISIBLE_DEVICES=$device_id
python3 audio2vec_train.py --init_lr=$init_lr --batch_size=$batch_size --seq_len=$seq_len --feat_dim=$feat_dim \
  --p_hidden_dim=$p_dim --s_hidden_dim=$s_dim --n_epochs=$n_epochs --stack_num=$stack_num $tf_log_dir $tf_model_dir \
  $feat_dir/train_AE.scp $feat_dir/test_AE.scp $feat_dir $model_type
