============
Contributing
============

**When** is open source software, this means that contributions are welcome.
To contribute with code, please consider following the minimal recommendations
that usually apply to the software published on GitHub:

1. Fork the `When repository`_ and pull it to your working directory
2. Create a branch for the new feature or fix: ``git checkout -b new-branch``
3. Edit the code and commit: ``git commit -am "Add this feature to When"``
4. Push your changes to the new branch: ``git push origin new-branch``
5. Compare and submit a `Pull Request`_.

A more general discussion about contribution can be found here_. Otherwise,
just submit an issue to notify a bug, a mistake or something that could just
have been implemented better. Just consider that the applet is intended to be
and remain small in terms of code and features, so that it can stay in the
background of an user session without disturbing it too much.

.. _`When Repository`: https://github.com/almostearthling/when-command
.. _`Pull Request`: https://github.com/almostearthling/when-command/compare
.. _here: https://help.github.com/articles/using-pull-requests


Some Notes about the Code
=========================

The applet is in fact a small utility, and I thought it also would have even
less features. It grew a little just because some of the features could be
added almost for free, so the "*Why Not?*" part of the development process
has been quite consistent for a while. The first usable version of the applet
has been developed in about two weeks, most of which spent learning how to use
*PyGObject* and friends, and not on a full time basis: by the 5th day I had to
freeze the features and focus on the ones I wrote down. So, being small and
mostly not reusable, the single-source option seemed the most obvious, also
to keep the package as self-contained as possible. However, the way the applet
starts and defines its own system-wide and user directories allows the
development of modules that can be imported without cluttering and polluting
the system: the ``APP_DATA_FOLDER`` variable defines a dedicated directory
for the application where modules can be installed, and normally it points to
``<install-base>/when-command/share`` or ``/usr/[local/]share/when-command``
or something similar and well identifiable anyway.

The code tries to follow the usual guidelines for Python 3.x, and takes
inspiration from other Gnome applets that sit in the indicator tray. I tried
to reduce the comments to the very least, and let the code speak for itself.
Some of the conventions here are the following:

* system wide constants are spelled in all uppercase (as usual in *C/C++*)
* variables tend to be all lowercase, both globals and locals
* class names start with an uppercase letter and are in camelcase
* global instances of classes are lowercase, like simple variables
* private members start, as usual, with an underscore
* function names are all lowercase with underscores
* transitional (or debug) functions start with underscores
* the core classes implement their own loggers, borrowing from the global one
* user interaction strings (and log messages) use double quotes
* program internal strings use single quotes
* statements tend to be split in lines of at most 80 characters, apart from
  log messages
* log messages mostly sport a prefix to determine what part generated them
* log messages containing the ``NTBS`` strings are *never to be seen*.

All user interaction strings (except log messages) are surrounded by the
usual ``_(...)`` formula used in software that implements the ``gettext``
functions: this allows to translate **When** without intervention on the code
itself, in the usual fashion for Linux applications.


Developer Dependencies
======================

