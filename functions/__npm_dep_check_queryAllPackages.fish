# does the same as searching for wildcard *
# but is more efficient
function __npm_dep_check_queryAllPackages
	set -f currentPackage (string split -f 1 ':' -- $__npmDepCheck_NPM_PACKAGE_LIST_CACHE[1])
	set -f currentVersions
	for p in $__npmDepCheck_NPM_PACKAGE_LIST_CACHE
		set -l matcher (string split ':' -- $p)
		set -l packageName $matcher[1]
		set -l packageVersion $matcher[2]
		# collect versions until the current package name
		# does not match the saved one
		# if this is true -> print all collected versions
		if test "$currentPackage" != "$packageName"
			string join '@' -- $currentPackage (__npm_dep_check_printfVersions $currentVersions)
			set currentPackage $packageName
			set currentVersions
		end

		set -a currentVersions $packageVersion
	end

	# last run
	if test -n "$currentPackage"
		string join '@' -- $currentPackage (__npm_dep_check_printfVersions $currentVersions)
	end
end
