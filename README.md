# Create your own Signed Arch Linux Repository

## Contents

1. Creating the GPG Key
2. Generate the Public Key and Upload it
3. Get the Repositorys
4. Make the Repository an GITHUB Pages
5. Build the Packages for the first Time
6. Additional Things
7. Adding Repo to System
8. Future

---

## 1. Creating the GPG Key

#### Make the ~/.gnupg Directory and go inside of it

#### Run the Command and then Enter everything in the Tutorial

```bash
gpg --full-generate-key
```

Please select what kind of key you want:  
(1) RSA and RSA (default)  
(2) DSA and Elgamal  
(3) DSA (sign only)  
(4) RSA (sign only)  
(14) Existing key from card  
Your selection?  

#### Select 1

```bash
1
```

RSA keys may be between 1024 and 4096 bits long. What key size do you want? (3072)

#### Enter any Number between 1024 and 4096

The Longer the key the longer it takes to Sign  
We are Using 3072 which is a Middleground

```bash
3072 or Enter
```

#### Next, enter how long the Key should be Valid

I am Choosing 2 Years as it is bad practice to set it to not Expire  
You can extend the Expiration Date easily so 2 Years is a good Choice

```bash
2y
```

Is this correct? (y/N)

#### Enter Yes if it is Correct

```bash
y
```

Next, enter your Name and Email Address you want the key to be associated with and leave the Comment empty.

#### Confirm the Key creation by entering "O"

#### Next you have to enter a Passphrase

Save the Passphrase  in an Passwordmannager or use a long Sentence that you can remember or write down

## 2. Generate the Public Key and Upload it

#### This is not Needed i think if you follow the entire tutorial

#### Get the Key

```bash
gpg --list-keys
```

#### Copy the Key ID and then Generate the Public Key

Example KEY ID: 8BC5F9E0A2D63E11D9A2C3C9E4FA2B6878987B5F

```bash
gpg --armor --output "repo.key" --export "KEY ID or email"
```

#### Send the Key to a Keyserver

```bash
    gpg --send-keys "Your KEY ID"
```

#### If that doesn't work try This command in Which we specify the Keyserver

```bash
gpg --keyserver keyserver.ubuntu.com --send-keys "Your KEY ID"
```

#### You can test if the Key is on the Server by running

Change the Keyserver if you have it uploaded onto another Keyserver

```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys "Your KEY ID"
```

#### It Should look something like This

gpg: key 8BC5F9E0A2D63E11D9A2C3C9E4FA2B6878987B5F: “Name Lastname <email@something.com>” not changed  
gpg: Total number processed: 1  
gpg: unchanged: 1  

#### Add the Key to /etc/makepkg.conf and change the Packager name and Email

## 3. Get the Repositorys

#### Fork the Repositorys

Fork all Three Repositorys or if don't need the Testing Repository only Fork the Two and name them Some Name with alphabetic Characters and underscores

#### Clone the Repositorys

Clone the Repositorys to your local machine

#### Change all Refrences in the Script

Use a code Editor and find and Replace all RefinedArch refrences with your Repo Name if you have kept the Extensions like RefinedArch_repo to Your Distrubution name  
If you have changed the Extensions you have to rename the extensions aswell

#### Change the name of the Packages

Change the name of the refined-keyring and refined-mirrorlists to your Repo Name  

#### Change the mirrorlist File

Change the Server in the Mirrorlist to your Server by changing the Repo Name and the username in the URL

#### Add the Correct Key

Add the Key from your file ~/.gnupg/repo.key into the refined.gpg file and then rename the File to your Repo

## 4. Make the Repository an GITHUB Pages

#### I will sometime change it to not having to be a GITHUB pages

#### Go to your Repo and Testing Repo and make it into github pages on the Master Branch

## 5. Build the Packages for the first Time

#### Check the PKGBUILDs and Package names if all refrences have Changed

#### Run The ./check.sh Command to Check if All packages are Buildable

#### Edit the Default parameters in the ./build.sh Script

#### Run ./build.sh without Passing any arguments to use the standart Parameters

#### Run the ./push.sh command to Push all Repos to Github

#### Add additional PKGBUILDS and then Repeat all the Steps in this Paragraph

#### Remove the Old Packages with the Old names from the Repo

## 6. Additional Things

#### If there are any problems try the "-af" Argument in build.sh

#### If something else Breaks open an issue on the Example Repo

#### If you have the Testing Repo and want to move an Package to the official Repo run ./move.sh $packagename and then run push.sh

## 7. Adding Repo so System

#### Add the Repo to /etc/pacman.conf by pasting the next line to the End of the File and change the Refrences

```bash
[refined_repo]
SigLevel = Required DatabaseOptional
Server = https://username.github.io/reponame/x86_64/
```

#### Now you Should be able to Update and Install the Packages from the Repo

## 8. Future

#### When i have the basic Functionality in my RefinedArch Distribution i will rewrite the Script in rust as it is the Language i am the most familiar with

#### New Functionality

1. Automatic move from Testing to Repo after some Time
2. Automatic Template Creation as to not have to change the Refrences
3. Some Mose Automatic Things it can do
4. Some Commands which allow you to more easily create PKGBUILDS
5. Create a good Readme

#### If you have any Questions you can ask on Discord  @johnsi14
