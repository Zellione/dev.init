# run.sh — macOS/Linux setup script executor (library only).
# Source via macos-run.sh or linux-run.sh; do not execute directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: source this file, do not execute it directly." >&2
    return 1 2>/dev/null || exit 1
fi

if [ -z "${DEV_ENV:-}" ]; then
    echo "Error: DEV_ENV must be set before sourcing run.sh" >&2
    return 1 2>/dev/null || exit 1
fi

source "$(dirname "${BASH_SOURCE[0]}")/tags.sh"

export DRY_RUN="${DRY_RUN:-0}"

log() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

# Called by wrapper after sourcing.
# Usage: run_scripts "<grep-pattern>"
run_scripts() {
    local grep_pattern="${1:-}"
    local scripts_dir="${DEV_ENV%/}/runs"

    log "RUN: env: ${DEV_ENV} -- pattern: ${grep_pattern}"

    if [[ ! -d "${scripts_dir}" ]]; then
        log "No setup scripts found at ${scripts_dir} — nothing to do."
        return 0
    fi

    local scripts=() i="" s="" local_basename="" item_tags=""
    if [[ "${DEV_ENV}" == *"macos"* ]]; then
        mapfile -t scripts < <(find "$scripts_dir" -mindepth 1 -maxdepth 1 -type f -executable | sort)
    else
        mapfile -t scripts < <(find "$scripts_dir" -mindepth 1 -maxdepth 1 -type f \( -executable -o -perm /111 \) | sort)
    fi

    if [[ ${#scripts[@]} -eq 0 ]]; then
        log "No executable scripts found in ${scripts_dir}."
        return 0
    fi

    for s in "${scripts[@]}"; do
        # Filter by optional grep pattern (basename match)
        if [[ -n "$grep_pattern" ]]; then
            local_basename=$(basename "$s")
            if echo "$local_basename" | grep -qi "$grep_pattern"; then
                :
            else
                log "filtered out (pattern '${grep_pattern}'): ${local_basename}"
                continue
            fi
        fi

        # Tag filter
        item_tags=$(_read_item_tags "$s")
        if ! _matches_tags "$item_tags"; then
            log "filtered (tags: ${item_tags:-none}): $(basename "$s")"
            continue
        fi

        log "running script: $s"
        if [[ "${DRY_RUN:-0}" == "0" ]]; then bash "$s"; fi
    done

    log "run.sh complete."
}
