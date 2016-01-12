=====================
Credits and Resources
=====================

Open Source Software relies on collaboration, and I'm more than happy to
receive help from other developers. Here I'll list the main contributions.

* Adolfo Jayme-Barrientos, aka fitojb_ for the Spanish translation

Also, I'd like to thank everyone who contributes to the development of
**When** by commenting, filing bugs, suggesting features and testing.
Every kind of help is welcome.

The top panel icons and the emblems used in the application were selected
within Google's `Material Design`_ icon collection.

The application icon_ has been created by Rafi at GraphicsFuel_.

.. _fitojb: https://github.com/fitojb

.. _`Material Design`: https://materialdesignicons.com/
.. _icon: http://www.graphicsfuel.com/2012/08/alarm-clock-icon-psd/
.. _GraphicsFuel: http://www.graphicsfuel.com/


Resources
=========

As said above, this software is designed to run mainly on Ubuntu and the
chosen framework is *Python 3.x* with *PyGObject* (*GTK 3.0*); the interface is
developed using the *Glade* interface designer. The resources I found useful
are:

* `Python 3.x Documentation`_
* `PyGTK 3.x Tutorial`_
* `PyGTK 2.x Documentation`_
* `PyGObject Documentation`_
* `GTK 3.0 Documentation`_
* `DBus Documentation`_
* `pyinotify Documentation`_

The guidelines specified in UnityLaunchersAndDesktopFiles_ have been roughly
followed to create the launcher from within the application.

Many hints and valuable information have been found on StackOverflow_ and the
other sites in the StackExchange_ network.


.. _`Python 3.x Documentation`: https://docs.python.org/3/
.. _`PyGTK 3.x Tutorial`: http://python-gtk-3-tutorial.readthedocs.org/en/latest/index.html
.. _`PyGTK 2.x Documentation`: https://developer.gnome.org/pygtk/stable/
.. _`PyGObject Documentation`: https://developer.gnome.org/pygobject/stable/
.. _`GTK 3.0 Documentation`: http://lazka.github.io/pgi-docs/Gtk-3.0/index.html
.. _`DBus Documentation`: http://www.freedesktop.org/wiki/Software/dbus/
.. _`pyinotify Documentation`: https://github.com/seb-m/pyinotify/wiki
.. _UnityLaunchersAndDesktopFiles: https://help.ubuntu.com/community/UnityLaunchersAndDesktopFiles
.. _StackOverflow: http://stackoverflow.com/
.. _StackExchange: http://stackexchange.com/


Bugs and Errors
===============

**When** is hosted on GitHub_: the repository contains the most recent stable
code as well as developement and feature branches. The *master* branch might
include more recent code with respect to the packaged distributions. The
repository_ for **When** also gives access to the bug tracking system, in the
form of the *Issues* mechanism. *Issues* can be used to provide information
on bugs or features that could make **When** more useful.

Before filing an *issue* please consider that

* in the case of a bug some data are needed:

  - **When** version
  - Linux distribution and complete version
  - Python 3.x detailed version
  - How **When** was installed (which package, or how source was obtained)
  - Steps to reproduce the problem.

  Before filing a bug please verify that there is no open equivalent issue,
  or that the issue is not a particular case of an already open one.

* for a feature request the following should be taken into account:

  - whether or not it would make the applet more useful or usable
  - if the feature being requested is just a shortcut for something that
    can already be done via configuration (for instance, adding an event
    that could be provided using a *signal handler*)
  - how it would impact on **When** in terms of weight and responsiveness
  - the impact that it would have on backward compatibility.

  Consider that **When** should try to remain as small as possible, it
  already eats up around 20MBytes as it is: most effort in its development
  should go towards simplification and extendability via external tools.

The repository_ is also the starting point for other forms of contributions.
There is a separate_ documentation for contributors, that tries to cover
most possible areas.


.. _GitHub: https://github.com/
.. _repository: https://github.com/almostearthling/when-command
.. _separate: http://contributing-to-when.readthedocs.org/
