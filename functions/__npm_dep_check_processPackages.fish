function __npm_dep_check_processPackages
	for package in $argv
		__npm_dep_check_processPackage $package
	end
end

function __npm_dep_check_processPackage
	set -f package $argv[1]
	if string match -qr -- "\*" $package
		__npm_dep_check_processPackageSearch $package
		return
	end

	__npm_dep_check_findPackageVersions $package
end

function __npm_dep_check_processPackageSearch
	set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $argv)
	set -l packageName $matcher[1]
	set -l searchedVersions $matcher[2]
	set -l foundPackages (__npm_dep_check_queryPackageName $packageName)

	__npm_dep_check_log __npm_dep_check_processPackageSearch "matcher: $matcher"
	__npm_dep_check_log __npm_dep_check_processPackageSearch "foundPackages: $foundPackages"

	set -l foundPackagesWithOptionalVersion $foundPackages
	if test -n "$searchedVersions"
		set foundPackagesWithOptionalVersion
		for p in $foundPackages
			set -a foundPackagesWithOptionalVersion "$p@$searchedVersions"
		end
	end
	__npm_dep_check_processPackages $foundPackagesWithOptionalVersion
end
