#!/usr/bin/env sh

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parse_params() {
    local param

    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -c | --config)
                _configfile=$1
                shift
                ;;
            -h | --help)
                script_usage
                exit 0
                ;;
            -v | --verbose)
                _verbose=true
                ;;   
            *)
                echo "Invalid parameter was provided: $param"
                exit 1
                ;;
        esac
    done
}

# DESC: Usage help
# ARGS: None
# OUTS: None
function script_usage() {
    cat << EOF
Usage: loadtest [args]

Arguments:                        
     -c|--configfile            Set configuration file
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
EOF
}

# DESC: Only pretty_print() the provided string if verbose mode is enabled
# ARGS: $@ (required): Passed through to pretty_print() function
# OUTS: None
function verbose_print() {

    if [[ ! -z ${_verbose} ]]; then
        echo "$1"
    fi
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    parse_params "$@"

    _token=$(cat /token/token.txt);
    _file=${_configfile};
    # Add the bearer token to the configuration file
    jq --arg a "Bearer ${_token}" '.steps[].headers.authorization = $a' /app/config/${_file} > /tmp/config.json

    /app/bin/ddosify -config /tmp/config.json
    verbose_print "#### Complete" && echo "";

    rm /tmp/config.json
}

main "$@"