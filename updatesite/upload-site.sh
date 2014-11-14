#!/bin/bash

#####################################################################
# Upload to the soctrace-inria website the eclipse update site for a
# given module.
#
# Author: Generoso Pagano
#####################################################################

# Configuration

#####################################################################
# In the functions below we work under the hypothesis that the script
# is in the update site directory.
#####################################################################

# script directory == update site directory
UPDATESITE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# update site content
SITE_CONTENT="features plugins artifacts.jar content.jar"

# projects
PROJECTS="framesoc ocelotl framesoc.importers"

# print the help
function help() {
    echo ""
    echo "Usage: ./upload-site.sh LOCAL_SITE PROJECT"
    echo "LOCAL_SITE : absolute path of the directory containing the Eclipse update site content (${SITE_CONTENT})"
    echo "PROJECT : one of {$PROJECTS}"
    echo ""
    exit
}

# verify if the string in $2 is contained in the list $1
function contains () {
    local e
    for e in $1; do [[ $e == $2 ]] && return 1; done
    return 0
}

# main function
function main() {
    
    if [ $# != 2 ] ; then
	echo "Error: wrong number of arguments."
	help
    fi

    LOCAL_SITE=$1
    PROJECT=$2

    if [ ! -d "$LOCAL_SITE" ]; then
	echo "Error: directory $LOCAL_SITE does not exist."
	help
    fi

    contains "${PROJECTS}" "${PROJECT}"
    if [ $? -eq 0 ]; then
	echo "Error: project $PROJECT is unknown"
	help
    fi

    echo "* Removing the old update site for project $PROJECT"
    rm -rf $PROJECT/*

    echo "* Copying the new update site content"
    for OBJ in $SITE_CONTENT; do
	cp -r "${LOCAL_SITE}/${OBJ}" "${PROJECT}"
    done

    echo "* Uploading modifications"

    git add --all
    git commit -m "Upload update site for ${PROJECT}"
    git pull
    git push

    if [ $? -ne 0 ]; then
	echo "An error occurred while uploading the site"
    fi

}

###############

OLD_DIR=`pwd`
cd "${UPDATESITE_DIR}"

main $@

cd "${OLD_DIR}"

##############
