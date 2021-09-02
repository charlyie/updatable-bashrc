<p align="center">
  <img width="150" height="150" src="https://raw.githubusercontent.com/charlyie/updatable-bashrc/main/icon.png">
</p>

# Updatable-Bashrc


*Updatable-Bashrc is a .bashrc profile which can be upgraded through GIT releases. It brings multiple useful aliases and functions to save time. It can be customized by using overriding files locally which won't be upgraded on a further release.*


## Installation

1. Just checkout this GIT repo and replace your `~/.bashrc` by the `.bashrc` from the GIT.
2. If you want all your linux users profit of this configuration, replace `/etc/bash.bashrc` by the `.bashrc` from the GIT and remove `~/.bashrc` for each user.
3. Copy also `.aliases.ubrc` and `.functions.ubrc` in the same folder you've paste the main `.bashrc` 

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


## Updates

The **Updatable-Bashrc** will check once a day if a newever version exists. You can manually upgrade this `.bashrc` by typing the command `ubrc_check_update`.
```
Checking for update... 
No update required (remote version is : 1.0.0) 
```

You can check current version by typing `ubrc_version` :
```
Updatable-Bashrc v.1.0.0 (20210819). 
(c) Charles Bourgeaux <charles@resmush.it> 2017-2021
```

## Contributing

Please feel free to contribute by submitting enhancement or new aliases

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/charlyie/updatable-bashrc/tags). 

### Changelog

* **1.3.0** [sep 2021] : Loads local configuration with a wildcard (.*.bashrc`). New function in snippets to reset rights
* **1.2.0** [aug 2021] : Upgrade only for writable users, no output when not in TTY mode
* **1.1.3** [aug 2021] : Fix in lock file, 1 per user.
* **1.1.2** [aug 2021] : Fix in lock write, and exit status.
* **1.1.1** [aug 2021] : Minor fix
* **1.1.0** [aug 2021] : With prefix in string output
* **1.0.0** [aug 2021] : A fully usable version
* **0.1.0** [aug 2021] : A work in progress version began in 2017