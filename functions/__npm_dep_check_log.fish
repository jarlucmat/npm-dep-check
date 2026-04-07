function __npm_dep_check_log --argument-names method message
	if not set -q __npmDepCheck_LOG
		return
	end

	begin
		printf '[%s] %s\n' "$method" "$message"
	end >&2
end
