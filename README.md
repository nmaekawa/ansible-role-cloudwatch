cloudwatch
=========
Simplest cloudwatch metrics scripts for free disk percentage.


requirements for disk metrics
------------------------

This role does not grant any permission to the instance to access cloudwatch
service. For that check [ansible-role-iam-instance-profile]
(https://github.com/nmaekawa/ansible-role-iam-instance-profile)

`script_install_dir` dir where scripts to put metrics to cloudwatch are copied.
This dir also will contain scripts for backups, if you run tasks to install
backups to s3 -- see below. Scripts are owned by root, but executable by all.

`cronjob_owner` user to register the cronjob to put metrics into cloudwatch
(user is not create by this role!)

`cloudwatch_namespace` aws namespace for metrics being installed. Defaults to
"Custom Metrics"


requirements to copy to s3
--------------------------

This role also has tasks to install jobs to copy files to an s3 bucket (for
backups) and to sync folders from an s3 bucket (copy from s3 to local filesys).
These extra tasks assume that the cloudwatch role is already applied to the
managed host (i.e. you cannot install copy to s3 without installing disk
metrics).

The copy task is meant to save a list of files (say, things like
"/var/log/nginx/access.log" and "/var/log/syslog.1", into an s3 bucket, compressing
each before sending to s3.

Same requirements for disk metrics plus:

`s3_backup_bucket_name` s3 bucket name where the files are copied, ex: 'backup'

`s3_backup_prefix` a prefix to add to the s3 object, ex: 'prod/project/mytests'

`file_backup_prefix` yet another prefix to add to the copied s3 object, ex:
'webservice'. The final copied s3 object would look something like
"s3://backup/prod/project/mystests/webservice_original-filename.ext.gz"

`files_to_backup` list of fullpath local files to be copied to s3. See examples
below.


requirements to sync from s3
----------------------------

The sync task is meant to keep local files in sync with an s3 bucket/prefix.
The s3 bucket acts as a source to distribute files.
This extra task assumes that the cloudwatch role is already applied to the
managed host (i.e. you cannot install sync from s3 without installing disk

Same requirements for disk metrics plus:

`s3_sync_bucket_name` s3 bucket name from which to sync local filesys

`s3_sync_prefix` prefix of source s3 objects to be sync'd from

`target_s3_sync_dir` fullpath of local dir to be sync'd from s3


example playbook
----------------

    - hosts: all
      tasks:
        - import_role:
            name: ansible-role-cloudwatch
        vars:
            script_install_dir: /usr/local/bin
            cronjob_owner: cloudwatch
            cloudwatch_namespace: "MyOrganization/CustomMetricsForServiceX"

        # for this example, cronjob_user has to be "root" because it needs
        # permission to access "syslog.1"; and it copies "syslog.1" because it
        # is sure to be a file that is already logrotate'd and not being
        # written anymore.
        - import_tasks: roles/ansible-role-cloudwatch/tasks/install_s3_backup.yml
          vars:
            script_install_dir: /usr/local/bin
            cronjob_owner: root
            s3_backup_bucket_name: "backup"
            s3_backup_prefix: "prod/project/mytests"
            file_backup_prefix: "webservice"
            files_to_backup:
                - /var/log/syslog.1
                - /var/log/nginx/access.log
                - /var/log/nginx/error.log

        - import_tasks: roles/ansible-role-cloudwatch/tasks/install_s3_sync.yml
          vars:
            script_install_dir: /usr/local/bin
            cronjob_owner: root
            s3_sync_bucket_name: "source-dist"
            s3_sync_prefix: "prod/project/mytests/files-to-distribute"
            target_s3_sync_dir: "/opt/project/important-files"


license
-------

MIT


