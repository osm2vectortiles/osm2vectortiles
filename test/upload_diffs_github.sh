#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly DIFF_DIR="$CWD/local"

readonly GIT_USERNAME="Travis CI"
readonly GIT_EMAIL="me@lukasmartinelli.ch"

function commit_latest_diffs() {
    git clone https://github.com/geometalab/osm2vectortiles.git repo

    cd repo
    git checkout gh-pages
    cp -rf "$CWD/diff" "diff"

    git config user.name "$GIT_USERNAME"
    git config user.email "$GIT_EMAIL"
    git config credential.helper "store --file=.git/credentials"
    echo "https://${GH_TOKEN}:@github.com" > .git/credentials

    git add diff/*
    git commit -m "Add latest tile diffs from ${TRAVIS_BUILD_NUMBER}"
    git push origin gh-pages

    cd $CWD
}

commit_latest_diffs
