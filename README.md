# Roc Fortune

A replacement for the fortune UNIX command in Roc.

## Usage

After cloning the repo, build the `fortune` binary.

```shell
mkdir -p bin
roc build --output=bin/fortune --optimize src/main.roc
```

Create a fortunes file in `$XDG_CONFIG_HOME/roc-fortune/fortunes.txt` or `$HOME/.config/roc-fortune/fortunes.txt` with a list of fortunes separated by new lines.

Run the fortune command to get a random fortune.

```shell
bin/fortune
```

Example output:

```text
❱ bin/fortune
Why do they call it oven when you of in the cold food of out hot eat the food?
```
