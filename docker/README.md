# Object Detection - Docker images

1. [List of supported images](#supported)
2. [Installation](#installation)
    - [Setup NVIDIA Docker](#setup)
    - [Download](#image_download) and/or [Build](#image_build) images
3. [Usage](#usage)
    - [Run once](#run)
        - [Models](#models)
        - [Flags](#flags)
    - [Benchmark](#benchmark)
    - [Explore](#explore)

**NB:** You may need to run commands below with `sudo`, unless you
[manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

<a name="supported"></a>
# Supported images

The following table lists supported Docker images.

| Image name (`<image_name>`) | Image description | Docker Hub link |
|-|-|-|
|`object-detection-tf-py.tf-prebuilt.ubuntu-18.04`| TensorFlow prebuilt for the CPU (installed via pip) | [CPU prebuilt](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-prebuilt.ubuntu-18.04) |
|`object-detection-tf-py.tf-src.ubuntu-18.04`     | TensorFlow built from sources for the CPU           | [CPU from sources](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-src.ubuntu-18.04)  |
|`object-detection-tf-py.tensorrt.ubuntu-18.04`   | TensorFlow built from sources for the GPU, with TensorRT support enabled | [CUDA+TensorRT from sources](https://hub.docker.com/r/ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04) |

The CPU images are based on the [Ubuntu 18.04 image](https://hub.docker.com/_/ubuntu) from Docker Hub,
while the GPU image is based on the [TensorRT 19.08 image](https://docs.nvidia.com/deeplearning/sdk/tensorrt-container-release-notes/rel_19-08.html) from NVIDIA
(which is also based on Ubuntu 18.04).

All the images include TensorFlow 1.14.0, about a dozen of [object detection models](#models) and the [COCO 2017 dataset](http://cocodataset.org).

<a name="installation"></a>
# Installation

<a name="setup"></a>
## System setup

As our GPU image is based on [nvidia-docker](https://github.com/NVIDIA/nvidia-docker), please follow instructions there to set up your system.

<a name="image_download"></a>
## Download images from Docker Hub

To download an image from Docker Hub, run:
```
$ docker pull ctuning/<image_name>
```
where `<image_name>` is the image name from the [table above](#supported).

**NB:** As the prebuilt TensorFlow variant does not support AVX2 instructions, we advise to use the TensorFlow variant built from sources on compatible hardware.
In fact, as the latter was built on an [HP Z640 workstation](http://h20195.www2.hp.com/v2/default.aspx?cc=ie&lc=en&oid=7528701)
with an [Intel(R) Xeon(R) CPU E5-2650 v3](https://ark.intel.com/products/81705/Intel-Xeon-Processor-E5-2650-v3-25M-Cache-2_30-GHz) (launched in Q3'14), we advise
to rebuild the image on your system.

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
$ docker build --no-cache -f Dockerfile -t ctuning/<image_name> .
```

<a name="usage"></a>
# Usage

<a name="run"></a>
## Run inference once

Once you have downloaded or built an image, you can run inference e.g. as follows:
```bash
$ docker run --rm ctuning/object-detection-tf-py.tf-prebuilt.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --env.CK_BATCH_COUNT=50 \
    "
```
Here, we run inference on 50 images on the CPU using the quantized SSD-MobileNet model.

To perform inference on the GPU, add the `--runtime=nvidia` flag:

```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --env.CK_BATCH_COUNT=50 \
        --env.CK_ENABLE_TENSORRT=1 \
        --env.CK_TENSORRT_DYNAMIC=1 \
    "
```
Here, we additionally request to use TensorRT in the [dynamic mode](https://docs.nvidia.com/deeplearning/frameworks/tf-trt-user-guide/index.html#static-dynamic-mode).

We describe all supported [models](#models) and [flags](#flags) below.

<a name="models"></a>
### Models

Our [TensorFlow-Python application](https://github.com/ctuning/ck-tensorflow/blob/master/program/object-detection-tf-py/README.md) supports the following TensorFlow models trained on the COCO 2017 dataset. With the exception of a [TensorFlow reimplementation of YOLO v3](https://github.com/YunYang1994/tensorflow-yolov3), all the models come from the [TensorFlow Object Detection model zoo](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md).
Note that we report the accuracy reference (mAP in %) on the COCO 2017 validation dataset (5,000 images).

| Model | Unique CK Tags (`<tags>`) | Is Custom? | mAP in % |
| --- | --- | --- | --- |
| [faster\_rcnn\_resnet50\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)  | `rcnn,lowproposal,resnet50`  | 0 | 24.241037 |
| [faster\_rcnn\_resnet101\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | `rcnn,lowproposal,resnet101` | 0 | 32.594327 |
| [faster\_rcnn\_nas\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)       | `rcnn,lowproposal,nas`       | 0 | 44.340195 |
| [faster\_rcnn\_inception\_resnet\_v2\_atrous\_lowproposals\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | `rcnn,lowproposal,inception,resnetv2` | 0 | 36.520117 |
| [faster\_rcnn\_inception\_v2\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)           | `rcnn,inceptionv2`           | 0 | 28.309626 |
| [ssd\_mobilenet\_v1\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)            | `ssd-mobilenet,non-quantized,mlperf` | 0 | 23.111170 |
| [ssd\_mobilenet\_v1\_quantized\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md) | `ssd-mobilenet,quantized`            | 0 | 23.591693 |
| [ssd\_mobilenet\_v1\_fpn\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)       | `ssd,fpn`                            | 0 | 35.353170 |
| [ssd\_resnet\_50\_fpn\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)          | `ssd,resnet50`                       | 0 | 38.341120 |
| [ssd\_inception\_v2\_coco ](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)           | `ssd,inceptionv2`                    | 0 | 27.765988 |
| [ssdlite\_mobilenet\_v2\_coco](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md)        | `ssdlite`                            | 0 | 24.281540 |
| [yolo\_v3\_coco](https://github.com/YunYang1994/tensorflow-yolov3)                                                                             | `yolo`                               | 1 | 28.532508 |

Each model can be selected by adding the `--dep_add_tags.weights=<tags>` flag when running a customized command for the container.
For example, to run inference on the quantized SSD-MobileNet model, add `--dep_add_tags.weights=ssd-mobilenet,quantized`; to run inference on the YOLO model, add `--dep_add_tags.weights=yolo`; and so on.

<a name="flags"></a>
### Flags

| Env Flag                    | Possible Values  | Default Value | Description |
|-|-|-|-|
| `--env.CK_CUSTOM_MODEL`     | 0,1              | 0 | Specifies if the model comes from the TensorFlow zoo or from another source. (Models from other sources have to implement their own preprocess, postprocess and get tensor functions, as explained in the [application documentation](https://github.com/ctuning/ck-tensorflow/blob/master/program/object-detection-tf-py/README.md) (to be updated).) |
| `--env.CK_ENABLE_BATCH`     | 0,1              | 0 | Specifies if batching should be enabled (must be used for `--env.CK_BATCH_SIZE` to take effect). |
| `--env.CK_BATCH_SIZE`       | positive integer | 1 | Specifies the number of images to process in a single batch (must be used with `--env.CK_ENABLE_BATCH=1`). |
| `--env.CK_BATCH_COUNT`      | positive integer | 1 | Specifies the number of batches to be processed. |
| `--env.CK_ENABLE_TENSORRT`  | 0,1              | 0 | Enables the TensorRT backend (only to be used on the TensorRT image). |
| `--env.CK_TENSORRT_DYNAMIC` | 0,1              | 0 | Enables the [TensorRT dynamic mode](https://docs.nvidia.com/deeplearning/frameworks/tf-trt-user-guide/index.html#static-dynamic-mode). |
| `--env.CK_ENV_IMAGE_WIDTH`, `--env.CK_ENV_IMAGE_HEIGHT` | positive integer | Model-specific (set by CK) | These parameters can be used to resize at runtime the input images to a different size than the default for the model. This usually decreases the accuracy. |


<a name="benchmark"></a>
## Benchmark models individually

When you run inference using `ck run`, the result gets printed but not saved.

You can use `ck benchmark` to save the result on the host machine e.g. as follows:

```bash
$ docker run --runtime=nvidia \
    --env-file `ck find docker:object-detection-tf-py.tensorrt.ubuntu-18.04`/env.list \
    --user=$(id -u):1500 \
    -v$PATH_TO_TARGET_FOLDER:/home/dvdt/CK_REPOS/local/experiment \
    --rm ctuning/object-detection-tf-py.tensorrt.ubuntu-18.04 \
        "ck benchmark program:object-detection-tf-py \
        --env.CK_BATCH_COUNT=50 \
        --repetitions=1 \
        --record \
        --record_repo=local \
        --record_uoa=object-detection-tf-py-ssd-mobilenet-quantized-accuracy \
        --tags=object-detection,tf-py,ssd-mobilenet,quantized,accuracy \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        "
```

<a name="parameters_docker"></a>
### Docker parameters

- `--env-file`: the path to the `env.list` file, which is usually located in the same folder as the Dockerfile. (Currently, the `env.list` files are identical for all the images.)
- `--user`: your user id on your local machine and a fixed group id (1500) needed to access files in the container.
- `-v`: a folder with read/write permissions for the user that serves as shared space ("volume") between the host and the container.

<a name="parameters_ck"></a>
### CK parameters

- `--env.CK_BATCH_COUNT`: the number of batches to be processed; assuming `--env.CK_BATCH_SIZE=1`, we typically use `--env.CK_BATCH_COUNT=5000` for experiments that measure accuracy over the COCO 2017 validation set and e.g. `--env.CK_BATCH_COUNT=2` for experiments that measure performance. (Since the first batch is usually slower than all subsequent batches, its execution time has to be discarded. The execution times of subsequent batches will be averaged.)
- `--repetitions`: the number of times to run an experiment; we typically use `--repetitions=1` for experiments that measure accuracy and e.g. `--repetitions=10` for experiments that measure performance.
- `--record`, `--record_repo=local`: must be present to have the results saved in the mounted volume.
- `--record_uoa`: a unique name for each CK experiment entry; here, `object-detection-tf-py` (the name of the program) is the same for all experiments, `ssd-mobilenet-quantized` is unique for each model, `accuracy` indicates the accuracy mode.
- `--tags`: specify the tags for each CK experiment entry; we typically make them similar to the experiment name.


<a name="explore"></a>
## Explore design space

**TODO**
