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


Item Definition File
====================

With version *9.4.0-beta.1* a way has been introduced to define *items*
(*tasks*, *conditions* and especially *signal handlers*) using text files
whose syntax is similar (although it differs in some ways) to the one used
in common configuration files. Roughly, an *item definition* file has the
following format:

::

  [NameOf_Task-01]
  type: task
  command: do_something
  environment variables:
    SOME_VAR=some appropriate value
    ANOTHER_VAR=42
  check for: failure, status, 2

  [ThisIs_Cond02]
  type: condition
  based on: file_change
  watched path: ~/Documents
  tasks: NameOf_Task-01

  [SigHandler_03]
  type: signal_handler
  bus: session
  bus name: org.ayatana.bamf
  object path: /org/ayatana/bamf/matcher
  interface: org.ayatana.bamf.matcher
  signal: RunningApplicationsChanged
  parameters:
    0:1, not equal, BoZo

  # this is the end of the file.

where the names in square brackets are item names, as they appear in the
applet dialog boxes. Such names are case sensitive and follow the same rules
as the related *Name* entries in dialog boxes: only names that begin with an
alphanumeric character and continue with *alphanumerics*, *underscores* and
*dashes* (that is, no spaces) are accepted. Entries must be followed by
colons and in case of entries that support lists the lists must be indented
and span multiple lines. Complex values are rendered using commas to separate
sub-values. The value for each entry is considered to be the string beginning
with the first non-blank character after the colon.

.. Warning::
  Even a single error, be it syntactical or due to other possibly more
  complex discrepancies, will cause the entire file to be rejected. The
  loading applet will complain with an error status and, if invoked using
  the ``--verbose`` switch, a very brief error message: the actual cause
  of rejection can normally be found in the log files.

For each item, the item name must be enclosed in square brackets, followed
by the entries that define it. An entry that is common to all items is
``type``: the type must be one of ``task``, ``condition`` or
``signal_handler``. Every other value will be discarded and invalidate
the file. The following sections describe the remaining entries that can
(or have to) be used in item definitions, for each item type. Entry names
must be written in their entirety: abbreviations are not accepted.

Tasks
-----

Tasks are defined by the following entries. Some are mandatory and others
are optional: for the optional ones, if omitted, default values are used.
Consider that all entries correspond to entries or fields in the
*Task Definition Dialog Box* and the corresponding default values are the
values that the dialog box shows by default.

* ``command``:
  The value indicates the full command line to be executed when the task
  is run, it can contain every legal character for a shell command.
  *This entry is mandatory:* omission invalidates the file.
* ``environment variables``:
  A multi-value entry that includes a variable definition on each line.
  Each definition has the form ``VARNAME=value``, must be indented and
  the value *must not* contain quotes. Everything after the equal sign
  is considered part of the value, including spaces. Each line defines
  a single variable.
* ``import environment``:
  Decide whether or not to import environment for the command that the
  task runs. Must be either ``true`` or ``false``. Defaults to *true*.
* ``startup directory``:
  Set the *startup directory* for the task to be run. It should be a valid
  directory.
* ``check for``:
  The value of this entry consists either of the word ``nothing`` or of a
  comma-separated list of three values, that is ``outcome, source, value``
  where

  - ``outcome`` is either ``success`` or ``failure``
  - ``source`` is one of ``status``, ``stdout`` or ``stderr``
  - ``value`` is a free form string (it can also contain commas), which
    should be compatible with the value chosen for ``source`` -- this
    means that in case ``status`` is chosen it should be a number.

  By default, as in the corresponding dialog box, if this entry is omitted
  the task will check for success as an exit status of ``0``.
* ``exact match``:
  Can be either ``true`` or false. If ``true`` in the post-execution check
  the entire *stdout* or *stderr* will be checked against the *value*,
  otherwise the value will be sought in the command output. By default it
  is *false*. It is only taken into account if ``check for`` is specified
  and set to either *stdout* or *stderr*.
* ``regexp match``:
  If ``true`` the value will be treated as a *regular expression*. If also
  ``exact match`` is set, then the regular expression is matched at the
  beginning of the output. By default it is *false*. It is only taken into
  account if ``check for`` is specified and set to either *stdout* or
  *stderr*.
