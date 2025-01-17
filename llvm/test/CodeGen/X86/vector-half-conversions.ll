; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx,+f16c -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx2,+f16c -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx2,+f16c,+fast-variable-crosslane-shuffle,+fast-variable-perlane-shuffle -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx2,+f16c,+fast-variable-perlane-shuffle -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx512f -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX512
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+fast-variable-crosslane-shuffle,+fast-variable-perlane-shuffle -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX512
; RUN: llc < %s -disable-peephole -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+fast-variable-perlane-shuffle -verify-machineinstrs | FileCheck %s --check-prefixes=ALL,AVX512

;
; Half to Float
;

define float @cvt_i16_to_f32(i16 %a0) nounwind {
; ALL-LABEL: cvt_i16_to_f32:
; ALL:       # %bb.0:
; ALL-NEXT:    movzwl %di, %eax
; ALL-NEXT:    vmovd %eax, %xmm0
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast i16 %a0 to half
  %2 = fpext half %1 to float
  ret float %2
}

define <4 x float> @cvt_4i16_to_4f32(<4 x i16> %a0) nounwind {
; ALL-LABEL: cvt_4i16_to_4f32:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast <4 x i16> %a0 to <4 x half>
  %2 = fpext <4 x half> %1 to <4 x float>
  ret <4 x float> %2
}

define <4 x float> @cvt_8i16_to_4f32(<8 x i16> %a0) nounwind {
; ALL-LABEL: cvt_8i16_to_4f32:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = shufflevector <8 x i16> %a0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = bitcast <4 x i16> %1 to <4 x half>
  %3 = fpext <4 x half> %2 to <4 x float>
  ret <4 x float> %3
}

define <8 x float> @cvt_8i16_to_8f32(<8 x i16> %a0) nounwind {
; ALL-LABEL: cvt_8i16_to_8f32:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = bitcast <8 x i16> %a0 to <8 x half>
  %2 = fpext <8 x half> %1 to <8 x float>
  ret <8 x float> %2
}

define <16 x float> @cvt_16i16_to_16f32(<16 x i16> %a0) nounwind {
; AVX-LABEL: cvt_16i16_to_16f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtph2ps %xmm0, %ymm2
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vcvtph2ps %xmm0, %ymm1
; AVX-NEXT:    vmovaps %ymm2, %ymm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: cvt_16i16_to_16f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtph2ps %ymm0, %zmm0
; AVX512-NEXT:    retq
  %1 = bitcast <16 x i16> %a0 to <16 x half>
  %2 = fpext <16 x half> %1 to <16 x float>
  ret <16 x float> %2
}

