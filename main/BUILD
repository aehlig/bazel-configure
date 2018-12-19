load("@math//:info.bzl", "math_info")
load("@headers//:info.bzl", "headers_copts")

cc_binary(
    name = "main",
    srcs = ["main.c"],
    linkopts = math_info["linkopts"],
    copts = headers_copts,
)
