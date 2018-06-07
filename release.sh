#!/bin/bash

echo "Enter the owner and name of repo you wish to cut a release for (e.g. owner/repo)"

read REPO

echo "Enter your build command for your repo (if any)"

read BUILD_COMMAND

echo "Is this a major, minor, or patch release? Type major, minor, or patch"

read VERSION

echo "Enter your github access token (needed for releasing)"

read ACCESS_TOKEN

trim()
{
    local trimmed="$1"

    # Get rid of leading spaces.
    while [[ $trimmed == ' '* ]]; do
       trimmed="${trimmed## }"
    done
    # Get rid of trailing spaces.
    while [[ $trimmed == *' ' ]]; do
        trimmed="${trimmed%% }"
    done

    echo "$trimmed"
}

SANITIZED_VERSION=$(trim $VERSION)

if [ "$SANITIZED_VERSION" == "major" ]
then
  echo "Upping package version to a major release"
  npm --no-git-tag-version version major
elif [ "$SANITIZED_VERSION" == "minor" ]
then
  echo "Upping package version to a minor release"
  npm --no-git-tag-version version minor
elif [ "$SANITIZED_VERSION" == "patch" ]
then
  echo "Upping package version to a patch release"
  npm --no-git-tag-version version patch
else
  echo "Unrecognized release type, shutting down"
  exit 1
fi

echo "Upped package version"

SANITIZED_BUILD_COMMAND=$(trim $BUILD_COMMAND)
SANITIZED_REPO=$(trim $REPO)

if [ ${#SANITIZED_BUILD_COMMAND} -ge 0 ]
then
  echo "Starting build of ${SANITIZED_REPO}"
  eval $BUILD_COMMAND
  echo "Build complete"
else
  echo "No build command given"
fi

# Get the package version from the package.json to make git tag
PACKAGE_VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g')

SANITIZED_PACKAGE_VERSION=$(trim $PACKAGE_VERSION)

git add .
git commit -m "Updating ${SANITIZED_REPO} to v${SANITIZED_PACKAGE_VERSION}"
git push origin master

echo "Creating new release on GitHub for v${SANITIZED_PACKAGE_VERSION}"

SANITIZED_ACCESS_TOKEN=$(trim $ACCESS_TOKEN)

curl -X POST \
  https://api.github.com/repos/${SANITIZED_REPO}/releases \
  -H 'Authorization: Bearer '"$SANITIZED_ACCESS_TOKEN"'' \
  -H 'Content-Type: application/json' \
  -H 'User-Agent: request' \
  -d '{
	"tag_name": "release/v'"$SANITIZED_PACKAGE_VERSION"'",
	"body": "Updated '"$SANITIZED_REPO"' to v'"$SANITIZED_PACKAGE_VERSION"'",
	"name": "v'"$SANITIZED_PACKAGE_VERSION"'"
  }'

echo "Successfully released v${SANITIZED_PACKAGE_VERSION}"
