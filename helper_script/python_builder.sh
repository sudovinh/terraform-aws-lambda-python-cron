#!/bin/bash
set -euo pipefail

#/ Usage: ./python_builder.sh
#/ Description: This script will package your source code and dependencies into one folder.
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

CURRENT_WORKING_DIR="${path_cwd}"
FINAL_PACKAGE_SCRIPT_FOLDER="lambda_final_package_script"
SCRIPT_PATH="${source_code_path}/${script_name}"
REQUIREMENTS_PATH="${source_code_path}/requirements.txt"
PIP_PATH="/usr/local/bin/pip"
VIRTUALENV_PATH="/usr/local/bin/virtualenv"

# Make sure virtualenv and pip is installed
pre_req_check () {
  if [[ -f "${PIP_PATH}" && "${VIRTUALENV_PATH}" ]]; then
    echo "${PIP_PATH} and ${VIRTUALENV_PATH} exists!"
  else
    echo "${PIP_PATH} and ${VIRTUALENV_PATH} does not exists!"
    exit 1
  fi
}

# Set up directory folder for final packaged folder.
directory_setup () {
  echo "Creating final package script folder"
  cd "${CURRENT_WORKING_DIR}"
  mkdir -p "${FINAL_PACKAGE_SCRIPT_FOLDER}"
}

# Set up virtual env
virtual_env () {
  /usr/local/bin/virtualenv -p "${runtime}" "env-${function_name}"
  source "env-${function_name}/bin/activate"
}

# Validate script and requirements.txt exists
validate_file_exists () {
  if [[ -f "${SCRIPT_PATH}" && "${REQUIREMENTS_PATH}" ]]; then
    echo "${SCRIPT_PATH} and ${REQUIREMENTS_PATH} exists!"
  else
    echo "${SCRIPT_PATH} and ${REQUIREMENTS_PATH} does not exists!"
    exit 1
  fi
}

# Installing python dependencies
install_dependencies () {
  echo "Installing dependencies.."
  /usr/local/bin/pip install -q -r "${REQUIREMENTS_PATH}" --upgrade
  echo "Deactivating virtualenv.."
  deactivate
}

# Create deployment package
create_deployment_package () {
  echo "Creating deployment package to ${CURRENT_WORKING_DIR}/${FINAL_PACKAGE_SCRIPT_FOLDER}"
  cd "env-${function_name}/lib/${runtime}/site-packages/"
  cp -r . "${CURRENT_WORKING_DIR}/${FINAL_PACKAGE_SCRIPT_FOLDER}"
  cp -r "${source_code_path}/" "${CURRENT_WORKING_DIR}/${FINAL_PACKAGE_SCRIPT_FOLDER}"
}

# Clean up
clean_up () {
  cd "${CURRENT_WORKING_DIR}"
  rm -rf "env-${function_name}"
}

# Main
main () {
  pre_req_check
  validate_file_exists
  directory_setup
  virtual_env
  install_dependencies
  create_deployment_package
  clean_up
}

# Execute the main code only when the script is executed directly, not sourced.
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  # --help or -h in arguments? Show usage
  expr "$*" : ".*--help" > /dev/null && usage
  expr "$*" : ".*-h" > /dev/null && usage
  main "$@"
fi
