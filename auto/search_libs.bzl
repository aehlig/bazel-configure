TEST_SYMBOL = """
char {symbol} () ;

int main() {{
  return {symbol} () ;
  return 0;
}}
"""

CC_IMPORT = """
# example how a BUILD file could look, once `cc_import` supports
# a linkopts argument.

cc_import(
  name = "lib",
  linkopts = {linkopts},
)
"""

CC_LIB_STRUCT = """
{name}_info = {{
  "linkopts" : {linkopts},
}}
"""

def _test_try_link(ctx, prg, flags):
    ctx.file("conftest.c", prg)
    cmd = [ctx.path(ctx.attr.cc)] + flags + [ctx.path("conftest.c")]
    st = ctx.execute(cmd)
    ctx.execute(["rm", "-rf", ctx.path("conftest.c"), ctx.path("a.out")])
    return st.return_code == 0

def _write_cc_import(ctx, linkflags):
    ctx.file("future-BUILD", CC_IMPORT.format(linkopts = linkflags))
    ctx.file("BUILD", "exports_files(['info.bzl'])")
    ctx.file(
        "info.bzl",
        CC_LIB_STRUCT.format(linkopts = linkflags, name = ctx.name),
    )

def _impl(ctx):
    ctx.file("WORKSPACE", "workspace(name=\"{name}\")".format(name = ctx.name))
    for flag in [[]] + [["-l" + f] for f in ctx.attr.libs]:
        ctx.report_progress("Searching for '%s', candidate %s" %
                            (ctx.attr.symbol, flag))
        if _test_try_link(
            ctx,
            TEST_SYMBOL.format(symbol = ctx.attr.symbol),
            flag,
        ):
            _write_cc_import(ctx, flag)
            return
    fail("Could not find symbol '%s' in any of %s" %
         (ctx.attr.symbol, ctx.attr.flags))

search_libs = repository_rule(
    implementation = _impl,
    attrs = {
        "cc": attr.label(default = "@local_config_cc//:cc_wrapper.sh"),
        "symbol": attr.string(mandatory = True),
        "libs": attr.string_list(default = []),
    },
)
"""
Try a given set of libraries and find the first one (implicitly
starting the search with no library provided) providing the given
symbol.
"""
