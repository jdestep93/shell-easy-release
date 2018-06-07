# shell-easy-release
A shell script to easily cut a release and/or build repository on Github
## Shell Easy Release

This shell script lets you easily cut a new release of a repository on Github without having to go through the hassle of using the UI to create a tag.  This script will tag and release for you.  Just specify the `owner/repo`, your build command if you run a build on the repo (you can even use `yarn` commands to build), the release specification (major, minor, or patch) and provide your Github bearer token and let the script do the rest!