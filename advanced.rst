=================
Advanced Features
=================

This chapter describes the advanced features of **When**. Some of these can be
handy for everyday use too, others may require some deeper insight in what
occurs under the hood in a desktop session. Anyway these features can be
enabled or disabled in the applet settings, and can be safely ignored if not
needed.


File and Directory Notifications
================================

Monitoring file and directory changes can be enabled in the *Settings* dialog
box. This is particularly useful to perform tasks such as file
synchronizations and backups, but since file monitoring can be resource
consuming, the option is disabled by default. File and directory monitoring
is quite basic in **When**: a condition can be triggered by changes either on
a file or on a directory, no filter can be specified for the change type --
that is, all change types are monitored (creations, writes and deeletions),
and in case of directory monitoring all files in the directory are recursively
monitored. These limitations are intentional, at least for the moment, in
order to keep the applet as simple as possible. Also, no more than either a
file or a directory can be monitored by a condition: in order to monitor more
items, multiple conditions must be specified.

As said above, this feature is optional, and in order to make it available
the ``pyinotify`` library has to be installed. On Ubuntu this can be achieved
via the package manager (``sudo apt-get install python3-pyinotify``);
alternatively ``pip`` can be used to let Python directly handle the
installation: ``sudo pip3 install pyinotify`` (this will ensure that the
latest release is installed, but package updates are left to the user).

There are also some configuration steps at system level that might have to be
performed if filesystem monitoring does not work properly: when a monitored
directory is big enough, the default *inotify watches* may fall short so that
not all file changes can be notified. When a directory is under control, all
its subdirectories need to be watched as well recursively, and this implies
that several watches are consumed. There are many sources of information on
how to increase the amount of *inotify watches*, and as usual StackExchange
is one of the most valuables: see `Kernel inotify watch limit reached`_ for a
detailed description. Consider that other applications and utilities,
especially the ones that synchronize files across the network -- such as the
cloud backup and synchronization clients -- use watches intensively. In fact
**When** monitoring activity should not be too different from other cases.

Conditions depending on file and directory monitoring are not synchronous,
and checks occur on the next tick of the applet clock. Depending tasks should
be aware that the triggering event might have occurred some time before the
notified file or directory change.

.. _`Kernel inotify watch limit reached`: http://unix.stackexchange.com/a/13757/125979


DBus Signal Handlers
====================

Recent versions of the applet support the possibility to define system and
session events using DBus_. Such events can activate conditions which in turn
trigger task sequences, just like any other condition. However, since this is
not a common use for the **When** scheduler as it assumes a good knowledge of
the DBus interprocess communication system and the related tools, this feature
is intentionally inaccessible from the applet menu and disabled by default in
the configuration. To access the *DBus Signal Handler Editor* dialog, the user
**must** invoke the applet from the command line with the appropriate switch,
while an instance is running in the same session:

::

  $ when-command --show-signals

This is actually the only way to expose this dialog box. Unless the user
defines one or more signal handlers, there will be no *User Defined Events*
in the corresponding box and pane in the *Conditions* dialog box, and
**When** will not listen to any other system and session events than the
ones available in the *Events* list that can be found in the *Conditions*
dialog box. The possibility to define such events must be enabled in the
*Settings* dialog box, and **When** has to be restarted to make the option
effective: before restart the user events are not available in the
*Conditions* box, although it becomes possible to show the
*DBus Signal Handler Editor* using the command shown above. If the
appropriate setting is disabled, the above command exits without showing the
editor dialog.

To define a signal to listen to, the following values must be specified in the
*DBus Signal Handler Editor* box:

* the handler name, free for the user to define as long as it begins with an
  alphanumeric character (letter or digit) followed by alphanumerics, dashes
  and underscores
* the bus type (either *Session* or *System* bus)
* the unique bus name in dotted form (e.g. ``org.freedesktop.DBus``)
* the path of the object that emits the signal (e.g.
  ``/org/freedesktop/FileManager1``)
* the interface name in dotted form (e.g. ``org.freedesktop.FileManager1``)
* the signal name
* whether the scheduler must wait until the next clock tick to process the
  signal (checking *Activate on next clock tick*)

All these values follow a precise syntax, which can be found in the DBus
documentation. Moreover, if the signal has any parameters, constraints on the
parameters can be specified for the condition to be verified: given a list of
constraints, the user can choose whether to require all of them or just any
to evaluate to true. The tests against signal parameters require the
following data:

* *Value #* is the parameter index
* *Sub #* (optional) is the index within the returned parameter, when it is
  either a list or a dictionary: in the latter case, the index is read as a
  string and must match a dictionary key
* *comparison* (consisting of an operator, possibly negated) specifies how
  the value is compared to a test value: the supported operators are

  1. `=` (equality): the operands are converted to the same type, and the
     test is successful when they are identical; please notice that, in case
     of boolean parameters, the only possible comparison is equality (and the
     related *not* equality): all other comparisons, if used, will evaluate
     to false and prevent condition activation, and the comparison value
     should be either `true` or `false`
  2. `CONTAINS`: the test evaluates to true when either the test string is a
     substring of the selected value, or the parameter is a list (or struct,
     or dictionary: for dictionaries it only searches for values and not for
     keys though), no *Sub #* has been specified, and the test value is in
     the compound value
  3. `MATCHES`: the test value is treated as a *regular expression* and the
     selected value, which must be a string, matches it
  4. `<`: the selected value is less than the test value (converted to the
     parameter selected value type)
  5. `>`: the selected value is greater than the test value (converted to
     the parameter selected value type)

* *Test Value* is the user provided value to compare the parameter value to:
  in most cases it is treated as being of the same type as the selected
  parameter value.

When all the needed fields for a tests are given, the test can be accepted by
clicking the *Update* button. To remove a test line, either specify *Value #*
and *Sub #* or select the line to delete, then click the *Remove* button.
Tests are optional: if no test is provided, the condition will be enqueued as
soon as the signal is emitted. If a test is specified in the wrong way, or a
comparison is impossible (e.g. comparing a returned list against a string),
or any error arises within a test, the test will evaluate to *false* and the
signal will not activate any associated condition. For now the tests are
pretty basic: for instance nested compound values (e.g. lists of lists) are
not treated by the testing algorithm. The supported parameter types are
booleans, strings, numerals, simple arrays, simple structures, and simple
dictionaries. Supporting more complex tests is beyond the scope of a limited
scheduler: the most common expected case for the DBus signal handler is to
catch events that either do not carry parameters or carry minimal information
anyway.

.. Note::
  When the system or session do not support a bus, path, interface, or signal,
  the signal handler registration fails: in this case the associated event
  never takes place and it is impossible for any associated condition to be
  ever verified.

.. _DBus: http://dbus.freedesktop.org/


Environment Variables
=====================

By default **When** defines one or two environment variables when it spawns
subprocesses, respectively in *command based conditions* and in *tasks*.
These variables are:

* ``WHEN_COMMAND_TASK`` containing the task name
* ``WHEN_COMMAND_CONDITION`` containing the name of the triggering or current
  condition

When the test subprocess of a command based condition is run, only
``WHEN_COMMAND_CONDITION`` is defined, on the other hand when a task is run
both are available. This feature can be disabled in the configuration file or
in the *Settings* dialog box if the user doesn't want to clutter the
environment or the variable names conflict with other ones. Please note that
in a *task* these variables are defined *only* if the task is set to import
the environment (which is true by default): if not, it will only know the
variables defined in the appropriate list. [#envonimport]_


.. [#envonimport] This behavior is intentional, since if the user chose not
  to import the surrounding environment, it means that it's expected to be as
  clean as possible.
