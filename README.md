<p align="center">
  <img width="150" height="150" src="https://raw.githubusercontent.com/charlyie/updatable-bashrc/main/icon.png">
</p>

# Updatable-Bashrc


*Updatable-Bashrc is a .bashrc profile which can be upgraded through GIT releases. It brings multiple useful aliases and functions to save time. It can be customized by using overriding files locally which won't be upgraded on a further release.*


## Usage

Just checkout this GIT repo and replace your ~/.bashrc or /etc/bash.bashrc if you want all your linux users profit of this configuration.

## File explanation

### .bashrc

The main profile file.

### .aliases.ubrc

Contains a list of aliases brought from this repo. It should not be edited as the upgrade process will try to replace this file, if a new version is released.

### .functions.ubrc

Contains a list of functions brought from this repo. It should not be edited as the upgrade process will try to replace this file, if a new version is released.

### .custom.bashrc

You can place here your own aliases. This file won't be replaced after a version upgrade.


## Prerequisites
The daemon needs some packages such as :
* curl
* jq

At first launch, it will try to install them automatically.

The installation process has been successfully tested on Debian/Ubuntu distributions.

## Contributing

Please feel free to contribute by submitting enhancement or new aliases

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/charlyie/updatable-bashrc/tags). 

### Changelog

* **1.0.0** [aug 2021] : A fully usable version
* **0.1.0** [aug 2021] : A work in progress version began in 2017