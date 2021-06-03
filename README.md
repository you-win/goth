# GOth Test Harness
A test harness written for Godot 3.3.2.

Supports unit tests and BDD tests. Fancy!

## Setup
Create a `tests/` folder in your project's root directory. Create a test script (e.g. `Test_Player.gd`). The test script must have `Test` as the first word, as GOTH will automatically scan and run these types of files. 

Add a test in your script (e.g. `func test_move_left()`). All tests must have `test` as the first word, as GOTH will automatically run all test functions in your test file.

### Editor
Drop the `goth/` folder into your project's `addons/` folder. If your project does not have an `addons/` folder at the project root, then create an empty folder called `addons/` in your project's root folder.

Inside of the editor, click on `Project` > `Project Settings` > `Plugins` and then enable the `GOTH` plugin. A new `GOTH` option should appear in the bottom bar. Click on the appropriate options in order to run tests.

### Standalone
Drop the `goth/` folder anywhere in your project. It is recommended to keep all addons in an `addon/` folder in your project's root folder.

Create a new `GOTH` object in your script and then call `run_unit_tests()` to run all unit tests.

## GOTH Class Documentation

### GOTH.gd
`log_message(message: String) -> void:`

Logs a message to either the Godot console or the GOTH console depending on whether or not GOTH is being run from the editor or from a script.

`scan() -> void:`

Rescans the `tests/` folder for additional test files. Called automatically when GOTH is first created.

`run_unit_tests(test_name: String = "") -> void:`

Runs all unit tests picked up by the `scan()` method. A specific test can be specified by passing the file name + extension of the test to be run.

`run_bdd_tests(test_name: String = "") -> void:`

Runs all BDD tests picked up by the `scan()` method. A specific test can be specified by passing the file name + extension of the test to be run.

