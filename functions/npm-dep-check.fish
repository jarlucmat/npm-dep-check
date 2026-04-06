#!/usr/bin/env fish

function npm-dep-check --description "Checks given package names if there are part of your npm project."

	###
	### dependency check
	###
	__npm-dep-check-dependencies
	or return $status

	###
	### global variables
	###

	set -g __npmDepCheck_NPM_PACKAGE_LIST_CACHE
	set -g __npmDepCheck_NPM_REGEX_MATCHER '^(.[^@]+)(?:@(.*))?$'
	#set -g __npmDepCheck_LOG

	###
	### methods
	###

	function log_emit --argument-names level message
		emit my_logger_event $level $message
	end

	function my_logger_handler --on-event my_logger_event
		if not set -q __npmDepCheck_LOG
			return
		end
		set -l level $argv[1]
		set -l message $argv[2]

		printf '[%s] %s\n' $level $message >&2
	end

	function initNpmCache
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

	function findPackageVersions
		set -l package $argv

		# split package name from version (if set)
		set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $package)
		set -l packageName $matcher[1]
		set -l searchedVersions (string split ',' -- $matcher[2] | string trim)
		set -l foundVersions (queryPackageVersions $packageName)

		log_emit DEBUG "packageName: $packageName"
		log_emit DEBUG "searchedVersions: $searchedVersions"
		log_emit DEBUG "foundVersions: $foundVersions"

		echo "$packageName"
		if test -z "$foundVersions"
			echo "NOT FOUND"
			return
		end

		if test -z "$searchedVersions"
			echo (printfVersions $foundVersions)
			return
		end

		echo (compareVersions --search (string join ',' $searchedVersions) --found (string join ',' $foundVersions))
	end

	function compareVersions
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
		printfVersions $matchedVersions
	end

	# query for given packageName
	function queryPackageVersions
		set -f searchString "^$argv[1]:.*\$"

		log_emit DEBUG "searchString: $searchString"
		log_emit DEBUG "query result: $(string match -r -- $searchString $__npmDepCheck_NPM_PACKAGE_LIST_CACHE)"

		string match -r -- $searchString $__npmDepCheck_NPM_PACKAGE_LIST_CACHE |\
			string split -f 2 --allow-empty ':'
	end

	function queryPackageName
		set -f searchString "^$(string replace -a '*' '.*' -- $argv[1]):.*\$"
		string match -r -- $searchString $__npmDepCheck_NPM_PACKAGE_LIST_CACHE |\
			string split -f 1 --allow-empty ':' |\
			sort -u
	end

	# does the same as searching for wildcard *
	# but is more efficient
	function queryAllPackages
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
				echo "$currentPackage@$(printfVersions $currentVersions)"
				set currentPackage $packageName
				set currentVersions
			end

			set -a currentVersions $packageVersion
		end
	end

	function printfVersions
		set -f coloredVersions (mapColorToVersion $argv | string split '\n')
		echo (string join ',' -- $coloredVersions)
	end

	function mapColorToVersion
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

	function processPackages
		for package in $argv
			processPackage $package
		end
	end

	function processPackage
		set -f package $argv[1]
		if string match -qr -- "\*" $package
			processPackageSearch $package
			return
		end
		set -l result (findPackageVersions $package)
		echo "$result[1]@$result[2]"
	end

	function processPackageSearch
		set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $argv)
		set -l packageName $matcher[1]
		set -l searchedVersions $matcher[2]
		set -l foundPackages (queryPackageName $packageName)

		set -l foundPackagesWithOptionalVersion $foundPackages
		if test -n "$searchedVersions"
			set foundPackagesWithOptionalVersion
			for p in $foundPackages
				set -a foundPackagesWithOptionalVersion "$p@$searchedVersions"
			end
		end
		processPackages $foundPackagesWithOptionalVersion
	end

	###
	### main
	###

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

	initNpmCache
	or return $status

	set -l packages $argv
	if test (count $packages) -eq 0
		queryAllPackages
		return
	end

	for result in (processPackages $packages)
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
