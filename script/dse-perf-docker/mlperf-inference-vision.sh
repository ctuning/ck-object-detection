#!/bin/bash

###############################################################################
# 0. Configure Docker image (build if necessary).
###############################################################################
IMAGE='mlperf-inference-vision-with-ck.tensorrt.ubuntu-18.04'
ck build docker:${IMAGE}


###############################################################################
# 1. Configure paths.
###############################################################################
# TODO: Assume $CK_REPOS is already defined and warn if not.
CK_REPOS=$HOME/CK_REPOS

# TODO: Create if if does not exist.
EXPERIMENTS_DIR=/data/$USER/mlperf-inference-vision-experiments


###############################################################################
# 2. Configure batch options.
###############################################################################
# NB: batch_sizes (#samples/query) must be 1 for SingleStream.
# NB: batch_count (#queries) must be at least 1024 for SingleStream.
# batch_sizes=( 1 2 4 8 16 32 )
batch_sizes=( 1 )
batch_count=2


###############################################################################
# 3. Configure models.
# NB: Somewhat counterintuitively, 'models' are actually tags for selecting
# models, while 'models_tags' are tags for recording experimental results.
###############################################################################
models=( 'rcnn,nas,lowproposals,vcoco' 'rcnn,resnet50,lowproposals' 'rcnn,resnet101,lowproposals' 'rcnn,inception-resnet-v2,lowproposals' 'rcnn,inception-v2' 'ssd,inception-v2' 'ssd,mobilenet-v1,quantized,mlperf,tf' 'ssd,mobilenet-v1,mlperf,non-quantized,tf' 'ssd,mobilenet-v1,fpn' 'ssd,resnet50,fpn' 'ssdlite,mobilenet-v2,vcoco' 'yolo-v3' )
models_tags=( 'rcnn-nas-lowproposals'  'rcnn-resnet50-lowproposals' 'rcnn-resnet101-lowproposals' 'rcnn-inception-resnet-v2-lowproposals' 'rcnn-inception-v2' 'ssd-inception-v2' 'ssd-mobilenet-v1-quantized-mlperf'    'ssd-mobilenet-v1-non-quantized-mlperf'    'ssd-mobilenet-v1-fpn' 'ssd-resnet50-fpn' 'ssdlite-mobilenet-v2'       'yolo-v3' )
# Uncomment for debugging.
#models=( 'ssd,mobilenet-v1,quantized,mlperf,tf' )
#models_tags=( 'ssd-mobilenet-v1-quantized-mlperf' )

models_selection=()
for model in "${models[@]}"; do
  if [ ${model} = "yolo-v3" ]
  then
    is_custom_model=1
  else
    is_custom_model=0
  fi
  models_selection+=( "--dep_add_tags.weights=${model} --env.CK_CUSTOM_MODEL=${is_custom_model}" )
done


###############################################################################
# 4. Configure TensorFlow backends.
###############################################################################
backends_selection=( '--dep_add_tags.lib-tensorflow=vcpu' '--dep_add_tags.lib-tensorflow=vcuda --env.CUDA_VISIBLE_DEVICES=-1' '--dep_add_tags.lib-tensorflow=vcuda --env.CK_TF_GPU_MEMORY_PERCENT=99' '--dep_add_tags.lib-tensorflow=vcuda --env.CK_TF_GPU_MEMORY_PERCENT=99 --env.CK_ENABLE_TENSORRT=1' '--dep_add_tags.lib-tensorflow=vcuda --env.CK_TF_GPU_MEMORY_PERCENT=99 --env.CK_ENABLE_TENSORRT=1 --env.CK_TENSORRT_DYNAMIC=1' )
backends_tags=( 'cpu-prebuilt' 'cpu' 'cuda' 'tensorrt' 'tensorrt-dynamic' )
# Uncomment for debugging.
#backends_selection=( '--dep_add_tags.lib-tensorflow=vcuda --env.CK_TF_GPU_MEMORY_PERCENT=99 --env.CK_ENABLE_TENSORRT=1 --env.CK_TENSORRT_DYNAMIC=1' )
#backends_tags=( 'tensorrt-dynamic' )


###############################################################################
# 5. Full design space exploration.
###############################################################################
# TODO: Add scenario info.
batch_sizes_len=${#batch_sizes[@]}
backends_len=${#backends_selection[@]}
models_len=${#models[@]}

echo "====================="
echo "Starting full DSE ..."
echo "====================="
experiment_idx=1
for i in $(seq 1 ${batch_sizes_len}); do
  batch_size=${batch_sizes[$i-1]}
  if [ ${batch_size} = 1 ]
  then
    enable_batch=0
  else
    enable_batch=1
  fi
  batch_selection="--env.CK_ENABLE_BATCH=${enable_batch} --env.CK_BATCH_SIZE=${batch_size} --env.CK_BATCH_COUNT=${batch_count}"
  for j in $(seq 1 ${backends_len}); do
    backend_selection=${backends_selection[$j-1]}
    backend_tags=${backends_tags[$j-1]}
    for k in $(seq 1 ${models_len}); do
      model=${models[$k-1]}
      model_selection=${models_selection[$k-1]}
      model_tags=${models_tags[$k-1]}
      record_uoa="mlperf.object-detection.${backend_tags}.${model_tags}"
      record_tags="mlperf,object-detection,${backend_tags},${model_tags}"
      if [ ${enable_batch} = 1 ]; then
        record_uoa+=".batch-size${batch_size}"
        record_tags+=",batch-size${batch_size}"
      fi
      echo "experiment_idx: ${experiment_idx}"
      echo "  batch_size: ${batch_size}"
      echo "  batch_selection: ${batch_selection}"
      echo "  backend_tags: ${backend_tags}"
      echo "  backend_selection: ${backend_selection}"
      echo "  model_tags: ${model_tags}"
      echo "  model: ${model}"
      echo "  model_selection: ${model_selection}"
      echo "  record_uoa=${record_uoa}"
      echo "  record_tags=${record_tags}"
#      docker run --runtime=nvidia \
#      --env-file ${CK_REPOS}/ck-object-detection/docker/${IMAGE}/env.list \
#      --user=$(id -u):1500 -v ${EXPERIMENTS_DIR}:/home/dvdt/CK_REPOS/local/experiment \
#      --rm ctuning/${IMAGE} \
#      "ck benchmark program:mlperf-inference-vision --repetitions=1 --env.CK_METRIC_TYPE=COCO \
#      ${batch_selection} \
#      ${model_selection} \
#      ${backend_selection} \
#      --record --record_repo=local --record_uoa=${record_uoa} --tags=${record_tags}"
       echo "------------------"
       ((experiment_idx++))
    done # for each backend
  done # for each model
done # for each batch size
