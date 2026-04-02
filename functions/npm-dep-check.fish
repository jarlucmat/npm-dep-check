#!/usr/bin/env fish

function npm-dep-check --description "Checks given package names if there are part of your npm project."

	#
	# dependency check
	#
	__npm-dep-check-dependencies
	or return $status

	#
	# global variables
	#

	set -g __npmDepCheck_hit (set_color --bold red)
	set -g __npmDepCheck_version (set_color --bold green)
	set -g __npmDepCheck_reset (set_color normal)
	set -g __npmDepCheck_NPM_PACKAGE_LIST_CACHE
	set -g __npmDepCheck_NPM_REGEX_MATCHER '^(.[^@]+)(?:@(.*))?$'

	#
	# methods
	#

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
		set __npmDepCheck_NPM_PACKAGE_LIST_CACHE (string split ' ' -- "$allDeps" | sort | uniq)
		echo "Found unique dependencies: $(count $__npmDepCheck_NPM_PACKAGE_LIST_CACHE), of total $(count $allDeps)"
	end

	function findPackageVersions
		set -l package $argv

		# split package name from version (if set)
		set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $package)
		set -l packageName $matcher[1]
		set -l searchedVersions (string split ',' -- $matcher[2] | string trim)
		set -l foundVersions (queryPackageVersions $packageName)

		echo "$packageName"
		if test -z "$foundVersions"
			echo "NOT FOUND"
			return 1
		end

		if test -z "$searchedVersions"
			printfVersions $foundVersions
			return 2
		end

		compareVersions --search (string join ',' $searchedVersions) --found (string join ',' $foundVersions)
		return $status 
	end

	function compareVersions
		argparse 'search=+' 'found=+' -- $argv
		set -l foundVersions (string split ',' -- $_flag_found)
		set -l regexVersions
		for v in (string split ',' -- $_flag_search)
			set -a regexVersions "^$v(\.\d+)*\$"
		end

		# search for version matches
		set -l returnCode 2
		set -l matchedVersions
		for foundVersion in $foundVersions
			set -l entry
			if string match -qr -- (string join '|' -- $regexVersions) $foundVersion
				set entry "$foundVersion (MATCH)"
				set returnCode 0
			else
				set entry "$foundVersion"
			end
			set -a matchedVersions $entry
		end
		printfVersions $matchedVersions
		return $returnCode
	end

	# query for given packageName
	function queryPackageVersions
		string split ' ' -- "$__npmDepCheck_NPM_PACKAGE_LIST_CACHE" |\
			string match -r "^$argv:.*\$" |\
			string split -f 2 --allow-empty ':'
	end

	function queryPackageName
		string split ' ' -- "$__npmDepCheck_NPM_PACKAGE_LIST_CACHE" |\
			string match -r "^$(string replace -a '*' '.*' -- $argv):.*\$" |\
			string split -f 1 --allow-empty ':'
	end

	function queryAllPackages
		set -f currentPackage (string split -f 1 ' ' -- "$__npmDepCheck_NPM_PACKAGE_LIST_CACHE" | string split -f 1 ':')
		set -f currentVersions
		for line in (string split ' ' -- "$__npmDepCheck_NPM_PACKAGE_LIST_CACHE")
			set -l matcher (string match -r -g "^([^:]+):(.*)\$" -- $line)
			set -l packageName $matcher[1]
			set -l packageVersion $matcher[2]
			# sobald der aktuelle package name nicht mehr zusammenpasst mit dem gespeicherten
			# gib alle gesammelten versionsnummern aus
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
		set -f coloredVersions
		for v in $argv
			set -l entry
			if string match -qe -- "(MATCH)" $v
				set entry "$__npmDepCheck_hit$v$__npmDepCheck_reset"
			else
				set entry "$__npmDepCheck_version$v$__npmDepCheck_reset"
			end
			set -a coloredVersions $entry
		end
		echo (string join '\n' -- $coloredVersions)
	end

	function getPackages
		for param in $argv
			echo $param
		end
	end

	function processPackages
		for package in $argv
			if string match -qr -- "\*" $package
				processPackageSearch $package
				continue
			end
			set -l result (findPackageVersions $package)
			set -l code $status
			if test $code -eq 0
				or begin
					test $code -eq 1; and not set -q _flag_f; and not set -q _flag_o;
				end
				or begin
					test $code -eq 2; and not set -q _flag_o
				end
				echo "$result[1]@$result[2]"
			end
		end
	end

	function processPackageSearch
		set -l matcher (string match -r -g $__npmDepCheck_NPM_REGEX_MATCHER -- $argv)
		set -l packageName $matcher[1]
		set -l searchedVersions $matcher[2]
		set -l foundPackages (queryPackageName $packageName)

		set -l foundPackagesWithVersion
		if test -n "$searchedVersions"
			for p in $foundPackages
				set -a foundPackagesWithVersion "$p@$searchedVersions"
			end
		else
			set foundPackagesWithVersion $foundPackages
		end
		processPackages $foundPackagesWithVersion
	end

	#
	# main
	#

	argparse 'f/found' 'o/only-matches' 'h/help' -- $argv
	or return 1;

	if set -q _flag_h;
		echo "Usage: $(status filename) [ OPTIONS ] [ NPM PACKAGE NAMES ]..."
		echo -e ""
		echo -e "OPTIONS"
		echo -e "\t -h, --help \t\t Display this page"
		echo -e "\t -o, --only-matches \t Show only packages with matched version numbers"
		echo -e "\t -f, --found \t\t Show only found packages"
		echo -e ""
		echo -e "NPM PACKAGE NAMES"
		echo -e "\t Can either be with or without version number like: typescript or typescript@1.0.0."
		echo -e ""
		return
	end

	initNpmCache
	or return $status

	set -l packages (getPackages $argv)
	if test (count $packages) -eq 0
		for package in (queryAllPackages)
			echo $package
		end
	else
		processPackages $packages
	end

	set -e __npmDepCheck_NPM_REGEX_MATCHER __npmDepCheck_version __npmDepCheck_hit __npmDepCheck_reset __npmDepCheck_NPM_PACKAGE_LIST_CACHE
end
