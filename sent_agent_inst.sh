#!/bin/bash

#-----------------------------------------------------------------------------------------
#Set our variables for our use

# Path for the install profile
profilepath="$PWD/sentinelone_config.cfg"

# Name of the x86_64 DEB Package
x86_64_deb="SentinelAgent_linux_x86_64_v23_2_2_4.deb"

# Name of the x86_64 RPM Package
x86_64_rpm="SentinelAgent_linux_x86_64_v23_2_2_4.rpm"

# Name of the arm64 DEB Package
arm64_deb="SentinelAgent-aarch64_linux_aarch64_v23_2_2_4.deb"

# Name of the arm64 RPM Package
arm64_rpm="SentinelAgent-aarch64_linux_aarch64_v23_2_2_4.rpm"

# Get the install type from the command line paramenter, then convert it to lowercase
installer=$(echo "$1" | tr '[:upper:]' '[:lower:]')
#-----------------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------------
# Exit Codes
#    0 = Normal exit, finished successfully
#    1 = No Root privileges
#    2 = Unable to determine CPU architecture or unsupported architecture
#    3 = Unable to determine installer type due to Syntax error or missing parameter or another unknown error happened
#    4 = Unable to locate Sentinel One Package to install
#    5 = Unable to locate the profile file
#   10 = Missing parameter, brings up the help screen
#   99 = Package install failed for some reason
#-----------------------------------------------------------------------------------------



#-----------------------------------------------------------------------------------------
#            					Functions
#-----------------------------------------------------------------------------------------

help () {
# Displays the help text if the command syntax is wrong or missing something.

	echo
	echo This shell script can be used to to automate the install of the SentinalOne Linux Agent.
	echo
	echo This script tries to determine your CPU architecture and package installer type and then
	echo picks the appropriate package to install. Supported architectures are x86_x64 and arm64
	echo in either an RPM or DEB installer type. All 4 SentinalOne packages need to be in the 
	echo install folder, currently:
	echo -e '\t' $PWD
	echo
	echo You can download the needed packages from your SentinelOne Dashboard, but do not forget 
	echo to update this script with the filenames of the packages.
	echo
    echo They are currently set as:
    echo
    echo -e '\t' For Debian x86_64:'\t'$x86_64_deb
    echo -e '\t' For Debian arm64:'\t'$arm64_deb
    echo -e '\t' For RHL x86_64:'\t'$x86_64_rpm
    echo -e '\t' For RHL arm64:'\t\t'$arm64_rpm
	echo
	echo There also needs to be a configuration file for the agent install options in the the 
	echo same install folder as the agent install ackages. There are a variet of option you 
	echo can specify in this file. See the link below for more details, SentinelOne dashboard 
	echo access is needed.
	echo
	echo https://usea1-017.sentinelone.net/docs/en/deploying-the-linux-agent-with-a-configuration-file.html##
	echo
	echo NOTE: This script must be run with root privileges.
	echo
	echo
	echo Usage: sent_agent_inst [rpm] [deb] [help]
	echo
	echo -e '\t' deb'\t'Specifies that the installer shouls use the DEB package and that 
	echo -e '\t\t'you are installing onto a Debian or derivitave distro.
    echo
	echo -e '\t' rpm'\t'Specifies that the installer should use the RPM package and that 
	echo -e '\t\t'you are isntalling onto a RHL or derivative distro.
    echo
	echo -e '\t' help'\t'Brings up this information screen, and is the same as -h or --help
	echo
	echo
	echo 

	exit $1

}


check_arch () {
    
    #Get CPU architecture
    architecture=$(uname -m)

	case $architecture in
		x86_64)
		  echo -e ... detected CPU Architecture: $architecture	     
		;;
		arm64)
		  echo -e ... detected CPU Architecture: $architecture	
		;;
		*)
          echo
          echo
		  echo -e '\t' ERROR: Unsupported CPU architecture detected.
		  echo -e '\t' Detected CPU architecture is: $architecture
          echo
		  exit 2
		;;
	esac
}

check_options () {

	case $installer in
		deb)
		;;
		rpm)
		;;
		help)
		  help 0
	   ;;
		--help)
		  help 0
	   ;;
		-h)
		  help 0
	   ;;
		*)
		  echo
		  echo -e '\t' ERROR: Missing or invalid parameter or option specified
		  echo -e '\t' Use the -h or --help option for the correct syntax
		  echo
		  exit 3
		;;
	esac
}



#-----------------------------------------------------------------------------------------
#         					   End Functions
#-----------------------------------------------------------------------------------------



echo
echo SentinelOne Linux Install script
echo	

# Check to make sure the correct options are specified at the command line and/or bring up the help
check_options

echo -e -n Step 1:'\t' Checking for root privileges

if [ "$EUID" -ne 0 ]
  then 
    echo
    echo
    echo ERROR: Not running with the required privileges, please run as root
    echo 
    exit 1
  else
    echo ... root privileges found. 
fi

echo
echo -e -n Step 2: Checking CPU Architecture
check_arch



echo
echo -e Step 3: Checking System and determining install details
echo

case $installer in
	deb)
	  if [[ $architecture = "x86_64" ]]
	  then
	     package=$x86_64_deb
	     installer="dpkg -i "
  	  else
	     package=$arm64_deb
	     installer="dpkg -i "
	  fi
	;;
	rpm)
		  if [[ $architecture = "x86_64" ]]
	  then
	     package=$x86_64_rpm
	     installer="rpm -i --nodigest "
	  else
	     package=$arm64_rpm
  	     installer="rpm -i --nodigest "
	  fi
    ;;
 	*)
      echo -e '\t' ERROR: You should never see this error, so something went very wrong.
      echo
	  exit 3
	;;
esac

echo -e '\t' Install type and options:'\t' $installer
echo -e '\t' Package to be installed:'\t' $package
echo
echo -e '\t' Environment variable file: '\t' $profilepath
echo -e '\t' Installer command: '\t\t' $installer $PWD/$package

echo


echo -e -n Step 4:'\t' Checking to make sure the package exists
if [[ -r $PWD/$package ]]
   then
     echo ... package found
   else
     echo
     echo
     echo -e '\t' ERROR: Unable locate $package
     echo -e '\t' Please copy $package into $PWD folder and try again
     echo
     exit 4
fi 


echo -e -n Step 5:'\t' Checking to make sure the profile file exists

if [[ -r $profilepath ]]
   then
     echo ... profile file found and using it to set evironment variables and agent install options
     # export S1_AGENT_INSTALL_CONFIG_PATH=$profilepath # <-------------------------------------------
   else
     echo
     echo
     echo -e '\t' ERROR: Unable locate $profilepath
     echo -e '\t' Please copy it into the $PWD folder and try again
     echo
     exit 5
fi 


echo -e -n Step 6:'\t' Installing the the package

# $installer $PWD/$package  # <----------------------------------------------------------


# Now Check to make sure the installer finished ok.
status=$?
if [[ $status -gt 0 ]]
  then
    echo 
    echo
    echo -e '\t' ERROR: Package install failed with and exit code of $status
    echo
    exit 99
  else
    echo ... installer finished succefully, exit code was $status
fi

echo
echo Done
exit 0
