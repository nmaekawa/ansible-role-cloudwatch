#!/bin/bash

namespace="{{ cloudwatch_namespace | default('CustomMetrics', true) }}"
region="{{ ansible_ec2_placement_region }}"
instance_id="{{ ansible_ec2_instance_id }}"




