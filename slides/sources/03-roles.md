% Part 3: Roles

---

# What is a role

* Roles can do most of the things that playbooks
  do - run tasks and handlers, install files or
  write templates, set variables
* Allows reusable implementation of common
  patterns.
* Examples include roles that install database
  engines (mysql, postgresql etc.), web servers
  (apache, nginx) and many more.

---

# Why do we have roles

* Roles should implement best practices
  (e.g. an apache role that enforced secure
  SSL ciphers)
* If more than one playbook might do
  something in the same way, that should
  be abstracted to a role

---

# Where do roles come from

* Ansible Galaxy (https://galaxy.ansible.com/) -
  there are 1000s of roles suitable for most
  operating systems.
* `ansible-galaxy init new-role` creates a role
  skeleton

---

# Ansible role skeleton

```
testrole/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```


---

# Installing a role

* Best practice is to use a requirements.yml containing
  the specification of the role you wish to use. This
  can be from [Ansible Galaxy](https://galaxy.ansible.com)
  or from github or your own internal source repository.

---

# requirements.yml

* The following are effectively equivalent:

    ```
    - src: geerlingguy.mysql

    - src: https://github.com/geerlingguy/ansible-role-mysql
      version: 2.4.0
      name: mysql
      scm: git
    ```

The latter mechanism is more useful for roles that don't come
from galaxy.

---

# Installing a role

The roles are then installed using

```
ansible-galaxy install -r playbooks/application/env/requirements.yml -p playbooks/application/env/roles -f
```

---

# Using a role

* Read the README file to see what variables are expected, and
  then set them appropriately in inventory.

* Rather than a bunch of tasks, your playbook might then look
  like

  ```
  - hosts: appserver

    roles:
    - mysql
    - nginx
    - application
  ```

  where `application` might be your role that installs your
  own application

---

# Creating new roles

- We use Ansible's [Galaxy](http://docs.ansible.com/galaxy.html) functionality
  for managing internal roles (`ansible-galaxy init` for creating new roles,
  `ansible-galaxy install` for installing existing roles)
- Each role has its own source control repo
- Each application-environment combination gets its own roles file used to provide
  roles for the playbooks
- The roles directories for the playbooks are ignored by git


---

# Versioning roles

There are some good reasons to version roles:
* Allows safe development of roles without enforcing strict backward
  compatibility - older playbooks can continue to use older versions
  of a role until it is ready to upgrade.
* Versioning allows repeatability - if the same playbook with the same rolesfile
  is used in 6 months time, it should work in exactly the same way. This would
  not be the case if a playbook just used the latest versions of the role.

---

# How we version roles

- Production playbooks must use versioned roles
- Production roles must have versions.
- Once a change to a role has passed code review and is accepted on
  the master branch:

```
git pull upstream master
git tag v2.3
git push upstream v2.3
```

---

# Lab

Using a [suitable mysql role](https://galaxy.ansible.com/resmo/mysql/)
from galaxy.ansible.com,
install and configure a database called catalogue:

```
database_name: shop
database_user: shop
database_password: sh0p
```

A starting playbook exists in playbooks/with_roles/install_db.yml, you'll need
to install the role, and set up the inventory.

---

# End of Part 3

[Proceed to Part 4](04-tools.html)
