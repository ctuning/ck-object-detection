# Object Detection - Docker containers
1. [List of supported images](#supported)

2. [Prereq](#prereq)
    - [CUDA Drivers & Nvidia Docker](#cuda_drivers&docker)

3. [Usage](#image_default) 
    - [Download](#image_default_download) or [Build](#image_default_build)
    - [Models](#models)
    - [Configuration Flags](#flags)
    - [Run](#image_default_run)
    - [Benchmark](#image_benchmark)

**NB:** You may need to run commands below with `sudo`, unless you
[manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

<a name="supported"></a>
# Available Containers
- [Ubuntu 18.04, with Tensorflow prebuilt version (installed via pip)](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-prebuilt.ubuntu-18.04)
- [Ubuntu 18.04, with Tensorflow compiled from sources for the CPU](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-src.ubuntu-18.04)
- [Ubuntu 18.04, with Tensorflow compiled from sources for the GPU, with the TensorRT support enabled](https://hub.docker.com/r/ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04)
    


<a name="prereq"></a>
# Prerequisites
<a name="cuda_drivers&docker"></a>
## System Setup

Follow the instruction in https://github.com/NVIDIA/nvidia-docker to prepare the system to run this container.
This container is based on an nvidia container, and it requires to have the nvidia-docker environment installed to work.




<a name="image_default"></a>
# Usage

<a name="image_default_download"></a>
## Download
to download from docker use the following command
```
$ docker pull ctuning/<image_name>
```
where image\_name is the name of the container to download, to select between:
    
- object-detection-tf-py.tf-prebuilt.ubuntu-18.04
- object-detection-tf-py.tf-src.ubuntu-18.04
- object-detection-tf-py.tensorrt.ubuntu-18.04

<a name="image_default_build"></a>
## Build
```bash
$ ck build docker:<image_name>
```
**NB:** Equivalent to:
```bash
$ cd `ck find docker:<image_name>
$ docker build -f Dockerfile -t ctuning/<image_name> .
```

<a name="models"></a>
## Models
Table with the models supported by the application, with the provenience URL, and the associated tags.

| Model | Tags | Custom Model |COCO 2017 mAP |
| --- | --- | --- | --- |
| [faster\_rcnn\_resnet50\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | lowproposal,rcnn,resnet50|  0 |  24.241037|
| [faster\_rcnn\_resnet101\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) |lowproposal,rcnn,resnet101|  0 | 32.594327|
| [faster\_rcnn\_nas\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| lowproposal,nas,rcnn|       0|     44.340195|
| [faster\_rcnn\_inception\_resnet\_v2\_atrous\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | inception,lowproposal,rcnn,resnetv2|    0|  36.520117|     
| [faster\_rcnn\_inception\_v2\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| rcnn,inceptionv2|               0|         28.309626|
| [ssd\_mobilenet\_v1\_quantized\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | ssd-mobilenet,quantized |     0 |     23.591693|
| [ssd\_mobilenet\_v1\_fpn\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| fpn,ssd|                             0|    35.353170|
| [ssd\_mobilenet\_v1\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssd-mobilenet,non-quantized,mlperf|        0|        23.111170|
| [ssd\_resnet\_50\_fpn\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)|ssd,resnet50|                            0|       38.341120 	|
| [ssd\_inception\_v2\_coco ](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssd,inceptionv2|                        0|    27.765988|
| [ssdlite\_mobilenet\_v2\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssdlite|                             0|      24.281540|
| [yolo\_v3\_coco](https://github.com/YunYang1994/tensorflow-yolov3) |yolo| 1|   28.532508|

Every model can be called by adding the `--dep\_add\_tags.weights=<tags list>` flag when running the customized command for the container.
tags list is the comma separated list reported in all the model after the website of provenience.
For example, to run inference on the ssd-mobilenet quantized, you will need to add `--dep\_add\_tags.weights=ssd-mobilenet,quantized`. To run inference on yolo, you need to specify `--dep\_add\_tags.weights=yolo` and so on.

We report also the accuracy reference, on 5000 images, on the COCO 2017 dataset, for all the supported models.

<a name="flags"></a>
## Other available flags
| Env Flag name | Possible Values | Default Value | Description|
| --- | --- | --- | --- |
| --env.CK\_CUSTOM\_MODEL | 1/0 | 0 | this flag specifies if the model comes from the tensorflow zoo or comes from other source. Model coming from other sources have to implement their own preprocess,postprocess and get tensor functions, as explained in the original application.|
| --env.CK\_BATCH\_SIZE| integer | 1 | number of images to process in a single batch|
| --env.CK\_BATCH\_COUNT | integer |1| number of batches to be processed|
| --env.CK\_METRIC\_TYPE|COCO| COCO | this variable has to be used, with the models present in the container, to tell the application that we will be working with models trained for the coco dataset|
| --env.CK\_ENABLE\_BATCH|1/0| 0 | this flag is used to specify if we want to enable the batch feature or not and process all the images singularly.|
| --env.CK\_ENABLE\_TENSORRT| 1/0| 0 | this flag enables the tensorRT backend|
| --env.CK\_TENSORRT\_DYNAMIC|1/0 | 0 | this flag enables the dynamic feature of tensorRT backend|
| --env.CK\_ENV\_IMAGE\_WIDTH and CK\_ENV\_IMAGE\_HEIGHT| integer| Model Dependent | These two parameters can be used to try to resize the images at runtime at a different size than the one suggested for each single model. This usually decrease accuracy.|


<a name="example_run"></a>
## Run

Here we will provid an example of command that can be used to run.
If the image used targets GPU, it is necessary to add the flag --runtime=nvidia when launching the docker command, as follows

```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --env.CK_BATCH_COUNT=50 \
    "
```
In this case, we are launching the command to perform the program object-detection on 50 images using the ssd-mobilenet quantized network to perform inference, on a tensorflow backend running on the GPU.

```bash
$ docker run --rm ctuning/object-detection-tf-py.tf-prebuilt.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --env.CK_BATCH_COUNT=50 \
    "
```

In this case, we are running the same command with a different image, targeting a backend using tensorflow installed with pip.

   
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --env.CK_BATCH_COUNT=50 \
        --env.CK_ENABLE_TENSORRT=1\
        --env.CK_TENSORRT_DYNAMIC=1\
    "
```
In the last example, we want to run exploiting TensorRT backend, and in particular its dynamic features (the network will not setup until the first input is provided, and that input is giving the shape to the network itself.


## Benchmark
<a name="image_benchmark"></a>
This command allows to run the benchmark in the docker container, and save the result on the host machine. 
Benchmark are a particular functionality of the CK framework that allows to run experiments in a controlled environment.

Parameter explanation:
env-file is found in the same folder of the Dockerfile, and can be reached from the path of the main CK\_REPO folder with the path in the commandline.
user is needed to run the docker image as the user you are on your local machine. the group (1500) is a fixed value in the docker container, and you will need it to use read/write the files in the image.
volume (-v) is the shared space between the container and the host. you have to provide a folder where you have rw permission.

```bash
$ docker run \
    --runtime=nvidia \
    --env-file  $PATH_TO_CK_REPO/ck-object-detection/docker/object-detection-tf-py.tensorrt.ubuntu-18.04/env.list \ 
    --user=$(id -u):1500 \
    -v$PATH_TO_TARGET_FOLDER:/home/dvdt/CK_REPOS/local/experiment \
    --rm \
    ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04 \
        "ck benchmark program:object-detection-tf-py \
        --repetitions=1 \
        --env.CK_BATCH_SIZE=1 \
        --env.CK_BATCH_COUNT=50 \ 
        --env.CK_METRIC_TYPE=COCO \
        --record \
        --record_repo=local \
        --record_uoa=mlperf-object-detection-ssd-mobilenet-quantized-tf-py-accuracy \
	--dep_add_tags.weights=ssd-mobilenet,quantized \
        --tags=mlperf,object-detection,ssd-mobilenet,tf-py,accuracy,quantized" 
```

where the number of repetitions can be changed in order to create a statistically valid number of experiments
the record\_uoa is a unique identifier used to build experiments and must not overlap with other benchmarks
the tags can be used to identify the experiment, and to organize experiments
the --record and --record\_repo=local must NOT be changed, since they are part of the setup to have the results saved in the mounted volume.

