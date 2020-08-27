#!/usr/bin/env bash

tf_config=
tf_command=
tf_args=

VERBOSE="debug"
HOSTFILE=/etc/hosts
ANSIBLE_INVENTORY=./ansible-build/inventory

logdebug() {
	# Only log to stdout when verbose is turned on
	if [[ "${VERBOSE}" = "debug" ]]; then
		echo "$(date +'%Y-%m-%d %H:%M:%S') ${MY_NAME}: [DEBUG] ${*}"
	fi
}

logmsg() {
	# Only log to stdout when verbose/debug is turned on
	if [[ "${VERBOSE}" = "verbose" ]] || [[ "${VERBOSE}" = "debug" ]]; then
		echo "$(date +'%Y-%m-%d %H:%M:%S') ${MY_NAME}: [INFO]  ${*}"
	fi
}

logerr() {
	echo "$(date +'%Y-%m-%d %H:%M:%S') ${MY_NAME}: [ERROR] ${*}" >&2
}

function run(){
    logmsg "kstack run"

    args=()
    # named args
    while [[ "$1" != "" ]]; do
        case "$1" in
           --config )                   tf_config=$2;   shift;;
           --cmd )                      tf_command=$2;  shift;;
           -h | --help )                usage;          exit;; # quit and show usage
            * )                         args+=("$1") # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
    # restore positional args
    set -- "${args[@]}"
    tf_args=$@
    logmsg ${tf_config} ${tf_command} ${tf_args}
    if [[ -f "backend_conf_${tf_config}.tf" ]]; then
        logmsg "backend configure for $tf_config existed then don't need to reconfig tf"
    else
        logmsg "backend configure for $tf_config not existed then need to reconfig tf"
        logmsg "remove current configure"
        rm -rf backend_conf_*.tf
        logmsg "Create new backend configure from temp"
        export TF_PROJECT_PREFIX=${tf_config}
        envsubst < ./temp/backend_gcs_temp.tf > backend_conf_${tf_config}.tf;
        terraform init -backend-config=./backend_conf_${tf_config}.tf ;
    fi
    terraform ${tf_command} -var prefix=${tf_config} ${tf_args}

    if [[ "${tf_command}" = "apply" && $? = 0 ]]; then
        tf_config_hostname="$tf_config"
        logmsg "terraform apply successful, let update /etc/hosts with $tf_config_hostname"
        if grep -q ${tf_config_hostname} $HOSTFILE; then
            logmsg "existed host. let replace by new one"
            sed -i "/$tf_config_hostname/c $(echo `terraform output ip` ${tf_config_hostname})" /etc/hosts
        else
           logmsg "Not existed host yet. push it in"
           echo "`terraform output ip` ${tf_config_hostname}" >> /etc/hosts
        fi

        logmsg "let update ansible inventory with $tf_config_hostname"
        if grep -q ${tf_config_hostname} ${ANSIBLE_INVENTORY}; then
            logmsg "existed host. let replace by new one"
            sed -i "/$tf_config_hostname/c $(echo ${tf_config_hostname} ansible_connection=ssh)" ${ANSIBLE_INVENTORY}
        else
           logmsg "Not existed host yet. push it in"
           echo "${tf_config_hostname} ansible_connection=ssh" >> ${ANSIBLE_INVENTORY}
        fi
        logmsg "Success on create your Virtual server at hostname ${tf_config_hostname}"
    fi
}

run $@
