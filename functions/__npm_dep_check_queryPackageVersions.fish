function __npm_dep_check_queryPackageVersions
	set -f searchString "^$argv[1]:.*\$"

	__npm_dep_check_log __npm_dep_check_queryPackageVersions "searchString: $searchString"

	string match -r -- $searchString $__npmDepCheck_NPM_PACKAGE_LIST_CACHE |\
		string split -f 2 --allow-empty ':'
end
