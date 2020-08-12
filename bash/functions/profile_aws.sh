#!/bin/bash

# Sets the AWS_PROFILE environment variable to the specified argument
function profile_aws() {
    export AWS_PROFILE="$1"
}
