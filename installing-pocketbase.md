# Installing PocketBase

**Outcome: a `pocketbase` program on
your machine that states its version —
before any data enters the picture.**
Installing here means downloading one
file and unzipping it; there is no
package manager step and nothing is
written outside the folder you choose.

## The release download

PocketBase is published on the project's
GitHub releases page
(`github.com/pocketbase/pocketbase`).
Each release offers one zip per
platform, named by the pattern
`pocketbase_<version>_linux_amd64.zip` —
match the three variable parts to your
machine: the version, the operating
system (`linux`, `darwin` for macOS,
`windows`), and the processor family
(`amd64` for ordinary 64-bit PCs, `arm64`
for newer Raspberry Pi boards and ARM
servers). The lab installed **0.40.6**,
and its download is in transcript `t00`:

```bash
curl -L -o pocketbase.zip \
  https://github.com/pocketbase/pocketbase/releases/download/v0.40.6/pocketbase_0.40.6_linux_amd64.zip
unzip pocketbase.zip
```

The zip holds three files:

```text
pocketbase        the program (about 34 MB)
CHANGELOG.md      what changed, release by release
LICENSE.md        the MIT licence text
```

Check what you fetched before running
it: a wrong platform name earns you a
small file containing an error message
instead of a program, and `ls -la` plus
the version check below expose that at
once. The lab's zip was about 13 MB and
the program inside it about 34 MB.

Nothing in the zip installs into the
system. The program carries its database
engine and its web server inside itself,
creates its `pb_data` folder beside
wherever it runs, and can be removed by
deleting the folder you unzipped into.
Work in a folder of your own for the
rest of the guide — the lab used
`pocketbase-labwork/` — because that
folder will accumulate the binary, its
data, and your hook files as one unit
you can copy or delete whole.

## The check

```bash
./pocketbase --version
```

```text
pocketbase version 0.40.6
```

That line is the whole acceptance test
for this chapter. `--help` is worth one
look now: it lists the four commands
(`serve`, `superuser`, `migrate`,
`update`) and the flags that say where
things live — `--dir` (default
`pb_data`), `--hooksDir`, `--publicDir`.
Chapter 2 mapped those parts; chapters 4
and 10 use the first three commands.

## Keeping it current

`./pocketbase update` downloads the
newest release and replaces the binary
in place. It does not touch `pb_data`:
your data's layout is migrated by the
program itself when a newer version
first opens an older folder (the
`--automigrate` behaviour, on by
default, and the subject of chapter 10).
The lab did not run an update — it
installed the then-current release
directly — so treat `update` as
documented-only here, and take a folder
copy before using it anywhere that
matters. Copying the folder *is* the
backup; chapter 11 shows the built-in
way as well.

## The other ways in

PocketBase can also be run from a Docker
image and used as a Go library — embedded
in your own Go program rather than run
as a file of its own. Both are real and
both are documented-only in this guide:
the lab verified the release binary
only, and every command that follows is
the binary's. If you later outgrow the
binary, the same `pb_data` folder and the
same API carry over; nothing you learn
here is thrown away.
