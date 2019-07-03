# [Object Detection - TF-Python with CUDA support (Nvidia/Ubuntu16.04, CUDA 9.0, cudnn 7.0)](https://hub.docker.com/r/ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04)

1. [Prereq](#prereq)
    - [CUDA Drivers & Nvidia Docker](#cuda_drivers&docker)

1. [Default image](#image_default) (based on [Nvidia/Ubuntu16.04](https://hub.docker.com/r/nvidia/cuda/) Ubuntu 16.04 )
    - [Download](#image_default_download) or [Build](#image_default_build)
    - [Models](#models)
        -  [ssd mobilenet](#ssd_mobilenet)
            -  [non-quantized](#non-quantized)
            -  [quantized](#quantized)
        -  [ssd-resnet](#ssd-resnet)
    - [Run](#image_default_run)
        - [Object Detection (default command)](#image_default_run_default)
        - [Object Detection (custom command)](#image_default_run_custom)
        - [Bash](#image_default_run_bash)

**NB:** You may need to run commands below with `sudo`, unless you
[manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

<a name="cuda_drivers&docker"></a>
## System Setup

Follow the instruction in https://github.com/NVIDIA/nvidia-docker to prepare the system to run this container.
This container is based on an nvidia container, and it requires to have the nvidia-docker environment installed to work.




<a name="image_default"></a>
## Default image

<a name="image_default_download"></a>
### Download
```
$ docker pull ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04
```

<a name="image_default_build"></a>
### Build
```bash
$ ck build docker:object-detection-tf-py.tf-src-cuda.ubuntu-18.04
```
**NB:** Equivalent to:
```bash
$ cd `ck find docker:object-detection-tf-py.tf-src-cuda.ubuntu-18.04`
$ docker build -f Dockerfile -t ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 .
```

<a name="models"></a>
### Models


<a name="ssd_mobilenet"></a>
#### ssd mobilenet

<a name="non-quantized"></a>
##### non quantized

This model comes from (https://FINDURL) and contains the non quantized version of the ssd-mobilenet network for Object Detection.
It can be used by adding the --dep\_add\_tags.weights=non-quantized flag when running the customized command for the container.

<a name="quantized"></a>
##### quantized

This model comes from (https://FINDURL) and contains the quantized version of the ssd-mobilenet network for Object Detection.
It can be used by adding the --dep\_add\_tags.weights=quantized flag when running the customized command for the container.

<a name="ssd-resnet50"></a>

#### ssd-resnet50
This model comes from (https://FINDURL) and contains the  ssd-resnet50 network for Object Detection.
It can be used by adding the --dep\_add\_tags.weights=resnet50 flag when running the customized command for the container.

<a name="image_default_run"></a>
### Run

<a name="image_default_run_default"></a>
#### Object Detection (default command)
The default command will run the docker container as follows, running the non quantized ssd-mobilenet for 50 images:

##### 50 images
```bash
$ ck run docker:object-detection-tf-py.tf-src-cuda.ubuntu-18.04
```
**NB:** Equivalent to:
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,non-quantized \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=50 \
    "
<a name="image_default_run_custom"></a>
#### Object Detection (custom command)
To test the different models or a different number of images, the docker based command has to be used, to change the parameters given to the ck run.
We will report the expected results for the three different models, on two different images batch sizes.

##### ssd-mobilenet, quantized, 50 images

```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=50 \
    "
...
Summary:
```

##### ssd-resnet50, 50 images

```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=resnet50 \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=50 \
    "

Summary:

```




##### ssd-mobilenet, non-quantized, 5000 images
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,non-quantized \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=5000 \
    "
...
Summary:
```


##### ssd-mobilenet, quantized, 5000 images
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,quantized \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=5000 \
    "
...
Summary:

```




##### ssd-resnet50 5000 images
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=resnet50 \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=5000 \
    "
...
Summary:
```



<a name="image_default_run_bash"></a>
#### Bash
```bash
$ docker run --runtime=nvidia -it --rm ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 bash
```


<a name="image_benchmark"></a>
This command allows to run the benchmark in the docker container, and save the result on the host machine. 
Parameter explanation:
env-file is found in the same folder of the Dockerfile, and can be reached from the path of the main CK\_REPO folder with the path in the commandline.
user is needed to run the docker image as the user you are on your local machine
volume (-v) is the shared space between the container and the host. you have to provide a folder where you have rw permission.

```bash
$ docker run \
    --env-file  $PATH_TO_CK_REPO/ck-object-detection/docker/object-detection-tf-py.tf-src-cuda.ubuntu-18.04/env.list \
    --user=$(id -u):$(id -g) \
    -v$PATH_TO_TARGET_FOLDER:/home/dvdt/CK_REPOS/local/experiment \ 
    --rm \
    ctuning/object-detection-tf-py.tf-src-cuda.ubuntu-18.04 \
         "ck benchmark program:object-detection-tf-py \ 
        --repetitions=1 \ 
        --env.CK_BATCH_SIZE=1 \
        --env.CK_BATCH_COUNT=50 \
        --env.CK_METRIC_TYPE=COCO \
        --record \
        --record_repo=local \
        --record_uoa=mlperf-object-detection-ssd-mobilenet-tf-py-accuracy \
	--dep_add_tags.weights=ssd-mobilenet,non-quantized \
        --tags=mlperf,object-detection,ssd-resnet50,tf-py,accuracy" 
```
