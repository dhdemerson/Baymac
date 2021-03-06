# Baymac - OS X setup companion

Baymac automates tedious setup work on new macs. It installs software, transfers configurations, and executes bootstrap scripts. Simply download and run the `baymac.command` file.

**Baymac is still in active development and is written in Ruby by someone who doesn't know Ruby. Use at your own peril!**

*Pull requests and Ruby wisdom welcome*

## Installation

Right now you need to install the gems `main` and `highline`

Other than that there really is no installation<sup>1</sup> just download the file open the directory and click the `baymac.command` file. Optionally you can start Baymac with parameters from the command line.

<sup>1</sup> Baymac requires Homebrew and Homebrew Cask to work (it will begin installing those for you though)

## Basic Usage
1. **Configure on a computer that is already setup.** Baymac will look at all the installed software on the computer, and offer to automate installation for applications that it can install automatically. Baymac will also offer to copy configurations for installed software using Mackup. *Mackup uses symlinks to restore configurations. If Baymac is in an automatically synced file (Dropbox, Google Drive, iCloud Drive etc.) changes to configurations will be synced across all computers Baymac is synced on.*

2. **Sync Baymac to a new computer.** Using iCloud Drive Baymac can be immediately available when you first setup a new mac with access to your iCloud account. Baymac is entirely self contained so any method of transfering or syncing a directory will work (e.g. flash drive, dropbox, ftp). Be warned that if you allowed Baymac to copy configurations that the configurations might contain sensitive data (e.g. **SSH Keys**) so keep the Baymac directory secure and private.

3. **Setup the new computer.** Baymac will install any software you asked for it to install automatically, transfer configurations, and execute all scripts in the /scripts directory.


## Advanced Usage

### Executing scripts

### Command Line Parameters
```
--verbose=[verbose] (0 ~> boolean(verbose=true))
Show output for all commands

--fast=[fast] (0 ~> boolean(fast=true))
Do not pause after Baymac speaks

--help, -h
```
## Roadmap
### 0.1

* [x] Software scanning and selection
* [x] Software installation
* [x] Save configurations locally using Mackup
* [x] Symlink configurations to home directory using Mackup
* [ ] Package or eliminate dependencies
* [ ] Execute scripts in `/scripts` directory

### 0.2
* [ ] Copying non-configuration files
* [x] Intelligent merging of user choices of multiple scans
* [ ] User selection of which applications to transfer configurations for

### 0.3
* [ ] Detect and present changes made to tracked files

## Contact
Use Github Issues
