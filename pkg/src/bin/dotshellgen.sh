# shellcheck shell=bash

warn() {
	printf 'Warning: %s\n' "$1"
}

error() {
	printf 'Error: %s\n' "$1"
	exit 1
}

is_in_array() {
	local array_name="$1"
	local value="$2"

	local -n array="$array_name"

	local item=; for item in "${array[@]}"; do
		if [ "$item" = "$value" ]; then
			return 0
		fi
	done; unset item

	return 1
}

concat() {
	local file="$1"

	local file_name="${file##*/}"

	case "$file_name" in
	*.bash)
		local -n output_file='concatenated_bash_file'
		;;
	*.zsh)
		local -n output_file='concatenated_zsh_file'
		;;
	*.fish)
		local -n output_file='concatenated_fish_file'
		;;
	*.sh)
		local -n output_file='concatenated_sh_file'
		;;
	*)
		warn "Skipping '$file_name'"
		return
		;;
	esac

	{
		printf '# %s\n' "$file_name"
		cat "$file"
		printf '\n'
	} >> "$output_file"
}

main.dotshellgen() {
	bash-args parse -- "$@" <<-"EOF"
	@flag [help.h] - Show help menu
	@flag [clear] - Clear all generated files
	EOF

	if [ "${args[help]}" = 'yes' ]; then
		printf '%s\n' "$argsHelpText"
		return
	fi

	local dotshellgen_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/dotshellgen"
	local dotshellgen_state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotshellgen"
	mkdir -p "$dotshellgen_config_dir" "$dotshellgen_state_dir"

	local concatenated_bash_file="$dotshellgen_state_dir/concatenated.bash"
	local concatenated_zsh_file="$dotshellgen_state_dir/concatenated.zsh"
	local concatenated_fish_file="$dotshellgen_state_dir/concatenated.fish"
	local concatenated_sh_file="$dotshellgen_state_dir/concatenated.sh"

	# TODO: this can just be a yes, return under the `> "$file" :` below
	if [ "${args[clear]}" = yes ]; then
		rm -f "$concatenated_bash_file" "$concatenated_zsh_file" "$concatenated_fish_file" "$concatenated_sh_file"
		return
	fi

	# Nuke all concatenated files
	> "$concatenated_bash_file" :
	> "$concatenated_zsh_file" :
	> "$concatenated_fish_file" :
	> "$concatenated_sh_file" :

	declare -a pre=() post=() disabled=()
	source "$dotshellgen_config_dir/config.sh"

	for dirname in "${pre[@]}"; do
		for file in "$dotshellgen_config_dir/$dirname"/*; do
			concat "$file"
		done; unset file
	done; unset dirname

	for dir in "$dotshellgen_config_dir"/*/; do
		local dirname="${dir%/}"; dirname="${dirname##*/}"

		if is_in_array 'pre' "$dirname"; then
			continue
		fi
		if is_in_array 'post' "$dirname"; then
			continue
		fi

		if is_in_array 'disabled' "$dirname"; then
			continue
		fi

		for file in "$dir"/*; do
			concat "$file"
		done; unset file
	done; unset dir

	for dirname in "${post[@]}"; do
		for file in "$dotshellgen_config_dir/$dirname"/*; do
			concat "$file"
		done; unset file
	done; unset dirname
}
