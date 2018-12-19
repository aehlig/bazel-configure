# Bazel-native `configure`

The purpose of this repository is to explore in which way bazel
could have a `configure`-like experience to explore the host system;
here, the assumption is that the host platform is also the platform
where actions (not necessarily the final program) are executed, or
at least that it is sufficiently equivalent (an assumption that is
not always true in bazel).

Such an exploration would be used, to build against pre-compiled
libraries&mdash;instead of telling bazel where the sources can be
obtained from and to build them itself. Building against pre-built
libraries can be useful, if the libraries themselves use a different
build system, thus allowing for gradual adoption; the non-bundling
also simplifies maintenance when other non-bazel projects depend
on those libraries as well (as duplication is avoided). Typically,
in those settings, the "ambient environment" is a `chroot`,
carefully set up by some package building tool, thus restoring the
reproducibility despite bazel not controlling


## The task of `configure`

When writing code that is to be run on more than one architecture,
one realizes that not all systems are equal: the system library
to be linked for a particular system is different on different
systems, header files are called differently, the underlying type
for `size_t` is different, etc.

The traditional approach to find out the specifics of the environment
is to try to compile and/or link small test programs and see if this
succeeds (as reported by the exit code of the compiler). Usually,
the approach does not involve running the test programs, as we
might be configuring for cross-compilation.

## Bazel-specific considerations

Bazel adhers to a strict phase separation, i.e., information and
artifacts can only flow from one phase to later phases, not to
earlier ones. The only place where bazel is allowed to inspect
the environment are "external repositories", which are evaluated
at loading phase&mdash;well before any building happens. However,
external repositories are allowed to execute arbitrary commands,
which still allows trying to compile the test porgrams. The most
important information to construct the command line is the knowledge
which C-compiler to use. Fortunately, external repositories may
depend on one another (in a cycle free way); they may not depend
on targets of other repositories, but they may use files generated
by repositories. `@local_config_cc` currently generates a file
`cc_wrapper.sh` which wraps the C-compiler to use, thus giving external
repositories analysing the environment the needed knowledge. This
file is not an official interface of `@local_config_cc`, but the
purpose of this repository is to explore how a possible interface
could look like; and if this style of configuration turns out to be
useful, it is well conceivable that `@local_config_cc` will provide
the needed information via an official interface.

## Layout of this repository

This repository consists of two directories.

- The `auto` directory contains simplified, proof-of-concept versions
  of repository rules looking at the ambient environment by running
  test compiles, in a way similar to what the GNU autotools do.

- The `main` directory is an (extremely artificial) example of how
  the information provided by those rules can be made available to
  the build.
