cloudwatch
=========
Simplest cloudwatch metrics scripts for free disk percentage.


requirements
------------

`cloudwatch_user` user that register cronjobs to send disk metrics; user must
exist and have a home dir. Cronjob scripts are copied to ~cloudwatch_user/bin;
~cloudwatch_user/bin directory is created if doesn't already exists.

`cloudwatch_namespace` is optional and the default value is "CustomMetrics".

This role does not grant any permission to the instance to access cloudwatch
service. For that check [ansible-role-iam-instance-profile]
(https://github.com/nmaekawa/ansible-role-iam-instance-profile)


example playbook
----------------

    - hosts: all
      import_role:
          name: ansible-role-cloudwatch
      vars:
          cloudwatch_user: myuser
          cloudwatch_namespace: "MyOrganization/CustomMetricsForServiceX"


license
-------

MIT


