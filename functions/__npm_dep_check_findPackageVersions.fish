function __npm_dep_check_findPackageVersions
	set -l package $argv

	# split package name from version (if set)
	set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $package)
	set -l packageName $matcher[1]
	set -l searchedVersions (string split ',' -- $matcher[2] | string trim)
	set -l foundVersions (__npm_dep_check_queryPackageVersions $packageName)
	set -l versionResult

	__npm_dep_check_log __npm_dep_check_findPackageVersions "packageName: $packageName"
	__npm_dep_check_log __npm_dep_check_findPackageVersions "searchedVersions: $searchedVersions"
	__npm_dep_check_log __npm_dep_check_findPackageVersions "foundVersions: $foundVersions"

	if test -z "$foundVersions"
		set versionResult "NOT FOUND"
	else if test -z "$searchedVersions"
		set versionResult (__npm_dep_check_printfVersions $foundVersions)
	else
		set versionResult (__npm_dep_check_compareVersions --search (string join ',' $searchedVersions) --found (string join ',' $foundVersions))
	end

	string join '@' -- $packageName $versionResult
end
