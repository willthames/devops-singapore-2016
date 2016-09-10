DevOpsDays Singapore 2016 Ansible Workshop
------------------------------------------

## Introduction

While the workshop should be informative and useful if you
can't run Ansible on the day, being able to try commands as we go along
will likely aid memory and allow more interaction.

## Requirements

* One control node - this can be your laptop
  if you're running OS X or Linux. The control node should have the following
  installed:
    - ansible 2.1
    - git
* One target node - this should probably be a fresh VM on your laptop.
  The accompanying playbooks will run best against Fedora/CentOS/RHEL etc.
  but require minor tweaks for Debian/Ubuntu etc. The target host should
  have a local account that you can ssh as without password using SSH keys,
  and that acount should be able to sudo as root without password.

### Easy setup

This is intended for people who are running windows or who want a simple
way to create the necessary VMs.

#### Install Virtualbox

Download and install Virtualbox for your
OS from https://www.virtualbox.org/wiki/Downloads

#### Install vagrant

Download and install vagrant for your OS from
https://www.vagrantup.com/downloads.html

#### Download the workshop resources

Download and extract:
TODO


#### Create VMs

From the workshop resources directory, run:
```
vagrant up
```
on the command line.


#### Check that first VM can control second VM

From the workshop resources directory, run:
```
vagrant ssh control
```

From the control node, run:
```
ansible -m ping target
ansible -m command -a whoami -b
```

### Self installation

On your control node:

```
cd workingdir
git clone https://github.com/willthames/devops-singapore-2016
cd devops-singapore-2016
TARGET=_INSERT_IP_ADDRESS_OF_TARGET_HOST_HERE_
USER=_INSERT_USERNAME_FOR_TARGET_HOST_HERE_
echo > inventory/target << EOF
[web]
target ansible_host=$TARGET ansible_user=$USER
EOF
```

Then the following should work

```
ansible -m ping target
ansible -m command -a whoami -b
```
