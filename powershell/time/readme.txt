Time
----

A cmdlet to measure execution time of a command.

Powershell lacks a timing utility like "time" in Linux. This is a small powershell script to do similar thing.

Usage
-----

1. When used without the "command" parameter, it'll print the execution time of the last command.

> Time
0.1417269 s (141.7269 ms)

2. Or, specify a command to be executed.
> Time -command "ls"
