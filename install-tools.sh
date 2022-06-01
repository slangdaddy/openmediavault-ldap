#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

# Install tools for testing the plugin

echo "Installing utils for development / testing"
# TODO: setup LDAP with test data
apt-get --yes install slapd ldap-utils smbldap-tools

# See https://ubuntu.com/server/docs/samba-openldap-backend
echo "Configuring LDAP"
ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config 'cn=*samba*'

cat<<EOF > /tmp/samba_indices.ldif
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcDbIndex
olcDbIndex: objectClass eq
olcDbIndex: uidNumber,gidNumber eq
olcDbIndex: loginShell eq
olcDbIndex: uid,cn eq,sub
olcDbIndex: memberUid eq,sub
olcDbIndex: member,uniqueMember eq
olcDbIndex: sambaSID eq
olcDbIndex: sambaPrimaryGroupSID eq
olcDbIndex: sambaGroupType eq
olcDbIndex: sambaSIDList eq
olcDbIndex: sambaDomainName eq
olcDbIndex: default sub,eq
EOF

ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /tmp/samba_indices.ldif

# Note: Samba must be activated / running in OMV from here on
# Generate configuration for smbldap-config, ask several questions
# Note: Ensure that the port is not part of the hostname!
smbldap-config
# Prepare the LDAP using freshly created config
smbldap-populate -g 10000 -u 10000 -r 10000

# Tell samba the ldap admin password
smbpasswd -W

# Not sure if thats really necessary
systemctl restart smbd.service nmbd.service

# Finally add a user to LDAP / Samba
smbldap-useradd -a -P -m jodoe
