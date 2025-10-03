#!/usr/bin/env fish

function __npm-dep-check-dependencies
    for dep in npm jq
        if not type -q $dep
            printf "%s: missing dependency: %s\n" (status current-function) $dep >&2
            return 127
        end
    end
end
