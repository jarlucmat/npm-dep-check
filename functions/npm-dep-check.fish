#!/usr/bin/env fish

###
### main
###
function npm-dep-check --description "Checks given package names if there are part of your npm project."

	###
	### dependency check
	###
	__npm_dep_check_dependencies
	or return $status

	###
	### global variables
	###

	set -g __npmDepCheck_NPM_PACKAGE_LIST_CACHE
	set -g __npmDepCheck_NPM_REGEX_MATCHER '^((?:@[^@]+)|([^@]+))(?:@(.*))?$'
	#set -g __npmDepCheck_LOG


	argparse 'f/found' 'o/only-matches' 'h/help' 'v/verbose' -- $argv
	or return 1;

	if set -q _flag_h;
		echo "Usage: $(status filename) [ OPTIONS ] [ NPM PACKAGE NAMES ]..."
		echo -e ""
		echo -e "OPTIONS"
		echo -e "\t -h, --help \t\t Display this page"
		echo -e "\t -o, --only-matches \t Show only packages with matched version numbers"
		echo -e "\t -f, --found \t\t Show only found packages"
		echo -e "\t -v, --verbose \t\t Verbose output"
		echo -e ""
		echo -e "NPM PACKAGE NAMES"
		echo -e "\t Can either be with or without version number like: typescript or typescript@1.0.0"
		echo -e "\t It is also possible to search for subsequences of versions: typescript@1,2.1"
		echo -e "\t To find groups of packages it is possible to use * as wildcard: @angular/*@18. Wildcards only work for names, not version numbers"
		echo -e ""
		return
	end

	if set -q _flag_v
		set -g __npmDepCheck_LOG
	end

	__npm_dep_check_initNpmCache
	or return $status

	set -l packages $argv
	if test (count $packages) -eq 0
		__npm_dep_check_queryAllPackages
		return
	end

	for result in (__npm_dep_check_processPackages $packages)
		# hide errors
		if test $status -ne 0
			continue
		end

		# hide not found packages
		if set -q _flag_f; or set -q _flag_o
			if string match -qe -- "NOT FOUND" $result
				continue
			end
		end

		# hide not matched packages
		if set -q _flag_o
			if not string match -qe -- "(MATCH)" $result
				continue
			end
		end

		echo $result
	end

	set -e __npmDepCheck_LOG __npmDepCheck_NPM_REGEX_MATCHER __npmDepCheck_NPM_PACKAGE_LIST_CACHE
end
