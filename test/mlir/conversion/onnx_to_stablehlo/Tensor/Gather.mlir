// RUN: onnx-mlir-opt --convert-onnx-to-stablehlo %s --canonicalize -split-input-file | FileCheck %s

func.func @test_gather_axis0(%arg0 : tensor<3x2xf32>) -> tensor<2x2x2xf32> {
  %indices = "onnx.Constant"() {value = dense<[[0, 1], [1, 2]]> : tensor<2x2xi64>} : () -> tensor<2x2xi64>
  %0 = "onnx.Gather"(%arg0, %indices) {axis = 0 : si64} : (tensor<3x2xf32>, tensor<2x2xi64>) -> tensor<2x2x2xf32>
  "func.return"(%0) : (tensor<2x2x2xf32>) -> ()
}

// CHECK-LABEL:  func.func @test_gather_axis0
// CHECK-SAME:   ([[PARAM_0_:%.+]]: tensor<3x2xf32>) -> tensor<2x2x2xf32> {
// CHECK-DAG:       [[VAR_0_:%.+]] = stablehlo.constant dense<{{.}}[0, 1], [1, 2]{{.}}> : tensor<2x2xi64>
// CHECK-DAG:       [[VAR_1_:%.+]] = stablehlo.constant dense<0> : tensor<2x2xi64>
// CHECK-DAG:       [[VAR_2_:%.+]] = stablehlo.constant dense<3> : tensor<2x2xi64>
// CHECK-NOT: separator of consecutive DAGs
// CHECK-DAG:       [[VAR_3_:%.+]] = stablehlo.compare  LT, [[VAR_0_]], [[VAR_1_]],  NOTYPE : (tensor<2x2xi64>, tensor<2x2xi64>) -> tensor<2x2xi1>
// CHECK-DAG:       [[VAR_4_:%.+]] = stablehlo.add [[VAR_0_]], [[VAR_2_]] : tensor<2x2xi64>
// CHECK:           [[VAR_5_:%.+]] = stablehlo.select [[VAR_3_]], [[VAR_4_]], [[VAR_0_]] : tensor<2x2xi1>, tensor<2x2xi64>
// CHECK:           [[VAR_6_:%.+]] = "stablehlo.torch_index_select"([[PARAM_0_]], [[VAR_5_]]) {batch_dims = 0 : i64, dim = 0 : i64} : (tensor<3x2xf32>, tensor<2x2xi64>) -> tensor<2x2x2xf32>
// CHECK:           return [[VAR_6_]] : tensor<2x2x2xf32>
// CHECK:         }

// -----

func.func @test_gather_axis0neg(%arg0 : tensor<3x2xf32>) -> tensor<2x2x2xf32> {
  %indices = "onnx.Constant"() {value = dense<[[0, -1], [1, 2]]> : tensor<2x2xi64>} : () -> tensor<2x2xi64>
  %0 = "onnx.Gather"(%arg0, %indices) {axis = 0 : si64} : (tensor<3x2xf32>, tensor<2x2xi64>) -> tensor<2x2x2xf32>
  "func.return"(%0) : (tensor<2x2x2xf32>) -> ()
}

// CHECK-LABEL:  func.func @test_gather_axis0neg
// CHECK-SAME:   ([[PARAM_0_:%.+]]: tensor<3x2xf32>) -> tensor<2x2x2xf32> {
// CHECK-DAG:       [[VAR_0_:%.+]] = stablehlo.constant dense<{{.}}[0, -1], [1, 2]{{.}}> : tensor<2x2xi64>
// CHECK-DAG:       [[VAR_1_:%.+]] = stablehlo.constant dense<0> : tensor<2x2xi64>
// CHECK-DAG:       [[VAR_2_:%.+]] = stablehlo.constant dense<3> : tensor<2x2xi64>
// CHECK-NOT: separator of consecutive DAGs
// CHECK-DAG:       [[VAR_3_:%.+]] = stablehlo.compare  LT, [[VAR_0_]], [[VAR_1_]],  NOTYPE : (tensor<2x2xi64>, tensor<2x2xi64>) -> tensor<2x2xi1>
// CHECK-DAG:       [[VAR_4_:%.+]] = stablehlo.add [[VAR_0_]], [[VAR_2_]] : tensor<2x2xi64>
// CHECK:           [[VAR_5_:%.+]] = stablehlo.select [[VAR_3_]], [[VAR_4_]], [[VAR_0_]] : tensor<2x2xi1>, tensor<2x2xi64>
// CHECK:           [[VAR_6_:%.+]] = "stablehlo.torch_index_select"([[PARAM_0_]], [[VAR_5_]]) {batch_dims = 0 : i64, dim = 0 : i64} : (tensor<3x2xf32>, tensor<2x2xi64>) -> tensor<2x2x2xf32>
// CHECK:           return [[VAR_6_]] : tensor<2x2x2xf32>
// CHECK:         }

// -----

func.func @test_gather_axis1(%arg0 : tensor<3x3xf32>) -> tensor<3x1x2xf32> {
  %indices = "onnx.Constant"() {value = dense<[[0, 2]]> : tensor<1x2xi64>} : () -> tensor<1x2xi64>
  %0 = "onnx.Gather"(%arg0, %indices) {axis = 1 : si64} : (tensor<3x3xf32>, tensor<1x2xi64>) -> tensor<3x1x2xf32>
  "func.return"(%0) : (tensor<3x1x2xf32>) -> ()
}

// CHECK-LABEL:  func.func @test_gather_axis1
// CHECK-SAME:   ([[PARAM_0_:%.+]]: tensor<3x3xf32>) -> tensor<3x1x2xf32> {
// CHECK-DAG:       [[VAR_0_:%.+]] = stablehlo.constant dense<{{.}}[0, 2]{{.}}> : tensor<1x2xi64>
// CHECK-DAG:       [[VAR_1_:%.+]] = stablehlo.constant dense<0> : tensor<1x2xi64>
// CHECK-DAG:       [[VAR_2_:%.+]] = stablehlo.constant dense<3> : tensor<1x2xi64>
// CHECK-NOT: separator of consecutive DAGs
// CHECK-DAG:       [[VAR_3_:%.+]] = stablehlo.compare  LT, [[VAR_0_]], [[VAR_1_]],  NOTYPE : (tensor<1x2xi64>, tensor<1x2xi64>) -> tensor<1x2xi1>
// CHECK-DAG:       [[VAR_4_:%.+]] = stablehlo.add [[VAR_0_]], [[VAR_2_]] : tensor<1x2xi64>
// CHECK:           [[VAR_5_:%.+]] = stablehlo.select [[VAR_3_]], [[VAR_4_]], [[VAR_0_]] : tensor<1x2xi1>, tensor<1x2xi64>
// CHECK:           [[VAR_6_:%.+]] = "stablehlo.torch_index_select"([[PARAM_0_]], [[VAR_5_]]) {batch_dims = 0 : i64, dim = 1 : i64} : (tensor<3x3xf32>, tensor<1x2xi64>) -> tensor<3x1x2xf32>
// CHECK:           return [[VAR_6_]] : tensor<3x1x2xf32>
// CHECK:         }
