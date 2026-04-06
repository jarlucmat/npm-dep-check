function __npm_dep_check_initNpmCache
	set -l npmJson (npm ls --all --json)
	set -l returnCode $status
	if test $returnCode -ne 0
		begin
			echo -e "\nNPM exited with code $returnCode"
			echo -e "Check your npm project and run npm (clean-)install before using this tool!"
		end >&2
		return 1
	end

	set -l allDeps (echo $npmJson |\
		# -r removes quotes from output
	# --stream creates pairs of [[path],value] for the whole object
	# select(has(1)) check if value exists
	# select(...) check for specific path of version -> [["somePackage", "dependencies", "packageName", "version"], "1.0.0"]
	# \(.[0] | length) currently not relevant but maybe later if depth info is interesting
	jq -r --stream 'select(has(1)) | select((.[0][-3]? == "dependencies") and (.[0][-1]? == "version")) | .[0][-2] + ":" + .[1]'
	)

	# remove duplicates and cache result
	set __npmDepCheck_NPM_PACKAGE_LIST_CACHE (string split ' ' -- "$allDeps" | sort -u)
	printf 'Found dependencies: %s, unique %s\n' (count $allDeps) (count $__npmDepCheck_NPM_PACKAGE_LIST_CACHE) >&2
end
