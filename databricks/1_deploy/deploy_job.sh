#!/bin/bash

# Access granted under MIT Open Source License: https://en.wikipedia.org/wiki/MIT_License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
# the rights to use, copy, modify, merge, publish, distribute, sublicense, # and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions 
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.
#
#
# Description: Deploy a notebook 
#
# Usage: deploy_job.sh -r "region" -t "token" -j "job conf file" [optional: -p "profile"]
# Example: deploy_job.sh -r "westeurope" -t "dapi58349058ea5230482058" -j "myjob.json"


set -o errexit
#set -o pipefail
set -o nounset
#set -o xtrace

#set path
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

db_region=""
db_token=""
db_job_conf=""
db_cli_profile="DEFAULT"


while getopts r:t:j: option
do
    case "${option}"
    in
        r) db_region=${OPTARG};;
        t) db_token=${OPTARG};;   
        j) db_job_conf=${OPTARG};;   
    esac
done


if [ -z "$db_region" ]
then
    echo "Cluster region wasn't supplied!"
    exit 1
fi

if [ -z "$db_token" ]
then
    echo "Access token wasn't supplied!"
    exit 1
fi

if [ -z "$db_job_conf" ]
then
    echo "Job configuration file wasn't supplied!"
    exit 1
fi

# configure databricks authentication
echo "[${db_cli_profile}]" > ~/.databrickscfg
echo "host = https://${db_region}.azuredatabricks.net" >> ~/.databrickscfg
echo "token = ${db_token}" >> ~/.databrickscfg
echo ""  >> ~/.databrickscfg

# get values from the job config
db_job_name=$(jq -r '.name' "${db_job_conf}")
job_notebook_path=$(jq -r '.notebook_task.notebook_path' "${db_job_conf}")
job_notebook_dir=$(jq -r '.notebook_task.notebook_path' "${db_job_conf}" | cut -d"/" -f2)


# create the directory for the notebooks in the workspace
echo "creaing a folder in the workspace"
databricks --profile "${db_cli_profile}" workspace mkdirs "/${job_notebook_dir}/"

# upload production notebook
echo "uploading notebooks..."    
databricks --profile "${db_cli_profile}" workspace import "../driver_safety.py" "${job_notebook_path}" --language python --overwrite


# look for our job
job_id=$(databricks --profile "${db_cli_profile}" jobs list | grep "${db_job_name}" | cut -d" " -f1)

if [ -n "$job_id" ] 
then
    # if the job already exists we should delete it before recreating it.
    # it's required since we don't know if the job definition has changed or not
    echo "deleting existing job"    
    databricks --profile "${db_cli_profile}" jobs delete --job-id "${job_id}"
fi

# create the job
echo "creating a new job"    
databricks --profile "${db_cli_profile}" jobs create --json-file "${db_job_conf}"

