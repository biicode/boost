#!/bin/sh

repos=("biicode/boost-examples-headeronly")

while [[ $# > 1 ]]
do
key="$1"

case $key in
    --build)
    BUILD="$2"
	shift
    ;;
	--user)
	USER="$2"
	shift
    ;;
	--password)
	PASSWORD="$2"
    shift
    ;;
    --email)
    EMAIL="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
shift
done

if [ -z "${BUILD}" ]; then
    echo ERROR: Missing --build param
    exit 1
fi

if [ -z "${USER}" ]; then
    echo ERROR: Missing --user param
    exit 1
fi

if [ -z "${PASSWORD}" ]; then
    echo ERROR: Missing --password param
    exit 1
fi

if [ -z "${EMAIL}" ]; then
    echo ERROR: Missing --email param
    exit 1
fi

commit_id="$(git log --format="%H" -n 1)"

for r in "${repos[@]}"; do
    IFS=/ read -a repo <<< "${r}"
    repo_account="${repo[0]}"
    repo_name="${repo[1]}"

    git clone "https://github.com/${r}.git" "${repo_name}"
    cd "${repo_name}"

    log="biicode/boost build ${BUILD}: ${commit_id}" 

    echo "${log}" >> ci_builds.txt

    git config user.email "${EMAIL}"
    git config user.name "${USER}"
    git config remote.origin.url "https://${USER}:${PASSWORD}@github.com/${r}.git"
    git add ci_builds.txt
    git commit -m "${log}"

    echo Launching $r build...

    git push &>/dev/null # Be careful! git shows "https://USER:PASSWORD@github.com..." when running push

    cd ..
done
