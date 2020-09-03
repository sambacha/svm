#!/bin/bash
# SPDX-License-Identifier: ISC
# https://github.com/josh-richardson/svm
# v0.1.0
# Description: Bash Script ment for integrating SVM into CI/CD Process 

set -ueE -o pipefail

echo -ne "==> SVM Script loading..."

# If our current solidity version is the `DESIRED_SOLIDITY_VERSION` (defaults to the latest 0.x.0 solidity version)
# then compile and lint our project with: `svm install 0.5.16 && svm use 0.5.16`
# otherwise just compile our project with: `svm use 0.5.16`
#-------------------------------------------------------------#
#
# * SCRIPT EXAMPLE
# <!-- do not use, just a template for when this reaches stability!!! -->
# before_script:
#   - eval "$(curl -fsSL https://gist.githubusercontent.com/sambacha/4d0918ff4de8dc77efe627aac79026be/raw/6e965d75dbda95f61bd78ccd0e89254e7d64b524/svm-script.sh)"
#
#-------------------------------------------------------------#
# * ENVIORNMENT VARIABLES
# CUSTOM ENVIRONMENT VARIABLES
#
# DESIRED_SOLIDITY_VERSION
# To specify a specific solidity version
# travis env set DESIRED_SOLIDITY_VERSION "0.7.0"
#-------------------------------------------------------------#
#
# * COMPILE_COMMAND
# To compile the project with a custom command, do so with:
# travis env set COMPILE_COMMAND "svm use 0.5.16"
# TODO: `COMPILE_COMMAND` should have additional argument e.g. `&& solc --
#-------------------------------------------------------------#
#
# * VERIFY_COMMAND [NOT YET IMPLEMENTED]
# To verify the project with a custom command, do so with:
# travis env set VERIFY_COMMAND "solc --VERIFY_COMMAND"
#-------------------------------------------------------------#
#
# * Additional Scripts
# `$ grep \"bytecode\" build/contracts/* | awk '{print $1 " " length($3)/2}' `
#-------------------------------------------------------------#
# 
# * DEFAULT VALUES
# Default User Environment Variables
if test -z "${DESIRED_SOLIDITY_VERSION}"; then
	DESIRED_SOLIDITY_VERSION="$(set +u && svm ${DESIRED_SOLIDITY_VERSION} 0.7.0 && set -u)"
else
	DESIRED_SOLIDITY_VERSION="$(set +u && svm ${DESIRED_SOLIDITY_VERSION} "$DESIRED_SOLIDITY_VERSION" && set -u)"
fi
if test -z "${COMPILE_COMMAND-}"; then
	COMPILE_COMMAND="svm use 0.5.16"
fi
if test -z "${VERIFY_COMMAND-}"; then
	VERIFY_COMMAND="echo -ne "NOT IMPLEMENTED YET""
fi

# Set Local Environment Variables
CURRENT_SOLIDITY_VERSION="$(svm current)"

# Run
if test "$CURRENT_SOLIDITY_VERSION" = "$DESIRED_SOLIDITY_VERSION"; then
	echo "running on solidity version $CURRENT_SOLIDITY_VERSION which IS the desired $DESIRED_SOLIDITY_VERSION"

	echo "compiling and verifying with $CURRENT_SOLIDITY_VERSION..."
	(eval "$COMPILE_COMMAND" && eval "$VERIFY_COMMAND")
	echo "...compiled and verified with $CURRENT_SOLIDITY_VERSION"
else
	echo "running on solidity version $CURRENT_SOLIDITY_VERSION which IS NOT the desired $DESIRED_SOLIDITY_VERSION"

	echo "swapping to $DESIRED_SOLIDITY_VERSION..."
	set +u && svm install "$DESIRED_SOLIDITY_VERSION" && set -u
	echo "...swapped to $DESIRED_SOLIDITY_VERSION"

	echo "compiling with $DESIRED_SOLIDITY_VERSION..."
	eval "$COMPILE_COMMAND"
	echo "...compiled with $DESIRED_SOLIDITY_VERSION"

	echo "swapping back to $CURRENT_SOLIDITY_VERSION"
	set +u && svm use "$CURRENT_SOLIDITY_VERSION" && set -u
	echo "...swapped back to $CURRENT_SOLIDITY_VERSION"
fi

# TODO: Additional Integrations
# while our scripts pass linting, other scripts may not
# TODO: Travis-CI Demo
# /home/travis/.travis/job_stages: line 81: secure: unbound
set +u