Being an applet oriented mostly towards users of recent Ubuntu editions, it
is developed in *Python 3.x* and uses the latest supported edition of
*PyGObject* at the time. It shouldn't rely on other packages than
``python3-gi`` and ``python3-pyinotify`` on the Python side. [#reqs]_ The
*Glade* user interface designer is almost mandatory to edit the dialog boxes.

To implement the "*Idle Session*" based condition (i.e. the one that lets a
task run when the session has been idle for a while), however, the external
``xprintidle`` command is used that is not installed by default on Ubuntu: at
this time the DBus idle time detection function is still imperfect and crashes
the applet, so it still relies on the external command. Also, by doing this,
the "*Idle Session*" based condition is not much more than a *Command* based
condition, and this simplified the development a lot.


Localization
============

Starting with version *0.9.1-beta.2* **When** supports the standard
localization paradigm for Linux software, via ``gettext`` and its companion
functions. This means that all translation work can be done with the usual
tools available on Linux, that is:

* ``xgettext`` (for the Python source) and ``intltool-extract`` (for the
  *Glade* UI files)
* ``msginit``, ``msgmerge`` and ``msgfmt``

This should allow for easier translation of the software. In fact I provide
the Italian localization (it's the easiest one for me): help is obviously
welcome and really appreciated for other ones.

I can provide some simple instructions for volunteers that would like to
help translate **When** in other languages: I've already seen some activity
in this sense, and very quickly after the first public announcement. I'm
really glad of it, because it helps **When** become more complete and usable.

Think of the following instructions more as a *recipe* than as an official
method to carry the translation tasks.


Template Generation
-------------------

.. Note::
  Normally, to translate the applet, a translator only needs access to the
  most recent *message template* (which is ``po/messages.pot``); however these
  instructions also try to show how to generate such template in case some
  text in the source has changed, for example while fixing a bug.

Basically the necessary tools are:

* ``intltool-extract`` to retrieve text from the UI files
* ``xgettext`` to extract text from the main applet source.

When in the source tree base, the following commands can be used to generate
the template without cluttering the rest of the source tree:

::

  $ mkdir .temp
  $ for x in share/when-command/*.glade ; do
  >   intltool-extract --type=gettext/glade $x
  >   mv -f $x.h .temp
  > done
  $ xgettext -k_ -kN_ -o po/messages.pot -D share/when-command -D .temp -f po/translate.list

After template generation, which is stored in ``po/messages.pot``, the
``.temp`` directory can be safely deleted. If ``po/messages.pot`` already
exists and is up to date, this step can be skipped.


Create and Update Translations
------------------------------

To create a translation, one should be in a localized environment:

::

  $ cd po
  $ export LANG=it_IT
  $ msginit --locale=it_IT --input=po/messages.pot --output=po/it.po

where ``it_IT`` is used as an example and should be changed for other locales.
For all ``po/*.po`` files (in this case ``it.po`` is created), the following
command can be used to create an updated file without losing existing work:

::

  $ msgmerge -U po/it.po po/messages.pot

where ``it.po`` should be changed according to locale to translate. The
generated or updated ``.po`` file has to be modified by adding or updating the
translation, and there are at least two options for it:

* use a standard text editor (the applet source and string set is small enough
  to allow it)
* use a dedicated tool like poedit_.

After editing the *portable object*, it must be compiled and moved to the
appropriate directory for proper installation, as shown below.

.. _poedit: https://poedit.net/


Create the Object File
----------------------

When the ``.po`` file has been edited appropriately, the following commands
create a compiled localization file in a subtree of ``share/locale`` that is
ready for packaging and distribution:

::

  $ mkdir -p share/locale/it/LC_MESSAGES
  $ msgfmt po/it.po -o share/locale/it/LC_MESSAGES/when-command.mo

Also here, ``it.po`` and the ``/it/`` part in the folder have to be changed
according to the translated locale. In my opinion such command-line based
tools should be preferred over other utilities to create the compiled object
file, in order to avoid to save files in the wrong places or to possibly
pollute a package generated from the repository clone. However, for the
editing phase in *Step 2* any tool can be used. If ``poedit`` is used and
launched from the base directory of the source tree, it should automatically
recognize ``po`` as the directory containing translation files: open the one
that you would like to edit and you will be presented with a window that
allows per-string based translation. [#nonewstrings]_


Translation hints
-----------------

I have tried to be as consistent as possible when writing UI text and command
line output in English. Most of the times I tried to follow these basic
directions:

* I preferred US English over British (although I tend to prefer to speak
  British)
* text in dialog box labels follows (or at least should follow, I surely have
  left something out) `title case`_
* text in command line output is never capitalized, apart from the preamble
  and notes for the ``--help`` switch output, and the applet name in the
  ``--version`` output.

These guidelines should also help to recognize where a string is used when
translating a newly created ``xx.po`` file: basically, all (or almost all)
sentences that begin with a lower case letter belong to console output, and
strings that begin with a capital letter belong in almost all cases to
graphical UI. However a translator is strongly advised to give **When** a
try, and explore its English interface (both UI and console, by trying the
various switches using the ``--verbose`` modifier) to be sure of what he is
translating. Also, be sure to issue

::

  $ when-command --help

to locate text that belongs to brief command help. Please note that some words
in the help text for the ``-h`` switch cannot be modified: they are directly
handled by the Python interpreter. Some more detailed instructions follow:

1. help text for switches should remain *below 55 characters*
2. letters inside brackets in help text should not be changed
3. console output strings should remain *below 60 characters*, and consider
   that ``%s`` placeholders in some cases might be replaced by quite long
   strings (like 20 characters or so)
4. strings in ALL CAPS, numbers and mathematical symbols
   *must NOT be translated*
5. labels in dialog boxes should remain as short as possible, possibly around
   the same size as the English counterpart
6. labels that are *above* or *aside* text entries (especially the time
   specifications that appear in the *Condition Dialog Box* for time based
   conditions and the *DBus parameter* specification strings like *Value #*
   and *Sub #*) should *not* be longer than the English counterpart: use
   abbreviations if necessary
7. most of the times, entries in drop down combo boxes (such as condition
   types) *can* be somewhat longer than the English counterpart
8. keep dialog box names short
9. *button* labels *must* follow existing translations every time it is
   possible: for example, the *Reload* button is present in many applications
   and the most common translation should be preferred
10. menu entries that have common counterparts (such as *About...*,
    *Settings...* and *Quit*) should be translated accordingly
11. button labels should not force the growth of a button: use a different
    translation if necessary, or an abbreviation if there is no other option
12. column titles should not be much longer than the English counterparts,
    use abbreviations if necessary unless the related column is part of a
    small set (like two or three columns)
13. *title case* is definitely *not* mandatory: the most comfortable and
    pleasant casing style should be used for each language
14. try to use only special characters normally available in the default
    ASCII code page for the destination language, such as diacritics: if
    possible avoid symbols and non-printable characters.

.. Note::
  There is one point where the translation might become difficult: the
  ``"showing %s box of currently running instance"`` *msgid*. Here ``%s`` is
  replaced with a machine-determined nickname for a dialog box. For the
  *About Dialog Box* the message would be
  ``"showing about box of currently running instance"`` and the word ``about``
  cannot be translated. Feel free to use quotes to enclose the nickname in a
  translation, if you find it necessary.

A personal hint, that I followed when translating from English to Italian, is
that when a term in one's own language is either obsolete, or unusual, or just
"funny" in the context, it has not to be necessarily preferred over a
colloquially used English counterpart. For example, the word *Desktop* is
commonly used in Italian to refer to a graphical session desktop: I would
never translate it to *Scrivania* -- which is the exact translation -- in an
application like **When**, because it would sound strange to the least.

.. _`title case`: http://www.grammar-monster.com/lessons/capital_letters_title_case.htm


Test Suite
==========

As of version *0.7.0-beta.1* **When** has an automated test suite. The test
suite does not come packaged with the applet, since it wouldn't be useful
to install the test scripts on the user machine: instead, it's stored in its
dedicated repository_, see the specific ``README.md`` file for more details.
The test suite is kept as a separate entity from the project: future releases
of the test suite could be moved to a dedicated GitHub repository.

Whenever a new feature is added, that affects the *background* part of
**When** (i.e. the loop that checks conditions and possibly runs tasks),
specific tests should be added using the test suite "tools", that is:

* the configurable *items* export file
* the *ad hoc* configuration file
* the test functions in ``run.sh``.

It has to be noted that, at least for now, the test suite is only concerned
about *function* and not *performance*: since **When** is a rather lazy
applet, performance in terms of speed is not a top requirement.

.. _repository: https://github.com/almostearthling/when-command-testsuite.git


Packaging
=========

In order to build a package that is compatible with the Linux FHS and LSB,
many changes have been introduced in the directory structure of the **When**
source tree. The most significant changes are:

* a new position for the main applet script
* a slightly different hierarchy in the ``share`` directory, with the
  introduction of

  - a folder for standard icons in different sizes, under
    ``share/icons/hicolor/<size>/apps/when-command``
  - a ``share/doc/when-command`` folder which contains documentation that
    is installed with the applet (``README.md``, ``LICENSE`` and
    ``copyright``)
  - the ``share/when-command`` folder containing all the resources and the
    main applet script (``when-command.py``)

* the files needed by the standard Python setup script, as well as the setup
  script itself (namely `setup.py`, `setup.cfg`, `stdeb.cfg` and
  `MANIFEST.in`), have been added to the project
* a stub file that will serve as the main entry point to start
  ``when-command`` instead of invoking the main applet script directly
* other files required by the utilities used to build the Debian package.

Other changes involve the code itself: parts of the script has been modified
in order to allow better recognition of the *LSB-based* installation (the one
that expects the entry point to be installed in ``/usr/bin`` and data files
in ``/usr/share``), even though the possibility has been kept to build a
package that installs **When** in `/opt` as it has been usual until now. From
now on the preferred installation mode will be the *LSB-based* one, the
``/opt`` based package is supported on a "best effort" basis for whoever
would want to keep **When** separated from the Linux installation.

Unfortunately the new directory setup could require some more effort to allow
for local installations (e.g. in the user's home directory), although I'll
try to do my best to make this process as easy as possible.


Requirements for Packaging
--------------------------

**When** uses Python 3.x ``setuptools`` (package ``python3-setuptools``, it
is possibly already installed on the system) to create the source distribution
used bu the packaging system. Most information about how to package an
application has been retrieved in `Packaging and Distributing Projects`_,
in `Introduction to Debian Packaging`_ and
`Python libraries/application packaging`_, as well as in the
`setuptools documentation`_. Especially, the ``stdeb`` for Python 3.x has
been used: this package is not provided by the official repository in
*Ubuntu 14.04*, so a *pip* installation may be required:

::

  $ pip3 install --user stdeb

Also, to build a ``.deb`` package, the standard ``debhelper``,
``build-essential`` and ``fakeroot`` packages and tasks are needed. I also
installed ``python-all``, ``python3-all``, ``python-all-dev``,
``python3-all-dev`` and ``python-stdeb`` (which is available, but it is for
Python 2.x and quite old), but they might be not needed.

.. _`Packaging and Distributing Projects`: http://python-packaging-user-guide.readthedocs.org/en/latest/distributing/
.. _`Introduction to Debian Packaging`: https://wiki.debian.org/IntroDebianPackaging
.. _`Python libraries/application packaging`: https://wiki.debian.org/Python/Packaging
.. _`setuptools documentation`: http://pythonhosted.org/setuptools/


Package Creation: LSB Packages
------------------------------

As far as I'm concerned, this step can be considered black magic. I expected
packaging to be a relatively simple thing to do, something more similar to
stuffing files into a tarball and then adding some metadata to the archive to
allow for the installation tools to figure out how things have to be done.
Apparently there is much more than that, especially when it comes to Python
applications. And when the main entry point of such a Python application
contains a dash, things get worse: none of the standard installation methods
that use the ``setup.py`` script seems to be suitable. That is why, for
instance, the ``when-command.py`` script is considered  a data file in the
whole process, whereas a stub script named ``when-command`` (with no
extension) is marked as *script*: we will not use the ``entry_points`` setup
keyword, because we don't absolutely want ``setup.py`` to generate the stub
script for us, since the *supposed-to-be-library* file contains a dash and
could be not imported in an easy way.

However, here are the steps I perform to build a ``.deb`` package.


The Easy Way with ``setup.py``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After unpacking the source tree, the following commands can be used to easily
build the ``.deb`` package:

::

  $ cd <when-source-tree>
  $ python3 setup.py --command-packages=stdeb.command bdist_deb

The ``python3 setup.py ... bdist_deb`` actually builds a ``.deb`` file in the
``deb_dist`` directory: this package is suitable to install **When**. The same
``deb_dist`` directory also contains a source package, in the form of a
``.dsc`` file, ``.orig.tar.gz`` and ``.debian.tar.gz`` archives, and
``.changes`` files. However the ``.dsc`` and ``changes`` files are not
signed: to upload the package to a *PPA*, for instance, they need to be
signed using ``gpg --clearsign``.


Using the Packaging Utilities Directly
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First a source distribution has to be created: the ``setup.py`` script comes
handy in this case too because it can do this job automatically using the
``sdist`` command. After the source tree has been unpacked or cloned, the
following operations will create a proper source distribution of **When**
and move it to the top of the source tree:

::

  $ cd <when-source-tree>
  $ python3 setup.py sdist
  $ mv dist/when-command-<version_identifier>.tar.gz .

where ``<version-identifier>`` is the suffix of the newly created archive in
the ``dist`` subdirectory. Then use the ``py2dsc`` tool to create the
structure suitable for packaging :

::

  $ py2dsc -m "$DEBFULLNAME <$DEBEMAIL>" when-command-<version_identifier>.tar.gz
  $ cd deb_dist/when-command-<version_identifier>

The guide in `Python libraries/application packaging`_ suggests then to edit
some files in the ``debian`` subdirectory, namely ``control`` and ``rules``.
The files should read as follows:

**control:**

::

  Source: when-command
  Maintainer: Francesco Garosi (AlmostEarthling) <franz.g@no-spam-please.infinito.it>
  Section: misc
  Priority: optional
  Build-Depends: python3-setuptools, python3, debhelper (>= 7.4.3)
  Standards-Version: 3.9.5
  X-Python3-Version: >= 3.4

  Package: when-command
  Architecture: all
  Depends: ${misc:Depends}, ${python3:Depends}, python-support (>= 0.90.0), python3-gi, xprintidle, gir1.2-appindicator3-0.1, python3-pyinotify
  Description: When Gnome Scheduler
   When is a configurable user task scheduler, designed with Ubuntu
   in mind. It interacts with the user through a GUI, where the user
   can define tasks and conditions, as well as relationships of
   causality that bind conditions to tasks.

**rules:**

::

  #!/usr/bin/make -f

  %:
  	dh $@ --with python3

  override_dh_auto_clean:
  	python3 setup.py clean -a
  	find . -name \*.pyc -exec rm {} \;

  override_dh_auto_build:
  #	python3 setup.py build --force

  override_dh_auto_install:
  	python3 setup.py install --force --root=debian/when-command --install-layout=deb --install-lib=/usr/share/when-command --install-scripts=/usr/bin

  override_dh_python3:
  	dh_python3 --shebang=/usr/bin/python3

Since we use a stub file, no ``links`` specification is actually necessary.
This in fact differs from the advices given in the aforementioned guide:
instead of specifying the target directory for *scripts* as
``/usr/share/when-command`` (same as the main script) in the package creation
``rules``, we let the package install the stub in ``/usr/bin`` directly and
don't rely on symbolic links. The package creation procedure is slightly
simplified in this way, and provides a tidier setup. Also, the comment in
the ``override_dh_auto_build`` rule is intentional, and better explained in
the guide.

To build the package the standard Debian utilities can be used in the
following way:

::

  $ cd <source-directory>
  $ pkgdir=deb_dist/when-command-<version_identifier>
  $ cp $pkgdir/share/doc/when-command/copyright $pkgdir/debian
  $ cd deb_dist/when-command-<version_identifier>
  $ debuild

The package is in the `deb_dist` directory. After entering the source
directory, the first two lines just synchronize the `copyright` file from
the unpacked source tree to the `debian` "service" directory just to avoid
some of the complaints that `lintian` shows during the build process, while
the last two lines are the commands that actually build the Debian package.

This process also creates a source package in the same form as above, with
the exception that the ``.dsc`` and ``.changes`` files should be already
signed after the process if the environment is correctly configured. In
fact, to build the package, the ``DEBFULLNAME`` and ``DEBEMAIL`` environment
variables are required, and must match the name and e-mail address provided
when the *GPG key* used to sign packages has been generated: see the
`Ubuntu Packaging Guide`_ for details.

At a small price in terms of complexity, this method has one main advantage
over the "easy" one as it allows some more control on packaging by allowing
to review and edit all the package control files before creation.

.. _`Ubuntu Packaging Guide`: http://packaging.ubuntu.com/html/getting-set-up.html#create-your-gpg-key


Package Creation: the Old Way
-----------------------------

As suggested above, a way to build the old ``/opt`` based package is still
available. I use a script that moves all files in the former locations,
removes extra and unused files and scripts, and then builds a ``.deb`` that
can be used to install the applet in ``/opt/when-command``. This file can be
found in a GitHub gist_, together with the ``control_template`` file that it
needs to build the package. It has to be copied to a suitable build directory
together with ``control_template``, made executable using
``chmod a+x makepkg.sh``, modified in the variables at the top of the file
and launched.

.. _gist: https://gist.github.com/almostearthling/009fbbe27ea5ca921452






.. [#reqs] In fact the other packages that could possibly require installation
  are the ones mentioned in the chapter devoted to the applet install process.
  No *-dev* packages should be needed because **When** is entirely developed
  in the Python language.

.. [#nonewstrings] Consider that ``poedit`` would not show new or untranslated
  strings by default.
