function __npm_dep_check_printfVersions
	set -f coloredVersions (__npm_dep_check_mapColorToVersion $argv | string split '\n')
	echo (string join ',' -- $coloredVersions)
end

function __npm_dep_check_mapColorToVersion
	set -f colorMatch (set_color --bold red)
	set -f colorVersion (set_color --bold green)
	set -f colorReset (set_color normal)
	set -f coloredVersions
	for v in $argv
		set -l entry
		if string match -qe -- "(MATCH)" $v
			set entry "$colorMatch$v$colorReset"
		else
			set entry "$colorVersion$v$colorReset"
		end
		set -a coloredVersions $entry
	end
	echo (string join '\n' -- $coloredVersions)
end
