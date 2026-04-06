function __npm_dep_check_queryPackageName
	set -f searchString "^$(string replace -a '*' '.*' -- $argv[1]):.*\$"
	string match -r -- $searchString $__npmDepCheck_NPM_PACKAGE_LIST_CACHE |\
		string split -f 1 --allow-empty ':' |\
		sort -u
end
