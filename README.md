```
setup http server for apt install.

Create private apt repo.
1.Gen gpg key
#apt update
#apt-get install -y rng-tools
#apt install -y gnupg
#gpg --generate-key
===>usename: xxxx, email:xxxxx
===>if blocking, need install rng....
export your public key
#gpg --list-key
/root/.gnupg/pubring.kbx
------------------------
pub   rsa3072 2021-04-19 [SC] [expires: 2023-04-19]
      7FFAE741FDCC047AEF55AF05F4F04A0173478047
uid           [ultimate] hawkeyeteck <root@hawkeyeteck.com.tw>
sub   rsa3072 2021-04-19 [E] [expires: 2023-04-19]

#gpg --armor --export 7FFAE741FDCC047AEF55AF05F4F04A0173478047 > my_public_key.key

one command to create keypair
#export password=123123123
#gpg --batch --generate-key <<EOF
     %echo Generating a basic OpenPGP key
     Key-Type: DSA
     Key-Length: 1024
     Subkey-Type: ELG-E
     Subkey-Length: 1024
     Name-Real: Joe Tester
     Name-Comment: with stupid passphrase
     Name-Email: joe@foo.bar
     Expire-Date: 0
     Passphrase: $password
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF



2.Gen deb package info (Package.gz)
mkdir mydeb_repo
put *.deb in mydeb_repo/

#apt install -y dpkg-scanpackages
#cd mydeb_repo/
#dpkg-scanpackages . /dev/null > Packages








```
