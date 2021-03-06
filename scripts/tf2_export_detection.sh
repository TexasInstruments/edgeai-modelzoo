#!/usr/bin/env bash

# Copyright (c) 2018-2021, Texas Instruments
# All Rights Reserved
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-11
TF_MODELS_REPO="/user/a0393608/files/work/github/tensorflow/models"
export PYTHONPATH=:$PYTHONPATH:/user/a0393608/files/work/github/tensorflow/models/research

############################################################
MODEL_NAMES="./downloads/tf2/od/ssd_mobilenet_v1_fpn_640x640_coco17_tpu-8
./downloads/tf2/od/ssd_mobilenet_v2_320x320_coco17_tpu-8
./downloads/tf2/od/ssd_mobilenet_v2_fpnlite_320x320_coco17_tpu-8
./downloads/tf2/od/ssd_mobilenet_v2_fpnlite_640x640_coco17_tpu-8
./downloads/tf2/od/ssd_resnet50_v1_fpn_640x640_coco17_tpu-8
./downloads/tf2/od/ssd_resnet50_v1_fpn_1024x1024_coco17_tpu-8
"

for model_name in ${MODEL_NAMES}; do
LOCAL_DIR="${model_name}"

python3 ${TF_MODELS_REPO}/research/object_detection/export_tflite_graph_tf2.py \
    --pipeline_config_path ${LOCAL_DIR}/pipeline.config \
    --trained_checkpoint_dir ${LOCAL_DIR}/checkpoint \
    --output_directory ${LOCAL_DIR}/tflite

tflite_convert \
    --saved_model_dir=${LOCAL_DIR}/tflite/saved_model \
    --output_file=${LOCAL_DIR}/tflite/model.tflite

done


