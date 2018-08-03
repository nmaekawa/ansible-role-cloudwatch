cloudwatch
=========
Simplest cloudwatch metrics for free disk percentage.


requirements
------------

A Debian-based system with `apt` installed.



example playbook
----------------

    - hosts: all
      roles:
         - { role: ansible-role-apt, apt_required_packages: ['htop'], apt_other_packages }

license
-------

MIT


