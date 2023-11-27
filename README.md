
# p6-GIO - GNOME libgio bindings for Raku

## Installation

Make a directory to contain the p6-GLib-based projects. Once made, then set the P6_GTK_HOME environment variable to that directory:

```
$ export P6_GTK_HOME=/path/to/projects
```

Switch to that directory and clone both p6-GLib and p6-GIO

```
$ git clone https://github.com/Xliff/p6-GLib.git
$ git clone https://github.com/Xliff/p6-GIO.git
$ cd p6-GLib
$ zef install --deps-only .
```

[Optional] To build all of p6-GLib and p6-GIO, change to the p6-GIO directory
and run:

```
scripts/dependency-build.sh
```

If you just want to run the examples, you can do:

```
./p6gtkexec t/<name of example>
