function __npm_dep_check_log --argument-names method message
	emit __npm_dep_check_logger_event $method $message
end

function __npm_dep_check_logger --on-event __npm_dep_check_logger_event
	if not set -q __npmDepCheck_LOG
		return
	end
	set -l method $argv[1]
	set -l message $argv[2]

	printf '[%s] %s\n' $method $message >&2
end
