function __npm_dep_check_dependencies
    for dep in npm jq sort
        if not type -q $dep
            printf "%s: missing dependency: %s\n" (status current-function) $dep >&2
            return 127
        end
    end
end
