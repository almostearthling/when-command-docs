# When Documentation

This repository contains the documentation for **When**, reorganized and revised to be made available through a separate service and in different formats. The contents are almost the same as the old documentation (which will be stripped away from the applet at at some moment) and is rewritten in *reStructuredText* to be compiled using [Sphinx](http://sphinx-doc.org/).

To compile it, provided that *Sphinx 1.3* or later is installed, the following steps should be sufficient:

```
$ mkdir _build
$ sphinx-build -a -b html . _build
```

This documentation also includes the tutorial, which will also be removed as a standalone repository.
