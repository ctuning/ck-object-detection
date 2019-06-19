# [Object Detection - SSD-ResNet50 - TF-Python (Debian 9)](https://hub.docker.com/r/ctuning/object-detection-tf-py.ssd-resnet50.debian-9)

1. [Default image](#image_default) (based on [Debian](https://hub.docker.com/_/debian/) 9 latest)
    - [Download](#image_default_download) or [Build](#image_default_build)
    - [Run](#image_default_run)
        - [Object Detection (default command)](#image_default_run_default)
        - [Object Detection (custom command)](#image_default_run_custom)
        - [Bash](#image_default_run_bash)

**NB:** You may need to run commands below with `sudo`, unless you
[manage Docker as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).

<a name="image_default"></a>
## Default image

<a name="image_default_download"></a>
### Download
```
$ docker pull ctuning/object-detection-tf-py.ssd-resnet50.debian-9
```

<a name="image_default_build"></a>
### Build
```bash
$ ck build docker:object-detection-tf-py.ssd-resnet50.debian-9
```
**NB:** Equivalent to:
```bash
$ cd `ck find docker:object-detection-tf-py.ssd-resnet50.debian-9`
$ docker build -f Dockerfile -t ctuning/object-detection-tf-py.ssd-resnet50.debian-9 .
```

<a name="image_default_run"></a>
### Run

<a name="image_default_run_default"></a>
#### Object Detection (default command)

##### 50 images
```bash
$ ck run docker:object-detection-tf-py.ssd-resnet50.debian-9
```
**NB:** Equivalent to:
```bash
$ docker run --rm ctuning/object-detection-tf-py.ssd-resnet50.debian-9 \
    "ck run program:object-detection-tf-py \
        --env.CK_BATCH_COUNT=50 \
    "
...
Summary:
-------------------------------
Graph loaded in 1.345360s
All images loaded in 12.639891s
All images detected in 32.416452s
Average detection time: 0.661560s
mAP: 0.414449934563344
Recall: 0.46153925387789685
--------------------------------
```

<a name="image_default_run_custom"></a>
#### Object Detection (custom command)

##### 5000 images
```bash
$ docker run --rm ctuning/object-detection-tf-py.ssd-resnet50.debian-9 \
    "ck run program:object-detection-tf-py \
        --env.CK_BATCH_COUNT=5000 \
    "
...
Summary:
-------------------------------
Graph loaded in 1.270971s
All images loaded in 1249.606287s
All images detected in 4065.931880s
Average detection time: 0.813349s
mAP: 0.3834113724148717
Recall: 0.45780387187265914
--------------------------------
```

<a name="image_default_run_bash"></a>
#### Bash
```bash
$ docker run -it --rm ctuning/object-detection-tf-py.ssd-resnet50.debian-9 bash
```