define <2 x float> @cvt_2i16_to_2f32_constrained(<2 x i16> %a0) nounwind strictfp {
; ALL-LABEL: cvt_2i16_to_2f32_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast <2 x i16> %a0 to <2 x half>
  %2 = call <2 x float> @llvm.experimental.constrained.fpext.v2f32.v2f16(<2 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <2 x float> %2
}
declare <2 x float> @llvm.experimental.constrained.fpext.v2f32.v2f16(<2 x half>, metadata) strictfp

define <4 x float> @cvt_4i16_to_4f32_constrained(<4 x i16> %a0) nounwind strictfp {
; ALL-LABEL: cvt_4i16_to_4f32_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast <4 x i16> %a0 to <4 x half>
  %2 = call <4 x float> @llvm.experimental.constrained.fpext.v4f32.v4f16(<4 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <4 x float> %2
}
declare <4 x float> @llvm.experimental.constrained.fpext.v4f32.v4f16(<4 x half>, metadata) strictfp

define <8 x float> @cvt_8i16_to_8f32_constrained(<8 x i16> %a0) nounwind strictfp {
; ALL-LABEL: cvt_8i16_to_8f32_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = bitcast <8 x i16> %a0 to <8 x half>
  %2 = call <8 x float> @llvm.experimental.constrained.fpext.v8f32.v8f16(<8 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <8 x float> %2
}
declare <8 x float> @llvm.experimental.constrained.fpext.v8f32.v8f16(<8 x half>, metadata) strictfp

define <16 x float> @cvt_16i16_to_16f32_constrained(<16 x i16> %a0) nounwind strictfp {
; AVX-LABEL: cvt_16i16_to_16f32_constrained:
; AVX:       # %bb.0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX-NEXT:    vcvtph2ps %xmm1, %ymm1
; AVX-NEXT:    vcvtph2ps %xmm0, %ymm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: cvt_16i16_to_16f32_constrained:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtph2ps %ymm0, %zmm0
; AVX512-NEXT:    retq
  %1 = bitcast <16 x i16> %a0 to <16 x half>
  %2 = call <16 x float> @llvm.experimental.constrained.fpext.v16f32.v16f16(<16 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <16 x float> %2
}
declare <16 x float> @llvm.experimental.constrained.fpext.v16f32.v16f16(<16 x half>, metadata) strictfp

;
; Half to Float (Load)
;

define float @load_cvt_i16_to_f32(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_i16_to_f32:
; ALL:       # %bb.0:
; ALL-NEXT:    movzwl (%rdi), %eax
; ALL-NEXT:    vmovd %eax, %xmm0
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = load i16, ptr %a0
  %2 = bitcast i16 %1 to half
  %3 = fpext half %2 to float
  ret float %3
}

define <4 x float> @load_cvt_4i16_to_4f32(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_4i16_to_4f32:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %xmm0
; ALL-NEXT:    retq
  %1 = load <4 x i16>, ptr %a0
  %2 = bitcast <4 x i16> %1 to <4 x half>
  %3 = fpext <4 x half> %2 to <4 x float>
  ret <4 x float> %3
}

define <4 x float> @load_cvt_8i16_to_4f32(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_8i16_to_4f32:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %xmm0
; ALL-NEXT:    retq
  %1 = load <8 x i16>, ptr %a0
  %2 = shufflevector <8 x i16> %1, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = bitcast <4 x i16> %2 to <4 x half>
  %4 = fpext <4 x half> %3 to <4 x float>
  ret <4 x float> %4
}

define <8 x float> @load_cvt_8i16_to_8f32(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_8i16_to_8f32:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %ymm0
; ALL-NEXT:    retq
  %1 = load <8 x i16>, ptr %a0
  %2 = bitcast <8 x i16> %1 to <8 x half>
  %3 = fpext <8 x half> %2 to <8 x float>
  ret <8 x float> %3
}

define <16 x float> @load_cvt_16i16_to_16f32(ptr %a0) nounwind {
; AVX-LABEL: load_cvt_16i16_to_16f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtph2ps (%rdi), %ymm0
; AVX-NEXT:    vcvtph2ps 16(%rdi), %ymm1
; AVX-NEXT:    retq
;
; AVX512-LABEL: load_cvt_16i16_to_16f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtph2ps (%rdi), %zmm0
; AVX512-NEXT:    retq
  %1 = load <16 x i16>, ptr %a0
  %2 = bitcast <16 x i16> %1 to <16 x half>
  %3 = fpext <16 x half> %2 to <16 x float>
  ret <16 x float> %3
}

define <4 x float> @load_cvt_4i16_to_4f32_constrained(ptr %a0) nounwind strictfp {
; ALL-LABEL: load_cvt_4i16_to_4f32_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %xmm0
; ALL-NEXT:    retq
  %1 = load <4 x i16>, ptr %a0
  %2 = bitcast <4 x i16> %1 to <4 x half>
  %3 = call <4 x float> @llvm.experimental.constrained.fpext.v4f32.v4f16(<4 x half> %2, metadata !"fpexcept.strict") strictfp
  ret <4 x float> %3
}

define <4 x float> @load_cvt_8i16_to_4f32_constrained(ptr %a0) nounwind strictfp {
; ALL-LABEL: load_cvt_8i16_to_4f32_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %xmm0
; ALL-NEXT:    retq
  %1 = load <8 x i16>, ptr %a0
  %2 = shufflevector <8 x i16> %1, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = bitcast <4 x i16> %2 to <4 x half>
  %4 = call <4 x float> @llvm.experimental.constrained.fpext.v4f32.v4f16(<4 x half> %3, metadata !"fpexcept.strict") strictfp
  ret <4 x float> %4
}

;
; Half to Double
;

define double @cvt_i16_to_f64(i16 %a0) nounwind {
; ALL-LABEL: cvt_i16_to_f64:
; ALL:       # %bb.0:
; ALL-NEXT:    movzwl %di, %eax
; ALL-NEXT:    vmovd %eax, %xmm0
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast i16 %a0 to half
  %2 = fpext half %1 to double
  ret double %2
}

define <2 x double> @cvt_2i16_to_2f64(<2 x i16> %a0) nounwind {
; ALL-LABEL: cvt_2i16_to_2f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast <2 x i16> %a0 to <2 x half>
  %2 = fpext <2 x half> %1 to <2 x double>
  ret <2 x double> %2
}

define <4 x double> @cvt_4i16_to_4f64(<4 x i16> %a0) nounwind {
; ALL-LABEL: cvt_4i16_to_4f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = bitcast <4 x i16> %a0 to <4 x half>
  %2 = fpext <4 x half> %1 to <4 x double>
  ret <4 x double> %2
}

define <2 x double> @cvt_8i16_to_2f64(<8 x i16> %a0) nounwind {
; ALL-LABEL: cvt_8i16_to_2f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = shufflevector <8 x i16> %a0, <8 x i16> undef, <2 x i32> <i32 0, i32 1>
  %2 = bitcast <2 x i16> %1 to <2 x half>
  %3 = fpext <2 x half> %2 to <2 x double>
  ret <2 x double> %3
}

define <4 x double> @cvt_8i16_to_4f64(<8 x i16> %a0) nounwind {
; ALL-LABEL: cvt_8i16_to_4f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = shufflevector <8 x i16> %a0, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = bitcast <4 x i16> %1 to <4 x half>
  %3 = fpext <4 x half> %2 to <4 x double>
  ret <4 x double> %3
}

define <8 x double> @cvt_8i16_to_8f64(<8 x i16> %a0) nounwind {
; AVX-LABEL: cvt_8i16_to_8f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtph2ps %xmm0, %ymm1
; AVX-NEXT:    vcvtps2pd %xmm1, %ymm0
; AVX-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX-NEXT:    vcvtps2pd %xmm1, %ymm1
; AVX-NEXT:    retq
;
; AVX512-LABEL: cvt_8i16_to_8f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtph2ps %xmm0, %ymm0
; AVX512-NEXT:    vcvtps2pd %ymm0, %zmm0
; AVX512-NEXT:    retq
  %1 = bitcast <8 x i16> %a0 to <8 x half>
  %2 = fpext <8 x half> %1 to <8 x double>
  ret <8 x double> %2
}

define <2 x double> @cvt_2i16_to_2f64_constrained(<2 x i16> %a0) nounwind strictfp {
; ALL-LABEL: cvt_2i16_to_2f64_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = bitcast <2 x i16> %a0 to <2 x half>
  %2 = call <2 x double> @llvm.experimental.constrained.fpext.v2f64.v2f16(<2 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <2 x double> %2
}
declare <2 x double> @llvm.experimental.constrained.fpext.v2f64.v2f16(<2 x half>, metadata) strictfp

define <4 x double> @cvt_4i16_to_4f64_constrained(<4 x i16> %a0) nounwind strictfp {
; ALL-LABEL: cvt_4i16_to_4f64_constrained:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = bitcast <4 x i16> %a0 to <4 x half>
  %2 = call <4 x double> @llvm.experimental.constrained.fpext.v4f64.v4f16(<4 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <4 x double> %2
}
declare <4 x double> @llvm.experimental.constrained.fpext.v4f64.v4f16(<4 x half>, metadata) strictfp

define <8 x double> @cvt_8i16_to_8f64_constrained(<8 x i16> %a0) nounwind strictfp {
; AVX-LABEL: cvt_8i16_to_8f64_constrained:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtph2ps %xmm0, %ymm0
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX-NEXT:    vcvtps2pd %xmm1, %ymm1
; AVX-NEXT:    vcvtps2pd %xmm0, %ymm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: cvt_8i16_to_8f64_constrained:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtph2ps %xmm0, %ymm0
; AVX512-NEXT:    vcvtps2pd %ymm0, %zmm0
; AVX512-NEXT:    retq
  %1 = bitcast <8 x i16> %a0 to <8 x half>
  %2 = call <8 x double> @llvm.experimental.constrained.fpext.v8f64.v8f16(<8 x half> %1, metadata !"fpexcept.strict") strictfp
  ret <8 x double> %2
}
declare <8 x double> @llvm.experimental.constrained.fpext.v8f64.v8f16(<8 x half>, metadata) strictfp

;
; Half to Double (Load)
;

define double @load_cvt_i16_to_f64(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_i16_to_f64:
; ALL:       # %bb.0:
; ALL-NEXT:    movzwl (%rdi), %eax
; ALL-NEXT:    vmovd %eax, %xmm0
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = load i16, ptr %a0
  %2 = bitcast i16 %1 to half
  %3 = fpext half %2 to double
  ret double %3
}

define <2 x double> @load_cvt_2i16_to_2f64(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_2i16_to_2f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; ALL-NEXT:    vpmovzxdq {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = load <2 x i16>, ptr %a0
  %2 = bitcast <2 x i16> %1 to <2 x half>
  %3 = fpext <2 x half> %2 to <2 x double>
  ret <2 x double> %3
}

define <4 x double> @load_cvt_4i16_to_4f64(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_4i16_to_4f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = load <4 x i16>, ptr %a0
  %2 = bitcast <4 x i16> %1 to <4 x half>
  %3 = fpext <4 x half> %2 to <4 x double>
  ret <4 x double> %3
}

define <4 x double> @load_cvt_8i16_to_4f64(ptr %a0) nounwind {
; ALL-LABEL: load_cvt_8i16_to_4f64:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtph2ps (%rdi), %xmm0
; ALL-NEXT:    vcvtps2pd %xmm0, %ymm0
; ALL-NEXT:    retq
  %1 = load <8 x i16>, ptr %a0
  %2 = shufflevector <8 x i16> %1, <8 x i16> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = bitcast <4 x i16> %2 to <4 x half>
  %4 = fpext <4 x half> %3 to <4 x double>
  ret <4 x double> %4
}

define <8 x double> @load_cvt_8i16_to_8f64(ptr %a0) nounwind {
; AVX-LABEL: load_cvt_8i16_to_8f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtph2ps (%rdi), %ymm1
; AVX-NEXT:    vcvtps2pd %xmm1, %ymm0
; AVX-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX-NEXT:    vcvtps2pd %xmm1, %ymm1
; AVX-NEXT:    retq
;
; AVX512-LABEL: load_cvt_8i16_to_8f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtph2ps (%rdi), %ymm0
; AVX512-NEXT:    vcvtps2pd %ymm0, %zmm0
; AVX512-NEXT:    retq
  %1 = load <8 x i16>, ptr %a0
  %2 = bitcast <8 x i16> %1 to <8 x half>
  %3 = fpext <8 x half> %2 to <8 x double>
  ret <8 x double> %3
}

;
; Float to Half
;

define i16 @cvt_f32_to_i16(float %a0) nounwind {
; ALL-LABEL: cvt_f32_to_i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    vmovd %xmm0, %eax
; ALL-NEXT:    # kill: def $ax killed $ax killed $eax
; ALL-NEXT:    retq
  %1 = fptrunc float %a0 to half
  %2 = bitcast half %1 to i16
  ret i16 %2
}

define <4 x i16> @cvt_4f32_to_4i16(<4 x float> %a0) nounwind {
; ALL-LABEL: cvt_4f32_to_4i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = fptrunc <4 x float> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  ret <4 x i16> %2
}

define <8 x i16> @cvt_4f32_to_8i16_undef(<4 x float> %a0) nounwind {
; ALL-LABEL: cvt_4f32_to_8i16_undef:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = fptrunc <4 x float> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %3
}

define <8 x i16> @cvt_4f32_to_8i16_zero(<4 x float> %a0) nounwind {
; ALL-LABEL: cvt_4f32_to_8i16_zero:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = fptrunc <4 x float> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %3
}

define <8 x i16> @cvt_8f32_to_8i16(<8 x float> %a0) nounwind {
; ALL-LABEL: cvt_8f32_to_8i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %ymm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <8 x float> %a0 to <8 x half>
  %2 = bitcast <8 x half> %1 to <8 x i16>
  ret <8 x i16> %2
}

define <16 x i16> @cvt_16f32_to_16i16(<16 x float> %a0) nounwind {
; AVX-LABEL: cvt_16f32_to_16i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtps2ph $4, %ymm0, %xmm0
; AVX-NEXT:    vcvtps2ph $4, %ymm1, %xmm1
; AVX-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: cvt_16f32_to_16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtps2ph $4, %zmm0, %ymm0
; AVX512-NEXT:    retq
  %1 = fptrunc <16 x float> %a0 to <16 x half>
  %2 = bitcast <16 x half> %1 to <16 x i16>
  ret <16 x i16> %2
}

;
; Float to Half (Store)
;

define void @store_cvt_f32_to_i16(float %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_f32_to_i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    vmovd %xmm0, %eax
; ALL-NEXT:    movw %ax, (%rdi)
; ALL-NEXT:    retq
  %1 = fptrunc float %a0 to half
  %2 = bitcast half %1 to i16
  store i16 %2, ptr %a1
  ret void
}

define void @store_cvt_4f32_to_4i16(<4 x float> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_4f32_to_4i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, (%rdi)
; ALL-NEXT:    retq
  %1 = fptrunc <4 x float> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  store <4 x i16> %2, ptr %a1
  ret void
}

define void @store_cvt_4f32_to_8i16_undef(<4 x float> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_4f32_to_8i16_undef:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    vmovaps %xmm0, (%rdi)
; ALL-NEXT:    retq
  %1 = fptrunc <4 x float> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  store <8 x i16> %3, ptr %a1
  ret void
}

define void @store_cvt_4f32_to_8i16_zero(<4 x float> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_4f32_to_8i16_zero:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    vmovaps %xmm0, (%rdi)
; ALL-NEXT:    retq
  %1 = fptrunc <4 x float> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  store <8 x i16> %3, ptr %a1
  ret void
}

define void @store_cvt_8f32_to_8i16(<8 x float> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_8f32_to_8i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtps2ph $4, %ymm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <8 x float> %a0 to <8 x half>
  %2 = bitcast <8 x half> %1 to <8 x i16>
  store <8 x i16> %2, ptr %a1
  ret void
}

define void @store_cvt_16f32_to_16i16(<16 x float> %a0, ptr %a1) nounwind {
; AVX-LABEL: store_cvt_16f32_to_16i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtps2ph $4, %ymm1, 16(%rdi)
; AVX-NEXT:    vcvtps2ph $4, %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: store_cvt_16f32_to_16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtps2ph $4, %zmm0, (%rdi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = fptrunc <16 x float> %a0 to <16 x half>
  %2 = bitcast <16 x half> %1 to <16 x i16>
  store <16 x i16> %2, ptr %a1
  ret void
}

;
; Double to Half
;

define i16 @cvt_f64_to_i16(double %a0) nounwind {
; ALL-LABEL: cvt_f64_to_i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtsd2ss %xmm0, %xmm0, %xmm0
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    vmovd %xmm0, %eax
; ALL-NEXT:    # kill: def $ax killed $ax killed $eax
; ALL-NEXT:    retq
  %1 = fptrunc double %a0 to half
  %2 = bitcast half %1 to i16
  ret i16 %2
}

define <2 x i16> @cvt_2f64_to_2i16(<2 x double> %a0) nounwind {
; ALL-LABEL: cvt_2f64_to_2i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    retq
  %1 = fptrunc <2 x double> %a0 to <2 x half>
  %2 = bitcast <2 x half> %1 to <2 x i16>
  ret <2 x i16> %2
}

define <4 x i16> @cvt_4f64_to_4i16(<4 x double> %a0) nounwind {
; ALL-LABEL: cvt_4f64_to_4i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %ymm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <4 x double> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  ret <4 x i16> %2
}

define <8 x i16> @cvt_4f64_to_8i16_undef(<4 x double> %a0) nounwind {
; ALL-LABEL: cvt_4f64_to_8i16_undef:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %ymm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <4 x double> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %3
}

define <8 x i16> @cvt_4f64_to_8i16_zero(<4 x double> %a0) nounwind {
; ALL-LABEL: cvt_4f64_to_8i16_zero:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %ymm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <4 x double> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %3
}

define <8 x i16> @cvt_8f64_to_8i16(<8 x double> %a0) nounwind {
; AVX-LABEL: cvt_8f64_to_8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtpd2ps %ymm1, %xmm1
; AVX-NEXT:    vcvtps2ph $0, %xmm1, %xmm1
; AVX-NEXT:    vcvtpd2ps %ymm0, %xmm0
; AVX-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: cvt_8f64_to_8i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtpd2ps %zmm0, %ymm0
; AVX512-NEXT:    vcvtps2ph $4, %ymm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = fptrunc <8 x double> %a0 to <8 x half>
  %2 = bitcast <8 x half> %1 to <8 x i16>
  ret <8 x i16> %2
}

;
; Double to Half (Store)
;

define void @store_cvt_f64_to_i16(double %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_f64_to_i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtsd2ss %xmm0, %xmm0, %xmm0
; ALL-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; ALL-NEXT:    vmovd %xmm0, %eax
; ALL-NEXT:    movw %ax, (%rdi)
; ALL-NEXT:    retq
  %1 = fptrunc double %a0 to half
  %2 = bitcast half %1 to i16
  store i16 %2, ptr %a1
  ret void
}

define void @store_cvt_2f64_to_2i16(<2 x double> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_2f64_to_2i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %xmm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    vmovss %xmm0, (%rdi)
; ALL-NEXT:    retq
  %1 = fptrunc <2 x double> %a0 to <2 x half>
  %2 = bitcast <2 x half> %1 to <2 x i16>
  store <2 x i16> %2, ptr %a1
  ret void
}

define void @store_cvt_4f64_to_4i16(<4 x double> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_4f64_to_4i16:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %ymm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <4 x double> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  store <4 x i16> %2, ptr %a1
  ret void
}

define void @store_cvt_4f64_to_8i16_undef(<4 x double> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_4f64_to_8i16_undef:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %ymm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    vmovaps %xmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <4 x double> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  store <8 x i16> %3, ptr %a1
  ret void
}

define void @store_cvt_4f64_to_8i16_zero(<4 x double> %a0, ptr %a1) nounwind {
; ALL-LABEL: store_cvt_4f64_to_8i16_zero:
; ALL:       # %bb.0:
; ALL-NEXT:    vcvtpd2ps %ymm0, %xmm0
; ALL-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; ALL-NEXT:    vmovaps %xmm0, (%rdi)
; ALL-NEXT:    vzeroupper
; ALL-NEXT:    retq
  %1 = fptrunc <4 x double> %a0 to <4 x half>
  %2 = bitcast <4 x half> %1 to <4 x i16>
  %3 = shufflevector <4 x i16> %2, <4 x i16> zeroinitializer, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  store <8 x i16> %3, ptr %a1
  ret void
}

define void @store_cvt_8f64_to_8i16(<8 x double> %a0, ptr %a1) nounwind {
; AVX-LABEL: store_cvt_8f64_to_8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtpd2ps %ymm1, %xmm1
; AVX-NEXT:    vcvtps2ph $0, %xmm1, %xmm1
; AVX-NEXT:    vcvtpd2ps %ymm0, %xmm0
; AVX-NEXT:    vcvtps2ph $0, %xmm0, %xmm0
; AVX-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX-NEXT:    vmovaps %xmm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: store_cvt_8f64_to_8i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtpd2ps %zmm0, %ymm0
; AVX512-NEXT:    vcvtps2ph $4, %ymm0, (%rdi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = fptrunc <8 x double> %a0 to <8 x half>
  %2 = bitcast <8 x half> %1 to <8 x i16>
  store <8 x i16> %2, ptr %a1
  ret void
}

define void @store_cvt_32f32_to_32f16(<32 x float> %a0, ptr %a1) nounwind {
; AVX-LABEL: store_cvt_32f32_to_32f16:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvtps2ph $4, %ymm3, 48(%rdi)
; AVX-NEXT:    vcvtps2ph $4, %ymm2, 32(%rdi)
; AVX-NEXT:    vcvtps2ph $4, %ymm1, 16(%rdi)
; AVX-NEXT:    vcvtps2ph $4, %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: store_cvt_32f32_to_32f16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vcvtps2ph $4, %zmm1, 32(%rdi)
; AVX512-NEXT:    vcvtps2ph $4, %zmm0, (%rdi)
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = fptrunc <32 x float> %a0 to <32 x half>
  store <32 x half> %1, ptr %a1
  ret void
}

define <4 x i32> @fptosi_2f16_to_4i32(<2 x half> %a) nounwind {
; ALL-LABEL: fptosi_2f16_to_4i32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpsrld $16, %xmm0, %xmm1
; ALL-NEXT:    vpextrw $0, %xmm1, %eax
; ALL-NEXT:    movzwl %ax, %eax
; ALL-NEXT:    vmovd %eax, %xmm1
; ALL-NEXT:    vcvtph2ps %xmm1, %xmm1
; ALL-NEXT:    vcvttss2si %xmm1, %eax
; ALL-NEXT:    vpextrw $0, %xmm0, %ecx
; ALL-NEXT:    movzwl %cx, %ecx
; ALL-NEXT:    vmovd %ecx, %xmm0
; ALL-NEXT:    vcvtph2ps %xmm0, %xmm0
; ALL-NEXT:    vcvttss2si %xmm0, %ecx
; ALL-NEXT:    vmovd %ecx, %xmm0
; ALL-NEXT:    vmovd %eax, %xmm1
; ALL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; ALL-NEXT:    vmovq {{.*#+}} xmm0 = xmm0[0],zero
; ALL-NEXT:    retq
  %cvt = fptosi <2 x half> %a to <2 x i32>
  %ext = shufflevector <2 x i32> %cvt, <2 x i32> zeroinitializer, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %ext
}
