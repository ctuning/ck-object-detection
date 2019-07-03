FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

LABEL maintainer="Anton Lokhmotov <anton@dividiti.com>"

# Use the Bash shell.
SHELL ["/bin/bash", "-c"]

# Allow stepping into the Bash shell interactively.
ENTRYPOINT ["/bin/bash", "-c"]

# Install known system dependencies and immediately clean up to make the image smaller.
# CK needs: git, wget, zip.
# TF needs: curl.
# TensorFlow Object Detection API needs ProtoBuf 3.0 which needs CMake.
RUN apt update -y\
 && apt install -y apt-utils\
 && apt upgrade -y\
 && apt install -y\
 git wget zip libz-dev\
 curl\
 cmake\
 python3 python3-pip\
 vim\
 && apt clean
RUN ln -s /usr/bin/python3 /usr/bin/python 
# Create non-root user.
RUN useradd -u 2000 --create-home --user-group --shell /bin/bash dvdt
USER dvdt:dvdt
WORKDIR /home/dvdt

# Install Collective Knowledge (CK).
ENV CK_ROOT=/home/dvdt/CK \
    CK_REPOS=/home/dvdt/CK_REPOS \
    CK_TOOLS=/home/dvdt/CK_TOOLS \
    PATH=${CK_ROOT}/bin:/home/dvdt/.local/bin:${PATH} \
    CK_PYTHON=python3 \
    CK_CC=gcc \
    GIT_USER="dividiti" \
    GIT_EMAIL="info@dividiti.com" \
    LANG=C.UTF-8
RUN mkdir -p ${CK_ROOT} ${CK_REPOS} ${CK_TOOLS}
RUN git config --global user.name ${GIT_USER} && git config --global user.email ${GIT_EMAIL}
RUN git clone https://github.com/ctuning/ck.git ${CK_ROOT}
RUN cd ${CK_ROOT} \
 && ${CK_PYTHON} setup.py install --user \
 && ${CK_PYTHON} -c "import ck.kernel as ck; print ('Collective Knowledge v%s' % ck.__version__)"


RUN ck pull repo:ck-tensorflow --url=https://github.com/me2x/ck-tensorflow.git
RUN cd $CK_REPOS/ck-tensorflow && git checkout -b tf14_src origin/tf14_src && cd
# Pull CK repositories (including ck-env, ck-autotuning and ck-tensorflow).
RUN ck pull repo:ck-mlperf

# Use generic Linux settings with dummy frequency setting scripts.
RUN ck detect platform.os --platform_init_uoa=generic-linux-dummy

# Detect C/C++ compiler (gcc).
RUN ck detect soft:compiler.gcc --full_path=`which ${CK_CC}`

# Detect Python.
RUN ck detect soft:compiler.python --full_path=`which ${CK_PYTHON}`
# Install the latest Python package installer (pip) and some dependencies.
RUN ${CK_PYTHON} -m pip install --ignore-installed pip setuptools --user

# Install Python dependencies.
RUN ck install package --tags=lib,python-package,numpy
RUN ck install package --tags=lib,python-package,scipy --force_version=1.2.1
RUN ck install package --tags=lib,python-package,pillow
RUN ck install package --tags=lib,python-package,matplotlib
RUN ck install package --tags=lib,python-package,cython
RUN ck show env --tags=python-package

RUN ${CK_PYTHON} -m pip install gast --user
RUN ${CK_PYTHON} -m pip install numpy --user
RUN ${CK_PYTHON} -m pip install protobuf --user
RUN ${CK_PYTHON} -m pip install absl-py --user
RUN ${CK_PYTHON} -m pip install wrapt --user
RUN ${CK_PYTHON} -m pip install astor --user
RUN ${CK_PYTHON} -m pip install termcolor --user
RUN ${CK_PYTHON} -m pip install tensorflow-estimator==1.14.0 --user
RUN ${CK_PYTHON} -m pip install keras_applications==1.0.6 --no-deps --user
RUN ${CK_PYTHON} -m pip install keras_preprocessing==1.0.5 --no-deps --user
# Install Python COCO API.
RUN ck install package --tags=tool,coco,api

#Dataset first 
# Download the COCO 2017 validation dataset (5,000 images) to the default path;
RUN echo | ck install package --tags=object-detection,dataset,coco.2017,val,original,full\
 && ck virtual env --tags=object-detection,dataset,coco.2017,val,original,full --shell_cmd=\
'rm $CK_ENV_DATASET_COCO_LABELS_DIR/*train2017.json'

#TF second
# Install TF.
# Detect CUDA deps
RUN ck detect soft:compiler.cuda --full_path=/usr/local/cuda-10.1/bin/nvcc \
 && ck detect soft:lib.cudnn \
 && ck detect soft:lib.cublas --full_path=/usr/lib/x86_64-linux-gnu/libcublas.so

#Install CK deps
RUN ck install ck-env:package:jdk-8u131-universal
RUN ck install ck-env:package:tool-bazel-0.25.2-linux
#install TF from src, enabling tensorrt
RUN ck install package --tags=lib,tensorflow-cuda,v1.14,vsrc

#Models third
# Download the SSD-ResNet50 TF model.
RUN ck install package:tensorflowmodel-object-detection-ssd-resnet50-v1-fpn-sbp-640x640-coco
# Download the SSD-MobileNet TF models (non-quantized and quantized).
RUN ck install package --tags=model,tf,object-detection,mlperf,ssd-mobilenet,non-quantized
RUN ck install package --tags=model,tf,object-detection,mlperf,ssd-mobilenet,quantized,finetuned

#Last step
#change dependencies to support "external" benchmarking. 
#we want to launch the container with a volume attached to it, and the permission to write that volume will be of the user on the host machine.
#the dvdt user in the docker container will NOT be able to write there.
#launching the docker container with --user=$(id -u):$(id -g) allows to be the user in the docker container. 
#However, the user cannot read/write by default the dvdt userspace. 
#For this reason we have to change the permission to the dvdt userspace.
#note that this step allows to have the result, on the mounted volume, as if they were created by the user, after the end of the container run.
RUN chmod -R 777 ~/.local
RUN chmod -R 777 ~/CK
RUN chmod -R 777 ~/CK_REPOS
RUN chmod -R 777 ~/CK_TOOLS


#entry for the experiment folder, that will be mounted as a shared volume between dockerspace and hostspace ( -v$FULL_PATH_OF_THE_TARGET_FOLDER:/home/dvdt/CK_REPOS/local/experiment) 
#In this way it is possible to save the benchmarking outside the container and keep all the results
RUN ck create_entry --path=/home/dvdt/CK_REPOS/local --data_uoa=experiment


# Run the Object Detection TF-Python program
# with the non-quantized SSD-MobileNet model 
# on the first 50 images of the COCO 2017 validation dataset.
# weigths can be: resnet50, quantized, non-quantized
CMD ["ck run program:object-detection-tf-py --env.CK_BATCH_COUNT=50 --dep_add_tags.weights=non-quantized"]
