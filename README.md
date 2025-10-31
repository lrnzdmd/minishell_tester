# README - Minishell Tester

This script (`minitester.sh`) is a test harness for `minishell`. Its purpose is to validate your shell's behavior by comparing its output, exit codes, standard error, and created files against `bash`.

---

## Installation and Structure

1.  Navigate to your main `minishell` project directory (the one containing your `Makefile` and executable).
2.  Clone this repository into a subdirectory (e.g., `tester`):
    `git clone git@github.com:lrnzdmd/minishell_tester.git tester`
3.  Make the script executable:
    `chmod +x tester/minitester.sh`

The final project structure required by the script will be as follows:

```
minishell/          <-- Your project root
├── minishell       <-- Your executable
├── Makefile
├── ... (your .c and .h files)
│
└── tester/         <-- This cloned repository
    ├── minitester.sh
    ├── test_cases/
    │   └── ...
    └── test_files/
        └── ...
```

The script (`minitester.sh`) expects to find the `minishell` executable in its parent directory (`../minishell`).

---

## Critical Prerequisite: Non-Interactive Input Handling

To function, this tester must send commands to your `minishell` via a pipe.

The operation performed is as follows:
`echo "ls -l | wc -l" | ../minishell`

When input comes from a pipe, `minishell`'s standard input is not connected to a terminal (TTY). As a result:
1.  The `isatty(STDIN_FILENO)` function will return `0` (false).
2.  The `readline()` function is not designed for this mode and will not work correctly (it may hang or fail).

### Required Solution

It is imperative that your `minishell` handles this distinction. It must detect whether the input is interactive or not and select the appropriate reading method.

When `isatty(STDIN_FILENO)` is false, the shell must read commands from standard input (file descriptor `0`) using an alternative function, such as `get_next_line` or a `read` loop.

```c
/* Example input handling logic */

#include <unistd.h> // For isatty

// ...
while (1)
{
    // ...

    if (isatty(STDIN_FILENO))
    {
        // 1. INTERACTIVE MODE (Terminal)
        // Print the prompt and use readline.
        refresh_prompt(data);
        input = readline("minishell$ ");
    }
    else
    {
        // 2. NON-INTERACTIVE MODE (Pipe)
        // Do not print a prompt. Read from STDIN with get_next_line.
        input = ft_get_next_line(0);
    }

    // ...
}
```

Failure to implement this logic will prevent the tester from communicating with `minishell`, causing all tests to fail.

---

## Usage

Run the script from its own directory:

`cd tester`
`./minitester.sh`

### Options

* `./minitester.sh`
    **Standard Mode**. Runs all tests. Displays full details only for failed tests. Passed tests are indicated by a single confirmation line.

* `./minitester.sh -v` (o `--verbose`)
    **Verbose Mode**. Displays full details (Output, Exit Code, Stderr) for *all* tests, including passed ones.

* `./minitester.sh -h` (o `--help`)
    Displays a help message summarizing the options.

---
lde-medi 42 Madrid