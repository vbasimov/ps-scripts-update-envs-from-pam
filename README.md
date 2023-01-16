# ps-scripts-update-envs-from-pam
[for GitLab CI]: Windows Powershell scripts for updating Enviroment Varialbles (*.json) from gitlab ENVS by GitLab-CI pipeline.
---

- *Arguments:*

  - `config`: List of paths to environments files. You can store env congfigurations files anywhere on your windows server host. Just provide paths as arguments.

  - `restart`: 1 or 0. Set 1 if restart required.

- *commandline:*

   - `powershell -Command .\configure.ps1 -config config1.json, config2.json 1`

- *configuration example file:*
  - [example.json](/example.json)

---
You can use this code at your own risk.
