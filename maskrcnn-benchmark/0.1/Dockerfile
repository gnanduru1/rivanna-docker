FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 AS build
ARG DIR=/vqa-maskrcnn-benchmark

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake g++ \
        wget git ca-certificates \
        libglib2.0-0 libsm6 libxext6 libxrender-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://micromamba.snakepit.net/api/micromamba/linux-64/latest | tar -xvj bin/micromamba

RUN micromamba create -p $DIR \
        python=3.6 pytorch=1.1.0 torchvision=0.3.0 cudatoolkit=10.0 -c pytorch -c conda-forge && \
    micromamba clean -ya

ENV PATH=$DIR/bin:$PATH

RUN pip install --no-cache-dir \
        requests ninja yacs cython matplotlib opencv-python tqdm

WORKDIR /opt

RUN git clone https://github.com/cocodataset/cocoapi.git && \
    cd cocoapi/PythonAPI && \
    python setup.py build_ext install

RUN git clone https://github.com/NVIDIA/apex.git && \
    cd apex && \ 
# 2019-11-06
    git reset --hard 37cdaf4ad57ab4e7dd9ef13dbed7b29aa939d061 && \
    python setup.py install --cuda_ext --cpp_ext

ENV FORCE_CUDA=1
RUN git clone https://gitlab.com/vedanuj/vqa-maskrcnn-benchmark.git && \
    cd vqa-maskrcnn-benchmark && \
    python setup.py build develop

FROM debian:buster-slim
ARG DIR=/vqa-maskrcnn-benchmark

RUN apt-get update && apt-get install -y --no-install-recommends \
        libglib2.0-0 libsm6 libxext6 libxrender-dev && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build $DIR $DIR
COPY --from=build /opt/cocoapi/PythonAPI /opt/cocoapi/PythonAPI
COPY --from=build /opt/apex /opt/apex
COPY --from=build /opt/vqa-maskrcnn-benchmark /opt/vqa-maskrcnn-benchmark

ENV PATH=$DIR/bin:$PATH \
    LD_LIBRARY_PATH=$DIR/lib:$LD_LIBRARY_PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1-mesa-glx && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir ipykernel opencv-python

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ && \
    rm -rf /var/lib/apt/lists/*

LABEL maintainer=rs7wz@virginia.edu \
      homepage=https://gitlab.com/vedanuj/vqa-maskrcnn-benchmark.git \
      description="Fast, modular reference implementation of Instance Segmentation and Object Detection algorithms in PyTorch." \
      gpu=true \
      moduleclass=data

ENTRYPOINT ["python"]