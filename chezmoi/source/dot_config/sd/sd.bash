# sd shell integration

# Preview changes without modifying files.
sdp() {
    command sd --preview "$@"
}

# Literal find and replace without regex.
sdf() {
    command sd --fixed-strings "$@"
}

# Replace across regular files found by fd.
sdall() {
    if (( $# < 2 )); then
        printf 'Usage: sdall <find> <replace> [path ...]\n' >&2
        return 2
    fi

    local find="$1"
    local replace="$2"
    shift 2

    if (( $# )); then
        command fd --type f . "$@" --exec sd "$find" "$replace"
    else
        command fd --type f --exec sd "$find" "$replace"
    fi
}
