function __npm_dep_check_log --argument-names level message
	emit __npm_dep_check_logger_event $level $message
end

function __npm_dep_check_logger --on-event __npm_dep_check_logger_event
	if not set -q __npmDepCheck_LOG
		return
	end
	set -l level $argv[1]
	set -l message $argv[2]

	printf '[%s] %s\n' $level $message >&2
end
