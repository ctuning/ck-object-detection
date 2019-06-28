# [Object Detection - TF-Python with CUDA support (NVIDIA Ubuntu 16.04, CUDA 9.0, cuDNN 7.0)](https://hub.docker.com/r/ctuning/object-detection-tf-py.cuda-9.ubuntu-16.04)

1. [Prerequisites](#setup)
    - [NVIDIA Docker and libraries](#nvidia)

1. [Default image](#image_default) (based on [NVIDIA Ubuntu](https://hub.docker.com/r/nvidia/cuda/) 16.04)
    - [Download](#image_default_download) or [Build](#image_default_build)
    - [Run](#image_default_run)
        - [Object Detection (default command)](#image_default_run_default)
        - [Object Detection (custom command)](#image_default_run_custom)
        - [Bash](#image_default_run_bash)

**NB:** You may need to run commands below with `sudo`, unless you
[manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

<a name="nvidia"></a>
## System setup

<a name="nvidia"></a>
## NVIDIA Docker and libraries
As this container is based on an NVIDIA container, and it requires `nvidia-docker` installed to work.
Please follow [NVIDIA's instructions](https://github.com/NVIDIA/nvidia-docker) to prepare your system to run this container.


<a name="image_default"></a>
## Default image

<a name="image_default_download"></a>
### Download
```
$ docker pull ctuning/object-detection-tf-py.cuda-9.ubuntu-16.04
```

<a name="image_default_build"></a>
### Build
```bash
$ ck build docker:object-detection-tf-py.cuda-9.ubuntu-16.04
```
**NB:** Equivalent to:
```bash
$ cd `ck find docker:object-detection-tf-py.cuda-9.ubuntu-16.04`
$ docker build -f Dockerfile -t ctuning/object-detection-tf-py.cuda-9.ubuntu-16.04 .
```

<a name="image_default_run"></a>
### Run

<a name="image_default_run_default"></a>
#### Object Detection (default command)

##### 50 images
```bash
$ ck run docker:object-detection-tf-py.cuda-9.ubuntu-16.04
```
**NB:** Equivalent to:
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.cuda-9.ubuntu-16.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,non-quantized \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=50 \
        --env.CK_TF_GPU_MEMORY_PERCENT=75 \
    "
...
Summary
-------------------------------
Graph loaded in 0.762601s
All images loaded in 14.427785s
All images detected in 1.990864s
Average detection time: 0.040630s
mAP: 0.3148934914889957
Recall: 0.3225293342489256
--------------------------------
```


<a name="image_default_run_custom"></a>
#### Object Detection (custom command)

##### 5000 images
```bash
$ docker run --runtime=nvidia --rm ctuning/object-detection-tf-py.cuda-9.ubuntu-16.04 \
    "ck run program:object-detection-tf-py \
        --dep_add_tags.weights=ssd-mobilenet,non-quantized \
        --dep_add_tags.dataset=coco.2017,full --env.CK_BATCH_COUNT=5000 \
    "
...
Summary:
-------------------------------
Graph loaded in 0.827014s
All images loaded in 1452.299614s
All images detected in 205.746414s
Average detection time: 0.041158s
mAP: 0.23111170526465216
Recall: 0.26304841188725403
--------------------------------
```

<a name="image_default_run_bash"></a>
#### Bash
```bash
$ docker run --runtime=nvidia -it --rm ctuning/object-detection-tf-py.cuda-9.ubuntu-16.04 bash
```
