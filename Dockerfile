# 使用 devel 镜像，包含 nvcc 和 CUDA 编译工具
FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

# 设置工作目录
WORKDIR /workspace

# ========== 设置腾讯云 apt 源 + 安装 git 和 build-essential ==========
RUN sed -i 's/archive.ubuntu.com/mirrors.tencent.com/g' /etc/apt/sources.list \
 && sed -i 's/security.ubuntu.com/mirrors.tencent.com/g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y git build-essential ninja-build libglib2.0-0 libgl1

# ========== 从宿主机复制已准备好的代码 ==========
# 将宿主机当前目录下的 "4DGaussians" 文件夹复制到容器的 "/workspace"
COPY . .

# 设置 CUDA 架构
ENV TORCH_CUDA_ARCH_LIST="8.0 8.6"
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH

# 安装依赖（直接在 base 环境，简化流程）
# 使用清华源加速 pip 安装
RUN pip install -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com -r requirements.txt \
 && pip install -e submodules/depth-diff-gaussian-rasterization \
 && pip install -e submodules/simple-knn \
 && pip install --upgrade typing_extensions

# 启动 bash（可选）
CMD ["/bin/bash"]