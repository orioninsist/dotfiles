_ast__grep() {
    local i cur prev opts cmd
    COMPREPLY=()
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        cur="$2"
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi
    prev="$3"
    cmd=""
    opts=""

    for i in "${COMP_WORDS[@]:0:COMP_CWORD}"
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="ast__grep"
                ;;
            ast__grep,completions)
                cmd="ast__grep__subcmd__completions"
                ;;
            ast__grep,help)
                cmd="ast__grep__subcmd__help"
                ;;
            ast__grep,lsp)
                cmd="ast__grep__subcmd__lsp"
                ;;
            ast__grep,new)
                cmd="ast__grep__subcmd__new"
                ;;
            ast__grep,outline)
                cmd="ast__grep__subcmd__outline"
                ;;
            ast__grep,run)
                cmd="ast__grep__subcmd__run"
                ;;
            ast__grep,scan)
                cmd="ast__grep__subcmd__scan"
                ;;
            ast__grep,test)
                cmd="ast__grep__subcmd__test"
                ;;
            ast__grep__subcmd__help,completions)
                cmd="ast__grep__subcmd__help__subcmd__completions"
                ;;
            ast__grep__subcmd__help,help)
                cmd="ast__grep__subcmd__help__subcmd__help"
                ;;
            ast__grep__subcmd__help,lsp)
                cmd="ast__grep__subcmd__help__subcmd__lsp"
                ;;
            ast__grep__subcmd__help,new)
                cmd="ast__grep__subcmd__help__subcmd__new"
                ;;
            ast__grep__subcmd__help,outline)
                cmd="ast__grep__subcmd__help__subcmd__outline"
                ;;
            ast__grep__subcmd__help,run)
                cmd="ast__grep__subcmd__help__subcmd__run"
                ;;
            ast__grep__subcmd__help,scan)
                cmd="ast__grep__subcmd__help__subcmd__scan"
                ;;
            ast__grep__subcmd__help,test)
                cmd="ast__grep__subcmd__help__subcmd__test"
                ;;
            ast__grep__subcmd__help__subcmd__new,project)
                cmd="ast__grep__subcmd__help__subcmd__new__subcmd__project"
                ;;
            ast__grep__subcmd__help__subcmd__new,rule)
                cmd="ast__grep__subcmd__help__subcmd__new__subcmd__rule"
                ;;
            ast__grep__subcmd__help__subcmd__new,test)
                cmd="ast__grep__subcmd__help__subcmd__new__subcmd__test"
                ;;
            ast__grep__subcmd__help__subcmd__new,util)
                cmd="ast__grep__subcmd__help__subcmd__new__subcmd__util"
                ;;
            ast__grep__subcmd__new,help)
                cmd="ast__grep__subcmd__new__subcmd__help"
                ;;
            ast__grep__subcmd__new,project)
                cmd="ast__grep__subcmd__new__subcmd__project"
                ;;
            ast__grep__subcmd__new,rule)
                cmd="ast__grep__subcmd__new__subcmd__rule"
                ;;
            ast__grep__subcmd__new,test)
                cmd="ast__grep__subcmd__new__subcmd__test"
                ;;
            ast__grep__subcmd__new,util)
                cmd="ast__grep__subcmd__new__subcmd__util"
                ;;
            ast__grep__subcmd__new__subcmd__help,help)
                cmd="ast__grep__subcmd__new__subcmd__help__subcmd__help"
                ;;
            ast__grep__subcmd__new__subcmd__help,project)
                cmd="ast__grep__subcmd__new__subcmd__help__subcmd__project"
                ;;
            ast__grep__subcmd__new__subcmd__help,rule)
                cmd="ast__grep__subcmd__new__subcmd__help__subcmd__rule"
                ;;
            ast__grep__subcmd__new__subcmd__help,test)
                cmd="ast__grep__subcmd__new__subcmd__help__subcmd__test"
                ;;
            ast__grep__subcmd__new__subcmd__help,util)
                cmd="ast__grep__subcmd__new__subcmd__help__subcmd__util"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        ast__grep)
            opts="-c -h -V --config --help --version run scan test new lsp outline completions help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__completions)
            opts="-c -h --config --help bash elvish fish powershell zsh"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help)
            opts="run scan test new lsp outline completions help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__completions)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__lsp)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__new)
            opts="project rule test util"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__new__subcmd__project)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__new__subcmd__rule)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__new__subcmd__test)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__new__subcmd__util)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__outline)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__run)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__scan)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__help__subcmd__test)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__lsp)
            opts="-c -h --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new)
            opts="-l -y -c -h --lang --yes --config --help project rule test util help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__help)
            opts="project rule test util help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__help__subcmd__project)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__help__subcmd__rule)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__help__subcmd__test)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__help__subcmd__util)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__project)
            opts="-l -y -c -h --lang --yes --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__rule)
            opts="-l -y -c -h --lang --yes --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__test)
            opts="-l -y -c -h --lang --yes --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__new__subcmd__util)
            opts="-l -y -c -h --lang --yes --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__outline)
            opts="-l -j -c -h --lang --json --color --items --type --match --pub-members --view --outline-rules --no-default-outline-rules --follow --no-ignore --stdin --globs --threads --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --json)
                    COMPREPLY=($(compgen -W "pretty stream compact" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto always ansi never" -- "${cur}"))
                    return 0
                    ;;
                --items)
                    COMPREPLY=($(compgen -W "auto structure exports imports all" -- "${cur}"))
                    return 0
                    ;;
                --type)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --match)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --view)
                    COMPREPLY=($(compgen -W "auto names signatures digest expanded" -- "${cur}"))
                    return 0
                    ;;
                --outline-rules)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --no-ignore)
                    COMPREPLY=($(compgen -W "hidden dot exclude global parent vcs" -- "${cur}"))
                    return 0
                    ;;
                --globs)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --threads)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -j)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__run)
            opts="-p -k -r -l -j -i -U -A -B -C -c -h --pattern --selector --strictness --kind --rewrite --lang --debug-query --follow --no-ignore --stdin --globs --threads --interactive --update-all --files-with-matches --json --color --inspect --after --before --context --heading --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --pattern)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -p)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --selector)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --strictness)
                    COMPREPLY=($(compgen -W "cst smart ast relaxed signature template" -- "${cur}"))
                    return 0
                    ;;
                --kind)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -k)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rewrite)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -r)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --lang)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -l)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --debug-query)
                    COMPREPLY=($(compgen -W "pattern ast cst sexp" -- "${cur}"))
                    return 0
                    ;;
                --no-ignore)
                    COMPREPLY=($(compgen -W "hidden dot exclude global parent vcs" -- "${cur}"))
                    return 0
                    ;;
                --globs)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --threads)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -j)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --json)
                    COMPREPLY=($(compgen -W "pretty stream compact" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto always ansi never" -- "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -W "nothing summary entity" -- "${cur}"))
                    return 0
                    ;;
                --after)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -A)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --before)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -B)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --context)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -C)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --heading)
                    COMPREPLY=($(compgen -W "auto always never" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__scan)
            opts="-r -j -i -U -A -B -C -c -h --rule --inline-rules --format --report-style --include-metadata --filter --min-severity --error --warning --info --hint --off --follow --no-ignore --stdin --globs --threads --interactive --update-all --files-with-matches --json --color --inspect --after --before --context --max-results --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --rule)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -r)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --inline-rules)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --format)
                    COMPREPLY=($(compgen -W "github sarif" -- "${cur}"))
                    return 0
                    ;;
                --report-style)
                    COMPREPLY=($(compgen -W "rich medium short" -- "${cur}"))
                    return 0
                    ;;
                --filter)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --min-severity)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --error)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --warning)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --info)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --hint)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --off)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --no-ignore)
                    COMPREPLY=($(compgen -W "hidden dot exclude global parent vcs" -- "${cur}"))
                    return 0
                    ;;
                --globs)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --threads)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -j)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --json)
                    COMPREPLY=($(compgen -W "pretty stream compact" -- "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto always ansi never" -- "${cur}"))
                    return 0
                    ;;
                --inspect)
                    COMPREPLY=($(compgen -W "nothing summary entity" -- "${cur}"))
                    return 0
                    ;;
                --after)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -A)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --before)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -B)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --context)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -C)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --max-results)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        ast__subcmd__grep__subcmd__test)
            opts="-t -U -i -f -c -h --test-dir --snapshot-dir --skip-snapshot-tests --update-all --interactive --filter --include-off --follow --color --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --test-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --snapshot-dir)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --filter)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -f)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --color)
                    COMPREPLY=($(compgen -W "auto always ansi never" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _ast__grep -o nosort -o bashdefault -o default ast-grep
else
    complete -F _ast__grep -o bashdefault -o default ast-grep
fi
