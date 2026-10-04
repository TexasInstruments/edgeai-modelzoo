# Depth Anything V2 Small: TIDL graph port

Static ONNX export with the original learned weights, targeting SK-TDA4VM / J721E
using TIDL `11_00_08_00` and SDK `11.00.00.08`. This is a development candidate
validated in TI x86 host emulation. Physical-board execution, target throughput,
power, and accuracy against physical ground truth have not been verified.

- [Recorded depth video](https://huggingface.co/spaces/usctigerw/depth-anything-tidl-demo)
- [Model, compiled artifacts, source helpers, and reports](https://huggingface.co/usctigerw/depth-anything-v2-small-tidl-j721e)
- [Upstream checkpoint and attribution](https://huggingface.co/depth-anything/Depth-Anything-V2-Small-hf)
- [Optional Resize optimizer PR](https://github.com/TexasInstruments/edgeai-tidl-tools/pull/113)

`static.onnx.link` pins the ONNX download to an immutable HF revision. Expected
SHA-256: `b192a97202ef9675a8eedd29bc32b1faaff744af1fcd06fee064817e7d9054d3`.
The Small checkpoint is Apache-2.0; its upstream license is included.

## Model contract

Input: float32 `pixel_values`, `[1, 3, 224, 392]`, RGB NCHW. Output:
`predicted_depth`, `[1, 224, 392]`, **relative inverse depth**. Values are not
distance in metres, and this model does not measure range like LiDAR or ToF.

The verified demo resizes RGB with Pillow bicubic, divides by 255, then normalizes
by mean `[0.485, 0.456, 0.406]` and std `[0.229, 0.224, 0.225]`. The supplied
configuration expresses the equivalent mean/scale normalization on 0–255 RGB.
It is an inference/import recipe with dataset fields left unset: it does not
enable an unvalidated metric-depth benchmark. Supply representative calibration
feeds separately when importing. The tested import used three video frames.

## TIDL compatibility changes

1. Reorder a transpose across the split LayerNorm pattern to permit importer fusion.
2. Select Q/K/V through early channel Split before reshape/transpose, avoiding
   scalar Gather crashes and incorrect rank-five selection on the tested release.
3. Keep 12 Softmax operators on CPU and disable activation/weight clipping and
   bias calibration to preserve attention numerics.
4. Lower five align-corners bilinear Resize operations to separable constant
   MatMul operations. The tested native Resize used half-pixel-style coordinates.

One ConvTranspose also remains on CPU. The resulting graph contains 817 ONNX
nodes; 804 are assigned to 14 TIDL subgraphs. Node coverage is not MAC coverage.
Dense interpolation constants can increase compute/memory, so target latency
must be measured before treating this graph as a real-time video solution.

## Validation

The graph transformation preserves original CPU output within `6.92e-5` maximum
absolute error on three calibration inputs. All 19 recorded video-frame TI
outputs pass the unchanged 10% raw relative-RMSE gate against the transformed
CPU model; the worst error is **1.46%**, with correlation at least **0.999743**.
No scale alignment was applied to those tensor comparisons.

The recorded clip samples the entire 9.5-second source at 2 FPS. Playback is
independent of inference throughput; this is not a live camera benchmark.
Agreement against CPU establishes port fidelity, not physical depth accuracy.
The demo's colour scale is recomputed per frame, and the model has no temporal
state. Detailed per-frame checks and provenance are linked above.

Compiled artifacts are provided in the HF repository for the exact tested
SDK/SoC combination. Obtain TI runtime libraries/tools separately. Other
targets or releases require recompilation and verification. The runtime wrapper
uses `SOC=am68pa`, the tested release's J721E alias.

Depth estimates can add dense scene geometry for LiDAR fusion, ADAS, and robotics.
Using them for distance-based planning requires physical scale calibration,
sensor/time alignment, and temporal validation.
