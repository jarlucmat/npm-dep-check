function __npm_dep_check_log --argument-names method message
	begin
		printf '[%s] %s\n' "$method" "$message"
	end >&2
end
