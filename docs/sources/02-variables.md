% Part 2: Ansible and variables

---

# Variables

* In general logic should be the same
  (or similar) for all environments.
* Variables fill in the contents of template
  files, can be used for the source of files,
  and to choose whether or not to perform a
  task (to name some reasons)
* Fewer variations in configuration sources
  reduces likelihood of errors (Don't Repeat
  Yourself)

---

# Roles `defaults/main.yml`

We'll talk about roles in part 3, but roles can
set default values for variables, and these
are available to the rest of the playbook.

---

# Inventory

* Inventory is used to define the hierarchy of hosts and the groups to which
  they belong.
* The inventory source can be a file, or a script, or a directory containing
  such files and scripts.
* Ansible also sources host variables and group variables from `host_vars`
  and `group_vars` stored in the inventory directory

---

# Inventory inheritance
* Inventory variables take precedence the closer they are to the host.
* Host variables override group variables
* Child group variables override their parents
* This means you can set defaults in top level groups, and override them lower
  down (e.g. the default log level for an application might be WARN, but in
  development it should be DEBUG).

---

# ansible-inventory-grapher

* Use ansible-inventory-grapher (`pip install ansible-inventory-grapher`) along
  with graphviz to help visualize inventory hierarchies:

```
ansible-inventory-grapher -q target | \
  dot -Tpng | display png:-
```

---

# ansible-inventory-grapher demo

Run

```
ansible-playbook playbooks/simple/add-inventory-graph.yml
```

Visit [http://192.168.33.11:8000/target.png](http://192.168.33.11:8000/target.png)

---

# ansible-inventory-grapher result

![inventory-grapher example](images/target.png)

---

# Best practices: inventory

* Set `hosts_file` in the ansible configuration
  file to a directory
* Each file in that directory can be an independent
  part of the inventory
* Inventory scripts can also live in that directory
* That directory can contain `host_vars` and `group_vars`

---

# Best practices: `host_vars`

* Host variables should be used only for things that will only be true
  for a single host.  An example of this might be caching of a UUID of
  a host, or setting kerberos keytabs

* This means that SSL certificates and keys,
  kerberos keytabs, server uuids etc. might be
  candidates, but most other inventory variables
  will be properties of groups.

---

# Anti-pattern: variables in host files

* Variables should not be stored in inventory host
  files (using `[group:vars]` or `[host:vars]` mechanism)
  &mdash; the inventory files should be used for group
  contents and hierarchy definitions (using `[group:children]`).
* Use `group_vars` instead, or `host_vars` at a push.

---

# Playbook vars and vars_prompt

In general playbooks shouldn't need to define
vars, but the capability exists.

`vars_prompt` is useful if you need to provide
a variable at run time &mdash; e.g. a password for a
service and don't want to
source it from a vaulted file.

# `vars_prompt` example

```
- hosts: certificate_authority

  vars_prompt:
  - name: ca_password
    prompt: "Please enter your CA password"

  tasks:
  - name: sign certificate
    command: openssl ca -in req.pem \
      -out newcert.pem -passin env:CA_PASSWD
    environment:
      CA_PASSWD: "{{ ca_password }}"
```

---

# `register`ed variables

* `register`ed variables used to store the
   results of a task in a playbook.

```
   - name: get stat data for file
     stat:
       path: /path/to/file
     register: stat_file

   - name: fail if path doesn't exist
     fail:
       msg: "File does not exist"
     when: not stat_file.stat.exists
```

---

# Facts

* Information about a host sourced
  at runtime, e.g. IP address or OS version.

* You don't need to run the `setup` module
  directly to gather facts &mdash; it is always run
  in playbook mode, unless `gather_facts` is
  set to `False`

* If you ran the previous lab, you should be able
  to see the facts for `target` at [http://192.168.33.11:8000/](http://192.168.33.11:8000/)

---

# `set_fact` module

* The `set_fact` module is used to derive new
  facts from existing facts to produce more
  useful ones.

```
  - name: set timezone fact
    set_fact:
    args:
      timezone: "{{ ansible_date_time.tz }}"
```

---

# `set_fact` examples

If `os_version` is the fact obtained by
joining `ansible_distribution` with
`ansible_distribution_major_version` then:

* The following will look under the `vars`
  directory of a role for a file called e.g. `CentOS7.yml`

```
  - name: include variables based on OS version
    include_vars: "{{ os_version }}.yml"
```

* The following will look under the `tasks`
  directory of a role for a file called e.g. `CentOS7.yml`

```
  - name: run tasks based on OS version
    include: "{{ os_version }}.yml"
```


---

# `include_vars` and `vars_files`

* Use `include_vars` to include a variables
  file as a task in a playbook run. You can use
  `no_log` to ensure vars aren't logged.

* You can also use `vars_files` in a playbook
  to include one or more variables files.
  `vars_files` can't be used in a role.

---

# Role `vars/main.yml`

* Use roles vars/main.yml when you want to
   override another role's defaults.

---

# Extra vars `-e`

* Command line extra vars are useful for
  setting configuration at run-time.
* Set lots of variables at once by including
  a variables file using `-e @filename.yml` &mdash;
  can be useful for overriding defaults during
  an outage.

---

# Variable precedence

The order of variables presented has been
in increasing order. There are more variable
types than presented here &mdash; others aren't
widely used or highly recommended

See more: [Ansible Variable precedence](http://docs.ansible.com/ansible/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)

---

# Secret variables

ansible provides a tool called `ansible-vault`
for encrypting secret variables. while other
tools are available, the vault is usefully
integrated.

---

# ansible-vault

* create: `ansible-vault create secrets.yml`
* edit: `ansible-vault edit secrets.yml`
* view: `ansible-vault view secrets.yml`
* encrypt existing file: `ansible-vault encrypt secrets.yml`
* decrypt existing file: `ansible-vault encrypt secrets.yml`
* change password: `ansible-vault rekey secrets.yml`

see more: [ansible vault](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault)

---

# Using vaulted secrets

```
ansible-playbook playbook.yml --ask-vault-pass
```

you can also set the password in a file (e.g. `~/.ansible/vault_pass`)
and use:

```
ansible-playbook playbook.yml --vault-password-file ~/.ansible/vault_pass
```

or set the `ANSIBLE_VAULT_PASSWORD_FILE` environment variable.

---

# Lab

* Create a playbook on control that
    - uses the debug task to show amount of memory free on the target host
    - runs a debug task if a variable `run_me` is set.
    - Stores the contents of the results of listing the directory of `httpd_directory`

---

# End of Part 2

[Proceed to Part 3](03-roles.html)
