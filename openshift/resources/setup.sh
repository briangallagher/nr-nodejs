#!/bin/bash

#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 NAMESPACE"
    exit 1
fi

NAMESPACE=$1

# TODO: Need to review all the resources that the template creates. Not sure if all needed, in particular the build config
oc apply -f ../templates/nodejs-app-dev.json -n $NAMESPACE

# Confirm template exists in nr-dev
oc get templates -n nr-dev
oc new-app --template nodejs-app -p NAMESPACE=nr-dev -p SOURCE_REPOSITORY_URL=https://github.com/briangallagher/nr-nodejs.git -n $NAMESPACE


# Create a pipeline Build Config for the pipeline 
# TODO: pipelineBuildConfig.yml should possibly be in with generic templates
oc process -f ../templates/pipelineBuildConfig.yml -p LABEL_APP_NAME=nr-nodejs -p JENKINS_FILENAME=./openshift/pipeline/JenkinsFile -p GIT_URL=https://github.com/briangallagher/nr-nodejs.git | oc create -f - -n nr-jenkins

# TODO:
# What about resources on test and prod environments ?? 


# NOTES:
# **To add the template into openshift:**
# `oc create -f pipeline-bc-from-git-template.yaml -n openshift`
# You can the use the _Add to Project_ menu to process the template.
# **To process the template and create the objects into openshift manually:**
# `oc process pipeline-bc-from-git-template.yaml -p <param-name1>=<value1> -p <param-name2>=<value2> ... | oc create -f - -n <namespace> | oc create -f - -n <namespace>`
