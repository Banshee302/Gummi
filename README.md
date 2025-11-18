# Gummi
Gummi is a Package Manager written in Ruby and is Open Source and Simple to use! it uses its own Package mirror, so if you want your Package on the Index, just make a issue with your GitHub Repository and ill look through it and add it!

**SECURITY DISCLAIMER**
All Packages from the official Gummi Index are tested for Malicious Code and or Behaviour, if a Package is Malicous or a "Virus", it will not be submitted to the Package Index and will be removed from the Issues Package submission request. We recommend you note All Packages in the Gummi Index are Open Source Projects. If a Malicious Package gets slipped through, please report it via Issues too, we will temporarily remove the Package and retest it, if Malicious Content are found it will NOT be put back, but if the greenlight is given it will be put back in the index.


# Gummi Package Index

To upload your Package to the Gummi Index, please create an issue, with your Repository link and what it does, then ill get around to adding it to the index!

# About Gummi
Gummi is a lightweight and simple and incredibly fast package manager written in Ruby and uses the Gummi index, the Gummi Index is a growing Package Index, we're inviting Open Source developers from everywhere to submit their Packages!

PLEASE NOTE:
ALL PACKAGES WILL BE SECURITY CHECKED, IF MALICIOUS CODE/BEHAVIOUR IS FOUND, IT WILL NOT BE PUBLISHED TO THE INDEX!

# Usage

To update the local package database, type in ruby gummi.rb index, this will download and or update the local current database from the remote updated package index database.

to install, you can type in ruby gummi.rb get <packagename>, this will check the index for a package entry with the name of it, checks the path and downloads it from the remote package mirror.

# For Developers

You can port your Package very easily to Gummi and make it compliant with the Package Manager, just put the gummi.rb script in your Package directory, type in "ruby gummi.rb mkpkg" and it will create a skeleton JSON Package instruction file, edit it to fit your Project, and then ship it out to Gummi Package Index via GitHub Issues as I said above.

For extensive development with Gummi documetation, check the Gummi Wiki for Developers!
> https://github.com/Banshee302/Gummi/wiki


