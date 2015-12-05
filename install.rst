============
Installation
============

**When** supports several installation types. The easiest way to install it
is using one of the packages_ provided for Ubuntu, that may also be suitable
for other Debian based Linux distributions. However, if a different setup is
needed (for instance in a `per-user` based installation), it is possible to
install **When** directly from a source archive or from a clone of the *Git*
repository_.

This chapter covers the installation process and the additional actions that
should be performed to get **When** up and running for an user. Information
is also provided on how to remove the applet from the system or for an user.

.. _packages: https://github.com/almostearthling/when-command/releases
.. _repository: https://github.com/almostearthling/when-command.git


Requirements
============

For the applet to function and before unpacking it to the destination
directory, make sure that *Python 3.x*,  *PyGObject* for *Python 3.x* and the
``xprintidle`` utility are installed. Optionally, to enable file and directory
monitoring, the ``pyinotify`` package can be installed. For example, not all
of these are installed by default on Ubuntu: in this case the following
commands can be used.

::

  $ sudo apt-get install python3-gi
  $ sudo apt-get install xprintidle
  $ sudo apt-get install gir1.2-appindicator3-0.1
  $ sudo apt-get install python3-pyinotify

The ``gir1.2-appindicator3-0.1`` package may not be needed on all systems, but
some Linux distributions do not install it by default. ``python3-pyinotify``
is normally considered *optional* for **When** [#pyinotify]_ to work, but it
is necessary to enable conditions based on changes to the file system.

After the requirements have been fulfilled, the methods below can be used to
set up the applet.


Package Based Install
=====================

As said above, a package provides the quickest and easiest way to have a
working installation of **When**. Packages are provided for Ubuntu, although
they might work (at least partially) with other Debian based Linux
distributions. **When** packages come in two flavors:

1. ``when-command``: this is a LSB structured package, especially suitable
   for Ubuntu and derivatives, that installs the applet in a way similar to
   other standard Ubuntu packages. The actual file name has the form
   ``when-command_VERSIONSPEC-N_all.deb`` where ``VERSIONSPEC`` is a version
   specification, and ``N`` is a number. Pros of this package are mostly that
   it blends with the rest of the operating environment and that the
   ``when-command`` command-line utility is available on the system path by
   default. Cons are that this setup may conflict with environments that are
   very different from Ubuntu.

2. ``when-command-opt``: this version installs **When** in
   ``/opt/when-command``, and should be suitable for ``.deb`` based
   distributions that differ from Ubuntu. The advantage of this method is that
   the applet is installed separately from the rest of the operating
   environment and does not clutter the host system. The main drawback is that
   the ``when-command`` utility is not in the system path by default and,
   unless the `PATH` variable is modified, it has to be invoked using the
   full path, that is as ``/opt/when-command/when-command``. The package file
   name has the form: ``when-command-opt-VERSIONSPEC.deb``.

To install a downloaded package, the command

::

  sudo dpkg --install when-command_VERSIONSPEC-N_all.deb

or

::

  sudo dpkg --install when-command-opt-VERSIONSPEC.deb

depending on the chosen version. After installation, each user who desires to
run **When** has to launch ``when-command --install`` (or
``/opt/when-command/when-command --install`` if the second method was chosen)
in order to find the applet icon in *Dash* and to be able to set it up as a
startup application (via the *Settings* dialog box). [#preferredinstall]_

.. Warning::
  The two package types are seen as different by *apt* and *dpkg*: this means
  that one package type will not be installed *over* the other. When switching
  package type, the old package *must* be uninstalled before. This also yields
  when upgrading from packages up to release *0.9.1*, however removal of user
  data and desktop shortcuts is not required. After a package type switch or
  an upgrade from release *0.9.1* or older, ``when-command --install`` should
  be invoked again, using the full path to the command if appropriate.


Install from the source
=======================

A source archive or a *Git* clone can be used to install the package in a
directory of choice, but some additional operations are required. However this
can be done almost mechanically. In the following example we will suppose that
the source has been downloaded in the form of a ``when-command-master.zip``
archive located in ``~/Downloads``, and that the user wants to install
**When** in ``~/Applications/When``. The required steps are the below:

::

  $ cd ~/Applications
  $ unzip ~/Downloads/when-command-master.zip
  $ mv when-command-master When
  $ cd When
  $ rm -Rf po temp scripts .git* setup.* MANIFEST.in share/icons
  $ chmod a+x share/when-command/when-command.py
  $ ln -s share/when-command/when-command.py when-command
  $ $HOME/Applications/When/when-command --install

The ``rm`` command is **not** mandatory: it is only required to remove files
that are not used by the installed applet and to avoid a cluttered setup.
Also, with this installation procedure, **When** can only be invoked from
the command line using the full path (``$HOME/Applications/When/when-command``
in the example): to use the ``when-command`` shortcut,
``$HOME/Applications/When`` has to be included in the `PATH` variable in
``.bashrc``. This means for instance that the creation of a `symbolic link` in
a directory already in the user path can cause malfunctions to **When** on
command line invocation.

This installation method is useful in several cases: it can be used for
testing purposes (it can supersede an existing installation, using the
``--install`` switch with the appropriate script), to run the applet directly
from a cloned repository or to restrict installation to a single user.


The ``--install`` switch
========================

**When** will try to recognize the way it has been set up the first time it's
invoked: the ``--install`` switch creates the desktop entries and icons for
each user that opts in to use the applet, as well as the required directories
that **When** needs to run correctly and an active autostart entry, that is:

* ``~/.config/when-command`` where it will store all configuration
* ``~/.local/share/when-command`` where it stores resources and logs (in
  the ``log`` subdirectory).

Please note that the full path to the command has to be used on the first run
if the ``/opt`` based package or the manual installation were chosen: in this
way **When** can recognize the installation type and set up the icons and
shortcuts properly.


Removal
=======

**When** can be uninstalled via ``apt-get remove when-command`` or
``apt-get remove when-command-opt`` if a package distribution was used, or
by deleting the newly created applet directory (``~/Applications/When`` in
the above example) if the source was unpacked from an archive or cloned from
*Git*. Also, user data and the desktop shortcut symbolic links should be
removed as follows:

::

  $ rm -f ~/.local/share/applications/when-command.desktop
  $ rm -f ~/.config/autostart/when-command-startup.desktop
  $ rm -f ~/.local/bin/when-command
  $ rm -Rf ~/.config/when-command
  $ rm -Rf ~/.local/share/when-command

Of course it has to be shut down before, for example by killing it via
``when-command --kill``.

.. Note::
  Removal of user data and desktop shortcuts is *not required* when switching
  package type or changing installation style, provided that the newly
  installed ``when-command`` is invoked with the ``--install`` switch before
  using the applet.


.. [#pyinotify] Package based installations depend on this: the installation
  fails if it is not installed.

.. [#preferredinstall] The first method is the preferred one, and it is
  the one usually referred to throughout the documentation: ``when-command``
  is considered to be in the path, and in the examples and instructions is
  invoked directly, omitting the full path prefix.
