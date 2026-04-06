function __npm_dep_check_compareVersions
	argparse 'search=+' 'found=+' -- $argv
	set -l foundVersions (string split ',' -- $_flag_found)
	set -l regexVersions
	for v in (string split ',' -- $_flag_search)
		set -a regexVersions "^$v(\.\d+)*\$"
	end

	# search for version matches
	set -l matchedVersions
	for foundVersion in $foundVersions
		set -l entry
		if string match -qr -- (string join '|' -- $regexVersions) $foundVersion
			set entry "$foundVersion (MATCH)"
		else
			set entry "$foundVersion"
		end
		set -a matchedVersions $entry
	end
	__npm_dep_check_printfVersions $matchedVersions
end
