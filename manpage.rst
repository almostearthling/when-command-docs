============
Introduction
============

**When** is a configurable user task scheduler for modern Gnome environments.
It interacts with the user through a GUI, where the user can define tasks and
conditions, as well as relationships of causality that bind conditions to
tasks.

This manual page briefly describes the *command line interface* of **When**,
the configuration file and *item definition files*. Please refer to

http://when-documentation.readthedocs.org/

for more detailed information.


Command Line Interface
======================

This paragraph illustrates the command line options that can be used to either
control the behaviour of a running **When** instance or to handle its
configuration or persistent state -- consisting of *tasks*, *conditions* and
*signal handlers*. Some of the options are especially useful to recover when
something has gone the wrong way -- such as the ``--show-settings`` switch
mentioned above, or the ``-I`` (or ``--show-icon``) switch, to recover from an
unwantedly hidden icon. There are also switches that grant access to "advanced"
features, which are better covered in the next sections.

The available options are:

-s, --show-settings       show the settings dialog box of an existing instance,
                          it requires a running instance, which may be queried
                          using the ``--query`` switch explained below
-l, --show-history        show the history dialog box of an existing instance
-t, --show-tasks          show the task dialog box of an existing instance
-c, --show-conditions     show the condition dialog box of an existing instance
-d, --show-signals        show the DBus signal handler editor box for an
                          existing instance [#busevent]_
-R, --reset-config        reset applet configuration to default, requires the
                          applet to be shut down with an appropriate switch
-I, --show-icon           show applet icon, the icon will be shown at the next
                          startup
-T, --install             install or reinstall application icon and autostart
                          icon, requires applet to be shut down with an
                          appropriate switch
-C, --clear               clear current tasks, conditions and possibly signal
                          handlers, requires applet to be shut down with an
                          appropriate switch
-Q, --query               query for an existing instance (returns a zero exit
                          status if an instance is running, nonzero otherwise,
                          and prints an human-readable message if the
                          ``--verbose`` switch is also specified)
-H file, --export-history file    export the current task history (the ones
                                  shown in the history box) to the file
                                  specified as argument in a CSV-like format
-r cond, --run-condition cond     trigger a command-line associated condition
                                  and immediately run the associated tasks;
                                  *cond* must be specified and has to be one of
                                  the *Command Line Trigger* conditions,
                                  otherwise the command will fail and no task
                                  will be run
-f cond, --defer-condition cond   schedule a command-line associated condition
                                  to run the associated tasks at the next clock
                                  tick; the same as above yields for *cond*
--shutdown                close a running instance performing shutdown tasks
                          first
--kill                    close a running instance abruptly, no shutdown tasks
                          are run
--item-add file           add items from a specially formatted file (see the
                          *advanced* section for details); if the specified
                          file is ``-`` the text is read from the standard
                          input
--item-del [type:]name    delete the named item from the ones that the applet
                          manages; ``type`` is one of ``tasks``, ``conditions``
                          and ``sighandlers`` (or an abbreviation thereof)
                          and can be omitted if the name is unique
--item-list [type]        print the list of currently managed items to the
                          console, each prefixed with its type; if type is
                          specified (same as above, abbreviations supported)
                          only such items are listed
--export file             save tasks, conditions and other items to a portable
                          format; the *file* argument is optional, and if not
                          specified the applet tries to save these items to a
                          default file in ``~/.config/when-command``; this will
                          especially be useful in cases where the compatibility
                          of the "running" versions of tasks and conditions
                          (which are a binary format) could be broken across
                          releases
--import file             clear tasks, conditions and other items and import
                          them from a previously saved file; the *file* argument
                          is optional, and if not specified the applet tries
                          to import these items from the default file in the
                          ``~/.config/when-command`` directory; the applet has
                          to be shut down before attempting to import items.

Some trivial switches are also available:

-h, --help                show a brief help message and exit
-V, --version             show applet version, if ``--verbose`` is specified
                          it also shows the *About Box* of a running instance,
                          if present
-v, --verbose             show output for some options; normally the applet
                          would not display any output to the terminal unless
                          ``-v`` is specified, the only exception being
                          ``--version`` that prints out the version string
                          anyway.

Please note that whenever a command line option is given, the applet will not
"stay resident" if there is no running instance. On the other side, if the user
invokes the applet when already running, the new instance will bail out with
an error.


Configuration
=============

The program settings are available through the specific *Settings* dialog box,
and can be manually set in the main configuration file, which can be found in
``~/.config/when-command/when-command.conf``.

The options are:

1. **General**

  * *Show Icon*: whether or not to show the indicator icon and menu
  * *Autostart*: set up the applet to run automatically at login
  * *Notifications*: whether or not to show notifications upon task failure
  * *Icon Theme*: *Guess* to let the application decide, otherwise one of
    *Dark* (light icons for dark themes), *Light* (dark icons for light
    themes), and *Color* for colored icons that should be visible on all
    themes.

2. **Scheduler**

  * *Application Clock Tick Time*: represents the tick frequency of the
    application clock, sort of a heartbeat, each tick verifies whether or not
    a condition has to be checked; this option is called ``tick seconds`` in
    the configuration file
  * *Condition Check Skip Time*: conditions that require some "effort" (mainly
    the ones that depend on an external command) will skip this amount of
    seconds from previous check to perform an actual test, should be at least
    the same as *Application Clock Tick Time*; this is named ``skip seconds``
    in the configuration file
  * *Preserve Pause Across Sessions*: if *true* (the default) the scheduler
    will remain paused upon applet restart if it was paused when the applet (or
    session) was closed. Please notice that the indicator icon gives feedback
    anyway about the paused/non-paused state. Use ``preserve pause`` in the
    configuration file.

3. **Advanced**

  * *Max Concurrent Tasks*: maximum number of tasks that can be run in a
    parallel run (``max threads`` in the configuration file)
  * *Log Level*: the amount of detail in the log file
  * *Max Log Size*: max size (in bytes) for the log file
  * *Number Of Log Backups*: number of backup log files (older ones are erased)
  * *Instance History Items*: max number of tasks in the event list (*History*
    window); this option is named ``max items`` in the configuration file
  * *Enable User Defined Events*: if set, then the user can define events
    using DBus *(see below)*. Please note that if there are any user defined
    events already present, this option remains set and will not be modifiable.
    It corresponds to ``user events`` in the configuration file. Also, to make
    this option effective and to enable user defined events in the
    *Conditions* dialog box, the applet must be restarted
  * *Enable File and Directory Notifications*: if set, **When** is configured
    to enable conditions based on file and directory changes. The option may
    result disabled if the required optional libraries are not installed. When
    the setting changes, the corresponding events and conditions are enabled
    or disabled at next startup.
  * *Enable Task and Condition Environment Variables*: whether or not to export
    specific environment variables with task and condition names when spawning
    subprocesses (either in *Tasks* or in *Command Based Conditions*). The
    configuration entry is ``environment vars``.

The configuration is *immediately stored upon confirmation* to the
configuration file, although some settings (such as *Notifications*,
*Icon Theme*, and most advanced settings) might require a restart of the
applet. The configuration file can be edited with a standard text editor, and
it follows some conventions common to most configuration files. The sections
in the file might slightly differ from the tabs in the *Settings* dialog, but
the entries are easily recognizable.

By default the applet creates a file with the following configuration, which
should be suitable for most setups:

::

  [Scheduler]
  tick seconds = 15
  skip seconds = 60
  preserve pause = true

  [General]
  show icon = true
  autostart = false
  notifications = true
  log level = warning
  icon theme = guess
  user events = false
  file notifications = false
  environment vars = true

  [Concurrency]
  max threads = 5

  [History]
  max items = 100
  log size = 1048576
  log backups = 4

Manual configuration can be particularly useful to bring back the program
icon once the user decided to hide it losing access to the menu,
by setting the ``show icon`` entry to ``true``. Another way to force access to
the *Settings* dialog box when the icon is hidden is to invoke the applet from
the command line using the ``--show-settings`` (or ``-s``) switch when an
instance is running.


Item Definition File
====================

With version *9.4.0-beta.1* a way has been introduced to define *items*
(*tasks*, *conditions* and especially *signal handlers*) using text files
whose syntax is similar (although it differs in some ways) to the one used
in common configuration files.

Item names are case sensitive and follow the same rules
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
  task runs. Must be either ``true`` or ``false``.
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


.. [#busevent] This is an advanced feature and is not available by default.
  It has to be enabled in the program settings to be accessible. Refer to the
  appropriate chapter for more information.
