# Security Policy

## Supported Versions

Exponential Platform Legacy has four maintained release lines. Security fixes are made on their branches and
published with the next release of the line.

| Release line | Branch | Supported          |
| ------------ | ------ | ------------------ |
| 2.5.0.x      | master | :white_check_mark: |
| 3.3.44.x     | 3.x    | :white_check_mark: |
| 4.6.23.x     | 4.6.x  | :white_check_mark: |
| 5.0.x        | 5.x    | :white_check_mark: |
| 3.0.0.x, 1.x and older upstream branches | | :x: |

The legacy kernel inside every line is Exponential 6.0 (`se7enxweb/exponential`); report issues in it to the same
address. Hardening advice for each line is in
[chapter 13 of the book](doc/book/13-security-hardening.md).

## Reporting a Vulnerability

Please report security issues privately by e-mail to security@se7enx.com, not in the public issue tracker or the
discussions. You can expect a first answer within one business day.

Include the release line and version (`composer show se7enxweb/exponential-platform-legacy se7enxweb/legacy-bridge
se7enxweb/exponential`), what an attacker can do, and the steps to reproduce it. Leave out passwords, secrets and
personal data.

You will be told whether the report is accepted or declined, and kept informed while a fix is prepared.
