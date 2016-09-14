DevOpsDays Singapore 2016 Ansible Workshop
------------------------------------------

## Introduction

While the workshop should be informative and useful if you
can't run Ansible on the day, being able to try commands as we go along
will likely aid memory and allow more interaction.

If the instructions below aren't clear, please raise an
[Issue](https://github.com/willthames/devops-singapore-2016/issues) 
(or better still a [Pull Request](https://github.com/willthames/devops-singapore-2016/pulls)) 
against thse instructions.

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

#### Ensure hardware virtualization is enabled

* http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/

#### Install Virtualbox and vagrant

##### OS X, Windows
* Download and install Virtualbox for your
  OS from https://www.virtualbox.org/wiki/Downloads
* Download and install vagrant from
  https://www.vagrantup.com/downloads.html
* Install the vbguest vagrant plugin:
  ```
  vagrant plugin install vagrant-vbguest
  ```


##### Fedora, Ubuntu etc.

* Fedora:
    - http://danilodellaquila.com/en/blog/vagrant-and-virtualbox-installation-on-fedora
    - http://jantz.cc/configure-fedora-23-firewalld-to-allow-nfs-vagrant/802/
* Ubuntu:
    - https://www.olindata.com/blog/2014/07/installing-vagrant-and-virtual-box-ubuntu-1404-lts


#### Download the workshop resources

Download and extract:
https://github.com/willthames/devops-singapore-2016/archive/master.zip

#### Create VMs

From the workshop resources directory (on Windows, Shift+Right Click
on a folder will give you an option to open a command prompt in that
directory), run:
```
cd vagrant
vagrant up --provision target
vagrant up --provision control
vagrant reload --provision target
```
on the command line. (The order here allows the control
node to get its ssh key onto the target, before turning
off password access on the target node again)

##### Troubleshooting

If you see:

```
The box 'centos/7' could not be found or
could not be accessed in the remote catalog. If this is a private
box on HashiCorp's Atlas, please verify you're logged in via
`vagrant login`. Also, please double-check the name. The expanded
URL and error message are shown below:

URL: ["https://atlas.hashicorp.com/centos/7"]
Error:
```

you may need to install
[Visual C++ runtime](http://www.microsoft.com/en-us/download/details.aspx?id=8328)
(see https://github.com/mitchellh/vagrant/issues/6754)

#### Check that first VM can control second VM

On windows, if you don't already have a command-line ssh client, download and install
git from https://git-scm.com/downloads. When installing, 
ensure that the 'Git Bash here' option is ticked. 

From the workshop resources directory (use Shift + Right click to get Git 
Bash here on the folder in windows), run:
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
cd devops-singapore-2016/ansible
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
