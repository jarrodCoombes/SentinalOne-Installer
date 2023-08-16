# SentinalOne Installer

## Description

This shell script can be used to to automate the install of the SentinalOne Linux Agent.

This script tries to determine your CPU architecture and package installer type and then
picks the appropriate package to install. Supported architectures are x86_x64 and arm64
in either an RPM or DEB installer type. All 4 SentinalOne packages need to be in the 
install folder.

You can download the needed packages from your SentinelOne Dashboard, but do not forget 
to update this script with the filenames of the packages.
	
   	
There also needs to be a configuration file for the agent install options in the the 
same install folder as the agent install ackages. There are a variety of option you 
can specify in this file. See [this](https://usea1-017.sentinelone.net/docs/en/deploying-the-linux-agent-with-a-configuration-file.html##) page for more details on how to build this config
file (SentinelOne dashboard access is needed to view this page).
	
	
**NOTE: This script must be run with root privileges.**
	
	
## Usage: 
	 
sent_agent_inst [rpm] [deb] [help]

	deb		Specifies that the installer shouls use the DEB package and that you are installing onto a Debian or derivitave distro.
    
	rpm		Specifies that the installer should use the RPM package and that you are isntalling onto a RHL or derivative distro.
    
	help	Brings up this information screen, and is the same as -h or --help
	
