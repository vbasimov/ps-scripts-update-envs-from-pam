# ps-scripts-update-envs-from-pam
Windows Powershell scripts for updating Enviroment Varialbles (*.json)

![ps](https://img.shields.io/badge/Powershell-2CA5E0?style=for-the-badge&logo=powershell&logoColor=white)
![win](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![gitlab](https://img.shields.io/badge/GitLab-330F63?style=for-the-badge&logo=gitlab&logoColor=white)



- *Arguments:*

  - `config`: List of paths to environments files. You can store env congfigurations files anywhere on your windows server host. Just provide paths as arguments.

  - `restart`: 1 or 0. Set 1 if restart required.

- *Command line:*

   - `powershell -Command .\configure.ps1 -config config1.json, config2.json 1`

- *configuration example file:*
  - [example.json](/example.json)

- GitLab CI (NOT GitHub):
  - To use GitLab CI you need to store project as GitLab repository.
  - You can use GitLab-CI pipeline to run script. Just see and edit [gitlab-ci.yaml](/.gitlab-ci.yaml)
  - You should configure gitlab-runner for your project at your server. [Tutorial](https://docs.gitlab.com/runner/install/windows.html)
  - You can store enviroment configs in GitLab ENVS (set type "file" and place filled [example.json](/example.json) there.
---
You can use this code at your own risk.
