# Ansible From Zero to Best Practices

By Will Thames:

* Senior Systems Engineer, Red Hat Brisbane
* Contributor to Ansible
* Developer of [ansible-lint](https://github.com/ansible-lint),
  [ansible-review](https://github.com/ansible-review), and
  [ansible-inventory-grapher](https://github.com/ansible-inventory-grapher)
* Mostly ansible-related blog at [https://willthames.github.io/](https://willthames.github.io/)

---


# About this talk (1)

* Part 1: Introduction to Ansible
* [Part 2: Ansible and variables](02-variables.html)
* [Part 3: Ansible and roles](03-roles.html)
* [Part 4: Ansible tools for best practices](04-tools.html)

---

# About this talk (2)

* This workshop is untested (sorry)
* There might be mistakes
* There might be missing information

* Available online at
  [https://willthames.github.io/devops-singapore-2016/](https://willthames.github.io/devops-singapore-2016/)

---

# Introduction to Ansible

* What is Ansible
* Why use Ansible
* Basic concepts
* Demo/Lab

---

# What is Ansible

* Configuration Management and Orchestration
  tool
* Repeatably put systems into a desired
  state
    - files
    - packages
    - services
    - ...

---

# Why use Ansible (1)

* Easy to install
    - control machine needs ssh and python
    - target machine needs ssh (and preferably python)
    - no agents other than ssh required
* No complicated access control
    - if you can ssh to a target, you can run
      ansible against it with your privileges
    - you only get root power if you already
      have root access

---

# Why use Ansible (2)

* Easy to do easy things with
* Not much harder to do hard things with
* Usually easy for others to understand what
  is going on

---

# Getting up and running with Ansible

* Install Ansible
  - RHEL/CentOS/Fedora: `yum install ansible`
  - OS X: `brew install ansible`
  - Windows: doesn't install directly - use a VM or cygwin
  - Most platforms: `pip install ansible`

---

# Setting up target hosts

Ansible is most easily used if you can ssh
as a normal user to a host without a password, and then
sudo to root without a password.

---

# Setting up ssh keys

```
ssh-keygen -f ansible
ssh-add ~/.ssh/ansible
ssh-copy-id -f ~/.ssh/ansible $targethost
```

---

# Setting up sudo

```
echo "ansible_user (ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
```

In some cases you will want to lock this down
further, perhaps with a password (you can enter a sudo password
if you add `-K` to your command line).

---

# Basic Concepts

* Modules
* Playbooks
* Tasks
* Templates
* Handlers
* Variables ([Part 2](02-variables.html))
* Inventory ([Part 2](02-variables.html))
* Roles ([Part 3](03-roles.html))

---

# Modules

* A single module allows the execution of a
  self-contained task.

* There are modules for an awful lot of things - 
  e.g.:
    * configuring services in AWS
    * installing OS packages
    * writing to files
    * updating network devices
    * configuring databases
    * and many others...

See the [Ansible Module Index](docs.ansible.com/ansible/modules_by_category.html) for a full list of categories.

---

# Example

Using the `ansible` command line, it's easy to
run a simple module to get all of the facts from a repo

```
ansible -m setup target
```

or run an ad-hoc task

```
ansible -m file -a "state=directory path=~/throwaway" target
```

---

# Playbooks

A playbook is, at its simplest, a list of tasks to run in
sequence against a list of hosts. The `setup` task is
run first.

```
- hosts: target

  tasks:
  - name: ensure ~/throwaway doesn't exist
    file:
      path: ~/throwaway
      state: absent
```

# Tasks

A task comprises the module to run and the
arguments with which to run the task.

There are also several modifiers to the
task, determining whether it is run,
who it is run by, where it is run, and
others.

---

# Naming tasks

Best practices suggest always naming tasks -
it's easier to follow what is happening if the
tasks are well named.

The task in the previous playbook looks like
this when named:

```
TASK [ensure ~/throwaway doesn't exist] ****************************************
ok: [target]
```

and when not named:

```
TASK [file] ********************************************************************
ok: [target]
```

---

# Task modifiers: when

You can tell a task to run only if certain conditions are met.

```
- name: install httpd (Red Hat)
  yum:
    name: httpd
  when: 'ansible_distribution == "RedHat"'

- name: install apache (Debian)
  apt:
    name: apache2
  when: 'ansible_distribution == "Debian"'
```

See more: [Ansible Conditionals](http://docs.ansible.com/ansible/playbooks_conditionals.html)

---

# Task modifiers: `with_items` etc.

A task can loop over a list of items (or indeed many other kinds of data structures).
For example, you can provide a list of packages for apt or yum to install, or
a list of definitions of database users (username, password, privileges etc).

See more: [Ansible Loops](http://docs.ansible.com/ansible/playbooks_loops.html)

---

# `with_items` example
```
- name: add database users
  mysql_user:
  - name: "{{ item.name }}"
    password: "{{ item.password }}"
  with_items:
  - name: bob
    password: abc123
  - name: sys
    password: superSekrit!
```

---

# Task modifiers: `become`

The `become` modifiers are useful when you need a task to run
as a different user to the rest of the playbook. Security best
practices suggest using a standard user for most tasks and
elevating privilege when required - but even if you're running
the playbook as root, you might need to become e.g. the `postgres`
user to run a DB related task.

See more: [Become](http://docs.ansible.com/ansible/become.html)

---

# `become` example

```
- name: install package
  yum:
    name: httpd
  become: yes

- name: connect to the database
  command: psql -U postgres 'select * from pg_stat_activity()'
  become_user: postgres
```

---

# Best practices: YAML

Note that the previous task could be written

```
    file: path=~/throwaway state=absent
```

Ansible have said that the preferred format is
the YAML dictionary format, as the key=value
form can lead to strange errors (we'll see this
later with the `--syntax-check`er)

---

# Structuring playbooks (1)

There are a number of elements to a playbook,
that can be separated into the following classes
of elements:

* Connection specification: `hosts`, `forks`, `serial`
* User specification: `remote_user`, `become`, `become_user` etc.
* Variable inclusion: `vars`, `vars_files`, `vars_prompt` etc.
* Logic before tasks: `pre_tasks`, `roles`
* Tasks and handlers: `tasks`, `handlers`

---

# Structuring playbooks (2)

Playbooks can also include other playbooks, using `include` at
the play level, or include task files by using the `include` task

```
- hosts: all

  include: another_playbook.yml

  tasks:
  - include: setup.yml
  - include: configure.yml
```

---

# Check Mode

Ansible can be run in test mode using the `-C` or `--check-mode` flags.

```
ansible-playbook -C examples/playbook.yml
```

Because ansible doesn't know if a command will have an effect in
dry run mode, tasks that don't support dry run (particularly
`command` and `shell` tasks) are skipped by default. You can force them to
be run using the `check_mode` flag (previously the `always_run` flag)

---

# Check Mode check example
```
- name: get version of coreutils rpm
  command: rpm -q coreutils
  args:
    warn: no
  changed_when: False
  check_mode: yes
```

You can also do things differently when in check mode
by changing behaviour based upon `when: ansible_check_mode`.

---

# Diff Mode

Diff mode is incredibly useful in conjunction with check mode to see
how a file would change, before the change is made. Diff mode can
be run by passing `-D` or `--diff-mode` to `ansible-playbook`

---

# Repeatability

If a playbook runs twice, the expected result is that nothing
should change on the second run - ansible should report
zero changes.

This should be true whether 10 seconds later, or 10 months later.

---

# Repeatability - command tasks

* In particular, `shell` and `command` will always return `changed: True`. Use
  of `changed_when: False` when running read-only commands is encouraged
  to minimise false alarms:

  ```
    - name: get list of files in a directory
      command: ls /path/to/directory
      register: directory_contents
      changed_when: false
      always_run: true
  ```

---

# Command tasks

* Other means of reducing the amount of unnecessary changes:
    - use `creates` or `removes` with commands to prevent an action happening
      if it's already happened
    - use `when` with a pre-check read-only task (with `changed_when: False`)
      to see if an action needs to happen before
      doing it - e.g.

      ```
        - name: check tuned profile
          command: tuned-adm active
          register: tuned_adm
          changed_when: False

        - name: set tuned profile
          command: tuned-adm profile virtual-guest
          when: "'Current active profile: virtual-guest' not in tuned-adm.stdout"
      ```

---

# Templates

- Templates allow you to generate configuration files from values set in
  various inventory properties. This means that you can store one template in
  source control that applies to many different environments.
- An example might
  be a file specifying database connection information that would have the same
  structure but different values for dev, test and prod environments

```
db.settings={{dbhost}}:{{dbport}}/{{dbuser}}:{{dbpass}}@{{dbschema}}
```

Templates are populated using

```
  - template:
      src: path/to/template.j2
      dest: /path/to/result
```

---

# Best practice: use directory structure with templates

Because configuration files for an application can end
up with similar names in different directories, reflect
the target destination in the source repository

```
- name: configure logrotate
  template:
    src: etc/logrotate.d/httpd.conf.j2
    dest: /etc/logrotate.d/httpd.conf

- name: configure apache
  template:
    src: etc/httpd/conf/httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
    owner: apache
```

---

# Handlers

Handlers are tasks that are 'fired' when a task
makes a change

```
    tasks:
    - name: install httpd configuration file
      template:
        src: etc/httpd/conf/httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: reload apache

    handlers:
    - name: reload apache
      service:
        name: apache
        state: reloaded
```

---

# Handlers

This is another mechanism of ensuring a change
is made only when it needs to be (as if no
change is made to the configuration, the
handler will not fire)

Handlers are run at the end of all tasks -
if you want to run them earlier, you can
use the `meta` task:

```
- meta: flush_handlers
```

---


# Lab

* Hopefully you received and followed the instructions
  to set up your Ansible environment.

* Log on to the control VM

* Have a look in playbooks/simple

* Run the deploy-web-service.yml playbook

* Visit http://192.168.33.11:8000/

---

# Troubleshooting: verbose mode

Adding extra `-v` arguments (using `-v -v -v` or just `-vvv`)
will increase the verbosity of ansible's output.

* No `-v` - just output tasks and plays and whether
  or not it's successful
* `-v` - shows the results of modules
* `-vv` - shows the files from which tasks come
* `-vvv` - shows what commands are being executed under the
  hood on the target machine
* `-vvvv` - shows what callbacks have been loaded
* `-vvvvv` - shows some additional ssh configuration information

---

# Best practice: debug messages

You can (and should) configure your debug messages to appear
only at certain verbosities

```
  debug:
    msg: "This will appear with -vv but not before"
    verbosity: 2
```

---

# Organising playbooks

For any self-contained set of playbooks (this might
be all of your playbooks, or playbooks just for a particular
application), the following is a reasonable directory structure

```
.
├── ansible.cfg
├── inventory
│   └── group_vars
│       └── web
└── playbooks
    ├── simple
    │   ├── deploy-web-service.yml
    │   └── templates
    │       ├── index.html.j2
    │       └── python-web.service.j2
    └── with_roles
```

---

# Organising playbooks

If you need modules or plugins, they can also be installed
in the top level directory. Something like

```
.
├── ansible.cfg
├── inventory
├── library
├── playbooks
└── plugins
    ├── filter
    └── lookup
```

is likely a reasonable setup.

---

# Configuration file

```
[defaults]
hostfile = ./inventory
roles_path = ./roles
library = ./library
filter_plugins = ./plugins/filter
lookup_plugins = ./plugins/lookup
callback_whitelist = profile_tasks,timer
command_warnings = True

[ssh_connection]
pipelining = True
control_path = %(directory)s/ssh-%%h-%%p-%%r
```
