cloudwatch
=========
Simplest cloudwatch metrics for free disk percentage.


requirements
------------

`cloudwatch_user` where the cronjob to send disk metrics is registered must
already exist.

this role creates a policy for instance-profile to allow instance to post
metrics to cloudwach service. The policy uses `permission_name` as the prefix
to name the policy.



example playbook
----------------

    - hosts: all
      import_role:
          name: ansible-role-cloudwatch
      vars:
          cloudwatch_user: myuser
          permission_name: cloudwatch_prefix


license
-------

MIT


