#!/bin/bash
. setup.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: ./run.sh <type>"
    echo "<type> should be either 'train' or 'eval'"
    exit 0
fi
exp_dir=/home/allyoushawn/exps/disentangle_exp/ssae_ali
ali_dir=alignments/ssae_ali
lr=0.0005
p_hid_dim=128
s_hid_dim=128
cuda_id=0
model_type=default
epoch_num=20
batch_size=64
feat_dim=39


if [ $1 == "train" ]; then
    # [ Training Phase]

    # Features
    echo "Preparing features"
    ark=$kaldi_feat_loc/train.39.cmvn.ark
    ali=$ali_dir/train.ali
    op_feat_dir=$feat_loc/train_feats
    ./make_feats.sh $ark $ali $op_feat_dir

    # Split data
    echo "Split data"
    #spk_num=$(ls ${op_feat_dir}/${seq_len}/ | wc -l)
    spk_num=120
    proportion=0.8

    ./split_data.py $op_feat_dir $seq_len $spk_num $proportion

    # Training model
    echo "Training model"

    rm -rf $exp_dir/*

    ./train.sh $lr $p_hid_dim $s_hid_dim $cuda_id $model_type $epoch_num $seq_len $batch_size $feat_dim $exp_dir $op_feat_dir


    exit 0
fi

if [ $1 == "eval" ]; then
    # Test

    echo "Preparing features for query.dev"
    ark=$kaldi_feat_loc/query.dev.39.cmvn.ark
    ali=$ali_dir/query.dev.ali
    op_feat_dir=$feat_loc/query_dev_feats
    ./make_feats.sh $ark $ali $op_feat_dir
    echo "Split data for dev query"
    spk_num=$(ls ${op_feat_dir}/${seq_len}/ | wc -l)
    ./split_all_data.py $op_feat_dir $seq_len $spk_num

    echo "Generate embed for query.dev"
    ./test.sh $lr $p_hid_dim $s_hid_dim $cuda_id $model_type $seq_len $batch_size $feat_dim $exp_dir $op_feat_dir

    echo "Generate embed pkl for query.dev"
    ./gen_pkl_embed.py ${op_feat_dir}/phonetic_all/phonetic_all_0 $ali query_dev.pkl


    echo "Preparing features for test set (doc)"
    ark=$kaldi_feat_loc/test.39.cmvn.ark
    ali=$ali_dir/test.ali
    op_feat_dir=$feat_loc/test_feats
    ./make_feats.sh $ark $ali $op_feat_dir

    echo "Split data for test set (doc)"
    spk_num=$(ls ${op_feat_dir}/${seq_len}/ | wc -l)
    ./split_all_data.py $op_feat_dir $seq_len $spk_num


    echo "Generate embed for test set (doc)"
    ./test.sh $lr $p_hid_dim $s_hid_dim $cuda_id $model_type $seq_len $batch_size $feat_dim $exp_dir $op_feat_dir

    echo "Generate embed pkl for test (doc)"
    ./gen_pkl_embed.py ${op_feat_dir}/phonetic_all/phonetic_all_0 $ali doc.pkl
fi