* ``case sensitive``:
  If ``true`` the comparison will be made in a case sensitive fashion. By
  default it is *false*. It is only taken into account if ``check for``
  is specified and set to either *stdout* or *stderr*.

Signal Handlers
---------------

Signal handlers are an advanced feature, and cannot be defined if they are
not enabled in the configuration: read the appropriate section on how to
enable *user defined events*. If user events are enabled, the following
entries can be used:

* ``bus``:
  This value can only be one of ``session`` or ``system``. It defaults to
  *session*, so it has to be specified if the actual bus is not in the
  *session bus*.
* ``bus name``:
  Must hold the *unique bus name* in dotted form, and is *mandatory*.
* ``object path``:
  The path to the objects that can issue the signal to be caught: has a
  form similar to a *path* and is *mandatory*.
* ``interface``:
  It is the name of the object interface, in dotted form. *Mandatory.*
* ``signal``:
  The name of the signal to listen to. This too is *mandatory*.
* ``defer``:
  If set to ``true``, the signal will be caught but the related condition
  will be fired at the next clock tick instead of immediately.
* ``parameters``:
  This is a multiple line entry, and each parameter check must be specified
  on a single line. Each check has the form: ``idx[:sub], compare, value``
  where

  - ``idx[:sub]`` is the parameter index per *DBus* specification, possibly
    followed by a subindex in case the parameter is a collection. ``idx``
    is always an integer number, while ``sub`` is an integer if the
    collection is a list, or a string if the collection is a dictionary. The
    interpunction sign is a colon if the subindex is present.
  - ``compare`` is always one of the following tokens: ``equal``, ``gt``,
    ``lt``, ``matches`` or ``contains``. It can be preceded by the word
    ``not`` to negate the comparison.
  - ``value`` is an arbitrary string (it can also contain commas), without
    quotes.

* ``verify``:
  Can be either ``all`` or ``any``. If set to ``any`` (the default) the
  parameter check evaluates to *true* if any of the provided checks is
  positive, if set to ``all`` the check is *true* only if all parameter
  checks are verified. It is only taken into account if ``parameters``
  are verified.

If user events are not enabled and a signal handler is defined, the item
definition file will be invalidated.

Conditions
----------

*Conditions* are the most complex type of items that can be defined, because
of the many types that are supported. Valid entries depend on the type of
condition that the file defines. Moreover, *conditions* depend on other items
(*tasks* and possibly *signal handlers*) and if such dependencies are not
satisfied the related condition -- and with it the entire file -- will be
considered invalid.

The following entries are common to all types of condition:

* ``based on``:
  Determines the type of condition that is being defined. It *must* be one
  of the following and is *mandatory*:

  - ``interval`` for conditions based on time intervals
  - ``time`` for conditions that depend on a time specification
  - ``command`` if the condition depends on outcome of a command
  - ``idle_session`` for condition that arise when the session is idle
  - ``event`` for conditions based on *stock* events
  - ``file_change`` when file or directory changes trigger the condition
  - ``user_event`` for conditions arising on user defined events: these
    can only be used if user events are enable, otherwise the definition
    file is considered *invalid*.

  Any other value will invalidate the definition file.
* ``task names``:
  A comma separated list of tasks that are executed when the condition fires
  up. The names *must* be defined, either in the set of existing tasks for
  the running instance, or among the tasks defined in the file itself.
* ``repeat checks``:
  If set to ``false`` the condition is never re-checked once it was found
  positive. By default it is *true*.
* ``sequential``:
  If set to ``true`` the corresponding tasks are run in sequence, otherwise
  all tasks will start at the same time. *True* by default.
* ``suspended``:
  The condition will be suspended immediately after construction if this is
  *true*. *False* by default.
* ``break on``:
  Can be one of ``success``, ``failure`` or ``nothing``. In the first case
  the task sequence will break on first success, in the second case it will
  break on the first failure. When ``nothing`` is specified or the entry is
  omitted, then the task sequence will be executed regardless of task
  outcomes.

Other entries depend on the values assigned to the ``based on`` entry.

Interval
^^^^^^^^

Interval based conditions require the following entry to be defined:

