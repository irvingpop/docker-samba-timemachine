#!/bin/sh -e

#defaults
TM_USER="${TM_USER:-timemachine}"
TM_PW="${TM_PW:-timemachine}"
TM_ID="${TM_ID:-1000}"
TM_SIZE="${TM_SIZE:-1024000}"

## create necessary directories
for dir in /shares/timemachine /shares/public /var/cache/samba /var/lib/samba/private /var/log/samba /var/run/samba; do
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
done

#Add smb user
grep -q "^${TM_USER}:" /etc/passwd || \
  adduser -D -H ${TM_GROUP:+-G $TM_GROUP} ${TM_ID:+-u $TM_ID} "${TM_USER}"
echo -e "${TM_PW}\n${TM_PW}" | smbpasswd -s -a "${TM_USER}"

chown -R ${TM_USER} "/shares"
TM_SIZE=$(($TM_SIZE * 1000000))
sed "s#REPLACE_TM_SIZE#${TM_SIZE}#" /tmp/template_quota > /shares/timemachine/.com.apple.TimeMachine.quota.plist

# run CMD
exec "${@}"
