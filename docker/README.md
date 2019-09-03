# Object Detection - Docker images

1. [List of supported images](#supported)

2. [Prerequisites](#prereq)
    - [Setup NVIDIA Docker](#setup)
    - [Download](#image_download) or [Build](#image_build) images

3. [Usage](#usage)
    - [Models](#models)
    - [Flags](#flags)
    - [Run](#run)
    - [Benchmark](#benchmark)

**NB:** You may need to run commands below with `sudo`, unless you
[manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

<a name="supported"></a>
# Supported images

The following table lists supported Docker images based on Ubuntu 18.04 with TensorFlow 1.14.0.

| Image name | Image description | Docker Hub link |
|-|-|-|
|`object-detection-tf-py.tf-prebuilt.ubuntu-18.04`| TensorFlow prebuilt for the CPU (installed via pip) | [CPU prebuilt](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-prebuilt.ubuntu-18.04) |
|`object-detection-tf-py.tf-src.ubuntu-18.04`     | TensorFlow built from sources for the CPU        | [CPU from sources](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-src.ubuntu-18.04) |
|`object-detection-tf-py.tensorrt.ubuntu-18.04`   | TensorFlow built from sources for the GPU, with TensorRT support enabled | [CUDA+TensorRT](https://hub.docker.com/r/ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04) |

**NB:** As the prebuilt TensorFlow variant does not support AVX2 instructions, it is advisable to use the TensorFlow variant built from sources on compatible hardware.

<a name="prereq"></a>
# Prerequisites

<a name="setup"></a>
## System setup

As our images are based on [nvidia-docker](https://github.com/NVIDIA/nvidia-docker), please follow instructions there to set up your system.

<a name="image_download"></a>
## Download images from Docker Hub

To download an image from Docker Hub, run:
```
$ docker pull ctuning/<image_name>
```
where `<image_name>` is the image name from the [table above](#supported).
    

<a name="image_build"></a>
## Build images

To build an image on your system, run:
```bash
$ ck build docker:<image_name>
```
where `<image_name>` is the image name from the [table above](#supported).

**NB:** This CK command is equivalent to:
```bash
$ cd `ck find docker:<image_name>`
$ docker build -f Dockerfile -t ctuning/<image_name> .
```

<a name="usage"></a>
# Usage

<a name="models"></a>
## Models

Our [TensorFlow-Python application](https://github.com/ctuning/ck-tensorflow/blob/master/program/object-detection-tf-py/README.md) supports the following TensorFlow models trained on the COCO 2017 dataset. With the exception of a [TensorFlow reimplementation of YOLO v3](https://github.com/YunYang1994/tensorflow-yolov3), all the models come from the [TensorFlow Object Detection model zoo](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md). 
Note that we report the accuracy reference (mAP in %) on the COCO 2017 dataset (5,000 images).

| Model | Unique CK Tags | Is Custom? | mAP in % |
| --- | --- | --- | --- |
| [faster\_rcnn\_resnet50\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | lowproposal,rcnn,resnet50|  0 |  24.241037|
| [faster\_rcnn\_resnet101\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) |lowproposal,rcnn,resnet101|  0 | 32.594327|
| [faster\_rcnn\_nas\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| lowproposal,nas,rcnn|       0 |     44.340195|
| [faster\_rcnn\_inception\_resnet\_v2\_atrous\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | inception,lowproposal,rcnn,resnetv2|    0|  36.520117|     
| [faster\_rcnn\_inception\_v2\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| rcnn,inceptionv2 |               0 |    28.309626|
| [ssd\_mobilenet\_v1\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssd-mobilenet,non-quantized,mlperf |      0 |    23.111170|
| [ssd\_mobilenet\_v1\_quantized\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | ssd-mobilenet,quantized |     0 |    23.591693|
| [ssd\_mobilenet\_v1\_fpn\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssd,fpn |                            0 |    35.353170|
| [ssd\_resnet\_50\_fpn\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)|ssd,resnet50 |                           0 |    38.341120|
| [ssd\_inception\_v2\_coco ](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssd,inceptionv2 |                        0 |    27.765988|
| [ssdlite\_mobilenet\_v2\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)| ssdlite |                             0 |    24.281540|
| [yolo\_v3\_coco](https://github.com/YunYang1994/tensorflow-yolov3) | yolo | 1|   28.532508|

Every model can be selected by adding the `--dep_add_tags.weights=<tags>` flag when running the customized command for the container.
For example, to run inference on the quantized SSD-MobileNet model, add `--dep_add_tags.weights=ssd-mobilenet,quantized`. To run inference on the YOLO model, add `--dep_add_tags.weights=yolo`, and so on.

<a name="flags"></a>
## Other flags

| Env Flag name | Possible Values | Default Value | Description|
| --- | --- | --- | --- |
| `--env.CK_CUSTOM_MODEL` | 0,1 | 0 | Specifies if the model comes from the TensorFlow zoo or from another source. (Models from other sources have to implement their own preprocess, postprocess and get tensor functions, as explained in the [application documentation](https://github.com/ctuning/ck-tensorflow/blob/master/program/object-detection-tf-py/README.md) (to be updated).) |
| `--env.CK_ENABLE_BATCH` | 0,1 | 0 | Specifies if batching should be enabled (must be used for `--env.CK_BATCH_SIZE` to take effect). |
| `--env.CK_BATCH_SIZE` | positive integer | 1 | Specifies the number of images to process in a single batch (must be used with `--env.CK_ENABLE_BATCH=1`). |
| `--env.CK_BATCH_COUNT` | positive integer | 1 | Specifies the number of batches to be processed. |
| `--env.CK_ENABLE_TENSORRT` | 0,1 | 0 | Enables the TensorRT backend (only to be used on the TensorRT image). |
| `--env.CK_TENSORRT_DYNAMIC` | 0,1 | 0 | Enables the [TensorRT dynamic mode](https://docs.nvidia.com/deeplearning/frameworks/tf-trt-user-guide/index.html#static-dynamic-mode). |
| `--env.CK_ENV_IMAGE_WIDTH`, `--env.CK_ENV_IMAGE_HEIGHT` | positive integer | Model-specific (set by CK) | These parameters can be used to resize at runtime the input images to a different size than the default for the model. This usually decreases the accuracy. |


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

