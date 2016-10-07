% Part 4: Tools

---

# Tools for best practices

* Continuous integration:
    * syntax check
    * `ansible-lint`

* Code review
    * `ansible-review`

---

# Syntax Check

Ansible can check the syntax of a playbook using `--syntax-check` argument.

```
$ ansible-playbook --syntax-check playbooks/simple/broken-syntax.yml
ERROR! Syntax Error while loading YAML.


The error appears to have been in '/home/vagrant/playbooks/simple/broken-syntax.yml': line 5, column 22, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

  - name: this task will fail syntax check
    debug: msg="hello: world"
                     ^ here
```


---

# ansible-lint

`ansible-lint` was developed to find various style and usage issues
with playbooks and roles, and suggest improvements.

There are several categories of rules:

* Using command/shell module instead of Ansible modules
* Deprecated syntax that is being removed by Ansible
* Incorrect formatting

---

# ansible-lint

Every rule is treated as an error &mdash; there is no way to
mark rules as warnings. You can choose to run specific
rules or to exclude specific rules


---

# Code Reviews

Code reviews are essential to maintaining codebase quality. We
use code reviews to check for standards compliance and best practices, and also
to ensure that the change is the right thing to do for future maintenance.

Reviews should be objective - there should be a documented reason for
comments made in a review.

---

# Code Reviews

Code reviews can lead to less code in the codebase. This can be a good thing. By
spotting common patterns, functionality that is in a common role can be removed
from an application role (roles do not need to install apache themselves when
they can rely on the apache role, for example).

Conversely, code that is specific to an application should be kept away from the
more general roles.

---

# Standards and Best Practices

* We keep our standards, best practices, guide to code reviews etc. in version
  control
* Our standards documentation goes through a similar review process to our
  code. This is so that standards are agreed, and not imposed.
* Standards have a version number and a changelog, so that it's obvious what
  standards have been added, improved or even removed over time.

---

# ansible-review

`ansible-review` is designed to apply an automated code
review process to work with an organisation's
standards.

As you add new standards to your style guide,
you can say what version of standards a playbook or role
is designed to meet. This allows older code to not fail
against newer standards.

---

# Running a review

After following the instructions on the
[ansible-review github repo](https://github.com/willthames/ansible-review)
you can run a review tool on just the changes
made against master

This can be run in any ansible repo, against roles or playbooks.
To run against all files in a repo (e.g. for a new role), just
use

```
git ls-files | xargs ansible-review
```

or

```
git diff master | ansible-review
```

---

# End of the Workshop!

Further resources:

* [Ansible Docs](http://docs.ansible.com/ansible/)
* [Ansible source](https://github.com/ansible/ansible)
* [Ansible Mailing list](https://groups.google.com/forum/!ansible-project)
* [Ansible Galaxy](http://galaxy.ansible.com)

---

# Thank you!

Feedback welcomed (positive and negative)

- Twitter: @willthames
- Email: will@thames.id.au

