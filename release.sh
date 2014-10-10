#!/bin/sh

set -e

source $(dirname $0)/utils.inc

NEXT_VERSION_REGEX="^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$"
ACTION_REGEX="^(prepare|publish|retract)$"
COMMIT_SHA_REGEX="(.*)"
ARG_DEFS=(
	"--next-version=${NEXT_VERSION_REGEX}"
	"[--action=${ACTION_REGEX}]"
	"[--commit-sha=${COMMIT_SHA_REGEX}]"
)

while [[ $# > 1 ]]; do
	key="$1"
	shift

	case $key in
		-n|--next-version)
	    NEXT_VERSION="$1"
	    shift
	    ;;
	    -a|--action)
	    ACTION="$1"
	    shift
	    ;;
	    -c|--commit-sha)
	    COMMIT_SHA="$1"
	    shift
	    ;;
	    *)
	    ;;
	esac
done

if [[ -z ${NEXT_VERSION} || ! ${NEXT_VERSION} =~ ${NEXT_VERSION_REGEX} ||
	  (! -z ${ACTION} && ! ${ACTION} =~ ${ACTION_REGEX}) ||
	  (! -z ${COMMIT_SHA} && ! ${COMMIT_SHA} =~ ${COMMIT_SHA_REGEX}) ]]; then
	usage
fi

compareVersions() {
	printf "Checking that %s is greater than %s..." $(focus ${NEXT_VERSION}) $(focus ${RELEASE_VERSION})
	if [[ ${NEXT_VERSION} > ${RELEASE_VERSION} ]]; then
		echo_success
	else
		echo_failure "${ERR} The next version must be greater than the current version."
	fi
}

updateVersionToRelease() {
	printf "Updating %s to %s in %s..." $(focus ${CURRENT_VERSION}) $(focus ${RELEASE_VERSION}) $(focus ${PACKAGE})
	replaceJsonProp ${PACKAGE} "version" ".*" ${RELEASE_VERSION}
	if [[ $(readJsonProp ${PACKAGE} "version") == ${RELEASE_VERSION} ]]; then
		echo_success
	else
		echo_failure "${ERR} An error occurred while trying to update the development version."
	fi
}

prepare() {
	local umode="-unormal"
	if [[ -n "$(git status --porcelain --ignore-submodules ${umode})" ]]; then
		echo "dirty"
	else 
		echo "not"
	fi
	exit
	local PACKAGE="package.json"
	local SNAPSHOT="-beta"

	local CURRENT_VERSION=$(readJsonProp ${PACKAGE} "version")
	local RELEASE_VERSION=${CURRENT_VERSION//${SNAPSHOT}/}

	compareVersions
	updateVersionToRelease

	# updates changelog
	npm run changelog

	# tag commit
	git add CHANGELOG.md package.json
	git commit -m "chore(release): Release ${RELEASE_VERSION}"
	git tag -s ${RELEASE_VERSION} -m "chore(release): $RELEASE_VERSION" "$COMMIT_SHA"

	# updates to next development version
	replaceJsonProp ${PACKAGE} "version" ".*" ${NEXT_VERSION}${SNAPSHOT}

	# commit new version to master
	git add package.json
	git commit -m "chore(release): Start Development on ${NEXT_VERSION}"
}

publish() {
	# push master and tags
	git push origin master && git push origin $RELEASE_VERSION	
}

prepare
