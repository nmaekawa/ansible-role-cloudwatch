#!/bin/bash
# run this from ansible provisioning host (local action)

# creates base instance profile _without_ any meaningful policy!
# exits with error if instance profile name already exists

ERROR_MISSING_ARGUMENTS=15
ERROR_CREATING_INSTANCE_PROFILE=14
ERROR_CREATING_ROLE=10
ERROR_ADDING_ROLE_TO_INSTANCE_PROFILE=16
ERROR_INSTANCE_PROFILE_ALREADY_EXISTS=17

AWS_PROFILE=$1
ROLE_NAME=$2
INSTANCE_PROFILE_NAME=$3

if [ $# -lt 3 ]
then
    echo "$0 <aws_profile> <role_name> <instance_profile_name>"
    exit $ERROR_MISSING_ARGUMENTS
fi

echo "aws_profile is $AWS_PROFILE"
echo "role name is $ROLE_NAME"
echo "instance_profile name is $INSTANCE_PROFILE_NAME"


# check if instance_profile already exists
INSTANCE_PROFILE=$(aws iam get-instance-profile \
    --instance-profile-name "${INSTANCE_PROFILE_NAME}" \
    --profile "${AWS_PROFILE}" \
    | jq '.InstanceProfile.InstanceProfileName' | sed 's/"//g')

if [ $? -eq 0 ]; then
    # create instance profile
    INSTANCE_PROFILE=$(aws iam create-instance-profile \
        --instance-profile-name "${INSTANCE_PROFILE_NAME}" \
        --profile "${AWS_PROFILE}" \
        | jq '.InstanceProfile.InstanceProfileName' | sed 's/"//g')
    if [ $? -ne 0 ]; then
        exit $ERROR_CREATING_INSTANCE_PROFILE
    fi
else
    exit $ERROR_INSTANCE_PROFILE_ALREADY_EXISTS
fi

# check if role already exists
ROLE=$(aws iam get-role \
    --role-name "${ROLE_NAME}" \
    | jq '.Role.RoleName' | sed 's/"//g')

if [ $? -ne 0 ]; then
    # create role
    ROLE=$(aws iam create-role \
        --role-name "${ROLE_NAME}" \
        --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["ec2.amazonaws.com"]},"Action":["sts:AssumeRole"]}]}' \
        --profile "${AWS_PROFILE}")
    if [ $? -ne 0 ]; then
        exit $ERROR_CREATING_ROLE
    fi
fi

# add role to instance profile
ADD_ROLE_TO_INSTANCE_PROFILE=$(aws iam add-role-to-instance-profile \
    --role-name "${ROLE_NAME}" \
    --instance-profile-name "${INSTANCE_PROFILE_NAME}" \
    --profile "${AWS_PROFILE}")

if [ $? -ne 0 ]; then
    exit $ERROR_ADDING_ROLE_TO_INSTANCE_PROFILE
fi

echo "${INSTANCE_PROFILE}"


