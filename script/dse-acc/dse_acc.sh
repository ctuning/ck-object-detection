#!/bin/bash

##env vars
target_folder='/data/emanuele/prova/test_scripts'
ck_repo_folder='/home/emanuele/cck'
######model list

model=('lowproposal,rcnn,resnet50' 'lowproposal,rcnn,resnet101' 'lowproposal,nas,rcnn' 'inception,lowproposal,rcnn,resnetv2' 'fpn,ssd' 'ssd-mobilenet,quantized' 'ssd-mobilenet,mlperf,non-quantized' 'ssd,resnet50' 'ssd,inceptionv2' 'ssdlite' 'rcnn,inceptionv2' 'yolo')
model_tags=('lowproposal-rcnn-resnet50' 'lowproposal-rcnn-resnet101' 'lowproposal-nas-rcnn' 'inception-lowproposal-rcnn-resnetv2' 'fpn-ssd' 'ssd-mobilenet-quantized' 'ssd-mlperf-mobilenet-non-quantized' 'ssd-resnet50' 'ssd-inceptionv2' 'ssdlite' 'rcnn-inceptionv2' 'yolo')

##all models there but the rcnn nas non lowproposal, cause it takes too much to evaluate
#model=('rcnn,nas,non-lowproposal' )
#model_tags=('rcnn-nas-non-lowproposal' )


####### accuracy: test only one vm (cuda, basic) with 5k, all models, different image sizes. 
# hypothesis is that accuracy is not changing across libraries. has to be verified. especially for tf.

batch_size=1
batch_count=5
vm='object-detection-tf-py.tensorrt.ubuntu-18.04'
vm_tag='tf-src-cuda'
mod_len=${#model[@]}
#
#non batched


##### normal run, now i only need the yolo
for j in $(seq 1 $mod_len); do
	is_custom=0
	if [ "${model[$j-1]}"  = "yolo" ]; then
		is_custom=1
	fi
		docker run --runtime=nvidia --env-file  $ck_repo_folder/ck-object-detection/docker/object-detection-tf-py.tensorrt.ubuntu-18.04/env.list --user=$(id -u):1500 -v $target_folder:/home/dvdt/CK_REPOS/local/experiment --rm ctuning/${vm} "ck benchmark program:object-detection-tf-py --dep_add_tags.weights=${model[$j-1]} --repetitions=1 --env.CK_CUSTOM_MODEL=${is_custom} --env.CK_METRIC_TYPE=COCO --env.CK_ENABLE_BATCH=0 --env.CK_BATCH_SIZE=${batch_size} --env.CK_BATCH_COUNT=${batch_count} --env.CK_TF_GPU_MEMORY_PERCENT=80 --record --record_repo=local --record_uoa=mlperf-object-detection-${model_tags[$j-1]}-tf-py-accuracy-${vm_tag}-no-batch --tags=${vm_tag},${model_tags[$j-1]},no-resize"
done

#batched
	for j in $(seq 1 $mod_len); do
		is_custom=0
		if [ "${model[$j-1]}"  = "yolo" ]; then
			is_custom=1
		fi
		docker run --runtime=nvidia --env-file  $ck_repo_folder/ck-object-detection/docker/object-detection-tf-py.tensorrt.ubuntu-18.04/env.list --user=$(id -u):1500 -v $target_folder:/home/dvdt/CK_REPOS/local/experiment --rm ctuning/${vm} "ck benchmark program:object-detection-tf-py --dep_add_tags.weights=${model[$j-1]} --repetitions=1 --env.CK_CUSTOM_MODEL=${is_custom} --env.CK_BATCH_SIZE=${batch_size} --env.CK_BATCH_COUNT=${batch_count} --env.CK_TF_GPU_MEMORY_PERCENT=80 --env.CK_METRIC_TYPE=COCO --env.CK_ENABLE_BATCH=1 --record --record_repo=local --record_uoa=mlperf-object-detection-${model_tags[$j-1]}-tf-py-accuracy-${vm_tag}-model-width-height --tags=${vm_tag},${model_tags[$j-1]},model-resize"
	done


