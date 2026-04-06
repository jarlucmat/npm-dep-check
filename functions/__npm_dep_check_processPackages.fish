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
	set -l result (__npm_dep_check_findPackageVersions $package)
	string join '@' -- $result[1] $result[2]
end

function __npm_dep_check_processPackageSearch
	set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $argv)
	set -l packageName $matcher[1]
	set -l searchedVersions $matcher[2]
	set -l foundPackages (__npm_dep_check_queryPackageName $packageName)

	set -l foundPackagesWithOptionalVersion $foundPackages
	if test -n "$searchedVersions"
		set foundPackagesWithOptionalVersion
		for p in $foundPackages
			set -a foundPackagesWithOptionalVersion "$p@$searchedVersions"
		end
	end
	__npm_dep_check_processPackages $foundPackagesWithOptionalVersion
end
