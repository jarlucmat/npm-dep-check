function __npm_dep_check_findPackageVersions
	set -l package $argv

	# split package name from version (if set)
	set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $package)
	set -l packageName $matcher[1]
	set -l searchedVersions (string split ',' -- $matcher[2] | string trim)
	set -l foundVersions (__npm_dep_check_queryPackageVersions $packageName)

	log_emit DEBUG "packageName: $packageName"
	log_emit DEBUG "searchedVersions: $searchedVersions"
	log_emit DEBUG "foundVersions: $foundVersions"

	echo "$packageName"
	if test -z "$foundVersions"
		echo "NOT FOUND"
		return
	end

	if test -z "$searchedVersions"
		echo (__npm_dep_check_printfVersions $foundVersions)
		return
	end

	echo (__npm_dep_check_compareVersions --search (string join ',' $searchedVersions) --found (string join ',' $foundVersions))
end