* ``interval minutes``:
  An integer *mandatory* value that defines the number of minutes that
  will occur between checks, or before the first check if the condition
  is not set to repeat.

Time
^^^^

All parameters are optional: if none is given, the condition will fire up
every day at midnight.

* ``year``:
  Integer value for the year.
* ``month``:
  Integer value for month: must be between 1 and 12 included.
* ``day``:
  Integer value for day: must be between 1 and 31 included.
* ``hour``:
  Integer value for hour: must be between 0 and 23 included.
* ``minute``:
  Integer value for minute: must be between 0 and 59 included.
* ``day of week``:
  A token, one of ``monday``, ``tuesday``, ``wednesday``, ``thursday``,
  ``friday``, ``saturday``, ``sunday``. No abbreviations allowed.

Command
^^^^^^^

Command based conditions accept a command line and the specification of
what has to be checked. The latter is not mandatory, and defaults to
expectation of a zero exit status.

* ``command``:
  The full command line to run: this is *mandatory*.
* ``check for``:
  Somewhat similar to the same entry found in Tasks_, this entry must be
  specified as a comma-separated pair of the form ``source, value``, where
  ``source`` is one of ``status``, ``stdout`` or ``stderr``, and ``value``
  is an integer in the ``status`` case, or a string to look for in the
  other cases. Defaults to ``status, 0``.
* ``match regexp``:
  If ``true`` the test value is treated as a *regular expression*. Defaults
  to ``false``.
* ``exact match``:
  If ``true`` the test value is checked against the full output (if
  ``match regexp`` is ``true`` the regular expression is matched at the
  beginning of the output). Defaults to ``false``.
* ``case sensitive``:
  If ``true`` the comparison will be case sensitive. Defaults to ``false``.

Idle Session
^^^^^^^^^^^^

The only parameter is mandatory:

* ``idle minutes``:
  An integer value indicating the number of minutes that the machine must
  wait in idle state before the condition fires.

Event
^^^^^

This condition type requires a sigle entry to be defined.

* ``event type``:
  This *must* be one of the following words:

  - ``startup``
  - ``shutdown``
  - ``suspend``
  - ``resume``
  - ``connect_storage``
  - ``disconnect_storage``
  - ``join_network``
  - ``leave_network``
  - ``screensaver``
  - ``exit_screensaver``
  - ``lock``
  - ``unlock``
  - ``charging``
  - ``discharging``
  - ``battery_low``
  - ``command_line``

Each of them is a single word with underscores for spaces. Abbreviations
are not accepted. Any other value invalidates the condition and the file.

File and Path Modifications
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Also in this case a single entry is required, indicating the file or path
that **When** must observe.

* ``watched path``:
  A path to be watched. Can be either the path to a file or to a directory.
  No trailing slash is required.

User Event
^^^^^^^^^^

In this case a single entry is required and must contain the *name* of an
user defined event. The event can either be defined in the same file or
already known to the applet, but it *must* be defined otherwise the file
fails to load. Names, as usual, are case sensitive.

* ``event name``:
  The name of the user defined event.

.. Note::
  Items defined in an *items definition file*, just as items built using
  the applet GUI, will overwrite items of the same type and name.


Exporting and Importing Items
=============================

**When** saves *tasks*, *conditions* and *signal handlers* in binary form
for use across sessions. It might be useful to have a more portable format
at hand to store these items and be sure, for instance, that they will be
loaded correctly when upgrading **When** to a newer release. While every
effort will be made to avoid incompatibilities, there might be cases where
compatibility cannot be kept.

To export all items to a file, the following command can be used:

::

  $ when-command --export [filename.dump]

where the file argument is optional. If given, all items will be saved
to the specified file, otherwise in a known location in ``.config``. The
saved file is not intended to be edited by the user -- it uses a JSON
representation of the internal objects.

To import items back to the applet, it has to be shut down first and the
following command must be run:

::

  $ when-command --import [filename.dump]

where the ``filename.dump`` parameter must correspond to a file previously
generated using the ``--export`` switch. If no argument is given, **When**
expects that items have been exported giving no file specification to the
``--export`` switch. After import **When** can be restarted.


.. [#envonimport] This behavior is intentional, since if the user chose not
  to import the surrounding environment, it means that it's expected to be as
  clean as possible.
