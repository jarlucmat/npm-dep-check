#!/usr/bin/env fish

function npm-dep-check --description "Checks given package names if there are part of your npm project. Can also handle stdin." 

	#
	# dependency check
	#
	__npm-dep-check-dependencies
	or return $status

	#
	# global variables
	#

	set hit (set_color --bold red)
	set reset (set_color normal)
	set NPM_PACKAGE_LIST_CACHE

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
		set NPM_PACKAGE_LIST_CACHE (echo $allDeps | string split ' ' | sort | uniq)
		echo "Found unique dependencies: $(count $NPM_PACKAGE_LIST_CACHE), of total $(count $allDeps)"
	end

	function findPackageVersions
		set -l package $argv

		# split package name from version (if set)
		set -l matcher (string match -r -g '^(.[^@]+)(?:@(.*))?$' -- $package)
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
		set -l searchedVersions (string split ',' $_flag_search)
		set -l foundVersions (string split ',' $_flag_found)

		# search for version matches
		set -l returnCode 2
		set -l coloredVersions
		for foundVersion in $foundVersions
			set -l entry
			if contains -- $foundVersion $searchedVersions
				set entry "$hit$foundVersion (MATCH)$reset"
				set returnCode 0
			else
				set entry "$foundVersion"
			end
			set coloredVersions $coloredVersions $entry
		end
		printfVersions $coloredVersions
		return $returnCode
	end

	# query for given packageName
	function queryPackageVersions
		echo "$NPM_PACKAGE_LIST_CACHE" |\
			string split ' ' |\
			grep -P "^$argv:" |\
			string split -f 2 --allow-empty ':'
	end

	function printfVersions
		echo (string join ', ' -- $argv)
	end

	function getPackages
		if contains -- '-' $argv; or test (count $argv) -eq 0
			while read -P "" -l line
				echo $line
			end
		else
			for param in $argv
				echo $param
			end
		end
	end

	#
	# main
	#

	argparse 'f/found' 'o/only-matches' 'h/help' -- $argv
	or return 1;

	if set -q _flag_h;
		echo "Usage: $(status filename) [ OPTIONS ] [ Npm package name ]..."
		echo -e ""
		echo -e "OPTIONS"
		echo -e "\t -h, --help \t\t Display this page"
		echo -e "\t -o, --only-matches \t Show only packages with matched version numbers"
		echo -e "\t -f, --found \t\t Show only found packages"
		echo -e ""
		echo -e "Npm package name"
		echo -e "\t Can either be with or without version number like: typescript or typescript@1.0.0."
		echo -e ""
		return
	end

	initNpmCache
	or return $status

	for package in (getPackages $argv)
		set -l result (findPackageVersions $package)
		set -l code $status
		if test $code -eq 0
			or begin 
				test $code -eq 1; and not set -q _flag_f; and not set -q _flag_o;
			end
			or begin 
				test $code -eq 2; and not set -q _flag_o
			end
		echo "$result[1]: $result[2]"
		end
	end
end
