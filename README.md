# dotshellgen

STATUS: Working, but no documentation

Improve dotfile maintainability

If you have a lot of dotfiles and switch between multiple shells often, it can be difficult to organize your dotfiles correctly. dotshellgen solves this by allowing you to categorize dotfiles for all shells of particular project (ex. `direnv`, `rbenv`, `nvm`) in a single directory. dotshellgen will concatenate all files for a particular project into a single file so there is no "overhead" of multiple sources and stat'ing directories to filter for '*.{sh,bash}' files

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/dotshellgen
```

## Usage

This reads configuration from `"$XDG_CONFIG_HOME/dotshellgen"` and generates it in `"$XDG_STATE_HOME/dotshellgen"`

```sh
dotshellgen
```

## Examples

The author's sample configuration is [here](https://github.com/hyperupcall/dots/tree/main/user/.config/dotshellgen), with the generated results located [here](https://github.com/hyperupcall/dots/blob/main/user/.local/state/dotshellgen/concatenated.bash)
