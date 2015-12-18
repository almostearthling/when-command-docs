============
Introduction
============

**When** is a configurable user task scheduler for modern Gnome environments.
It interacts with the user through a GUI, where the user can define tasks and
conditions, as well as relationships of causality that bind conditions to
tasks.

This manual page briefly describes the *command line interface* of **When**
and the configuration file.


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


.. [#busevent] This is an advanced feature and is not available by default.
  It has to be enabled in the program settings to be accessible. Refer to the
  appropriate chapter for more information.
