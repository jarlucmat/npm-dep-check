function __npm_dep_check_queryPackageName
	set -f escapedInput (string escape --style=regex -- $argv[1])
	set -f searchString "^$(string replace -a '\*' '.*' -- $escapedInput):.*\$"
	string match -r -- $searchString $__npmDepCheck_NPM_PACKAGE_LIST_CACHE |\
		string split -f 1 --allow-empty ':' |\
		sort -u
end
