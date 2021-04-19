#!/bin/bash
if [ -z "$1" ]; then
    echo $0 deb_path_dir
    exit 99
fi
dir=$1
if [ ! -d $dir ];then
    echo "directory not found"
    exit 99
fi


#change your config here.
password=qqqqqqqqqq
name=joel
email=joel@foo.bar

gen_gpg_keypair()
{
    gpg --batch --generate-key <<EOF
%echo Generating a basic OpenPGP key
Key-Type: DSA
Key-Length: 1024
Subkey-Type: ELG-E
Subkey-Length: 1024
Name-Real: $name
Name-Comment: with stupid passphrase
Name-Email: $email
Expire-Date: 0
Passphrase: $password
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF
    echo "export public key"
    cp -a $GNUPGHOME ./gpgdir
}

release_head()
{
    file=$1
    cat << EOF > $file 
Origin: My_Local_Repo
Label: My_Local_Repo
Codename: xenial
Architectures:  arm64
Components: main
Description: My local APT repository
SignWith: 12345ABC
EOF
 
}


if [ ! -z "$2" ]; then
    export GNUPGHOME=$2
else
    export GNUPGHOME="$(mktemp -d)"
    gen_gpg_keypair
fi

gpg --armor --export > $dir/Release.key
(
    cd $dir
    dpkg-scanpackages . /dev/null > Packages
    gzip --keep --force -9 Packages

    # Generate the Release file
    release_head Release
    # The Date: field has the same format as the Debian package changelog entries,
    # that is, RFC 2822 with time zone +0000
    echo "Date: `LANG=C date -Ru`" >> Release
    # Release must contain MD5 sums of all repository files (in a simple repo just the Packages and Packages.gz files)
    echo 'MD5Sum:' >> Release
    printf ' '$(md5sum Packages.gz | cut --delimiter=' ' --fields=1)' %16d Packages.gz' $(wc --bytes Packages.gz | cut --delimiter=' ' --fields=1) >> Release
    printf '\n '$(md5sum Packages | cut --delimiter=' ' --fields=1)' %16d Packages' $(wc --bytes Packages | cut --delimiter=' ' --fields=1) >> Release
    # Release must contain SHA256 sums of all repository files (in a simple repo just the Packages and Packages.gz files)
    echo -e '\nSHA256:' >> Release
    printf ' '$(sha256sum Packages.gz | cut --delimiter=' ' --fields=1)' %16d Packages.gz' $(wc --bytes Packages.gz | cut --delimiter=' ' --fields=1) >> Release
    printf '\n '$(sha256sum Packages | cut --delimiter=' ' --fields=1)' %16d Packages' $(wc --bytes Packages | cut --delimiter=' ' --fields=1) >> Release

    # Clearsign the Release file (that is, sign it without encrypting it)
    #echo $password | gpg --pinentry-mode loopback --passphrase-fd 0 --clearsign --digest-algo SHA512 --local-user $name -o InRelease Release
    gpg --clearsign --digest-algo SHA512 --local-user $name -o InRelease Release
    # Release.gpg only need for older apt versions
    # gpg -abs --digest-algo SHA512 --local-user $name -o Release.gpg Release
)
