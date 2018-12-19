TEST_HEADER = """
#include <{header}>
"""

HEADERS = """
{name}_headers = {headers}

{name}_copts = {copts}
"""

def _test_try_compile(ctx, prg):
    ctx.file("conftest.c", prg)
    cmd = [ctx.path(ctx.attr.cc), "-c", ctx.path("conftest.c")]
    st = ctx.execute(cmd)
    ctx.execute(["rm", "-rf", ctx.path("conftest.c"), ctx.path("conftest.o")])
    return st.return_code == 0

def _opt_for_header(s):
    return "-DHAVE_" + s.upper().replace(".", "_").replace("/", "_")

def _impl(ctx):
    ctx.file("WORKSPACE", "workspace(name=\"{name}\")".format(name = ctx.name))
    copts = []
    results = {}

    for header in ctx.attr.headerfiles:
        ctx.report_progress("Checking header %s" % (header,))
        if _test_try_compile(ctx, TEST_HEADER.format(header = header)):
            copts += [_opt_for_header(header)]
            results[header] = True
        else:
            results[header] = False
    ctx.report_progress("Writing results")
    ctx.file("BUILD", "exports_files(['info.bzl'])")
    ctx.file(
        "info.bzl",
        HEADERS.format(headers = results, copts = copts, name = ctx.name),
    )

check_headers = repository_rule(
    implementation = _impl,
    attrs = {
        "cc": attr.label(default = "@local_config_cc//:cc_wrapper.sh"),
        "headerfiles": attr.string_list(default = []),
    },
)
"""
For a list of header files, try for each of them, if including them
results in a compilable program. Record this information, both, in
a dict telling for each header file whether it is a vailable, as well
as a list of options defining approrpriate HAVE_* macros.
"""
