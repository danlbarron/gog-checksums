# SPDX-FileCopyrightText: 2025-2025 Danl Barron
# SPDX-License-Identifier: MIT

RED='\033[0;31m'
NOCOLOR='\033[0m'

if [ -z ${1+x} ]; then
  echo -e "${RED}Product Id: Required argument${NOCOLOR}"
  exit 1
fi

productid=$1

stty -echo
read -s -p 'Bearer Token: ' token
echo -e "\b\b\b\b\b\b\b\b\b\b\b\b\b\bDownloading Checksums"
stty echo

rm $productid.md5 > /dev/null 2>&1

script="import json, os, sys; "
script+="downloads = json.load(sys.stdin)['downloads']; "
script+="downlinks = [file['downlink'] for keys in downloads for key in downloads[keys] for file in key['files']]; "
script+="print(os.linesep.join(downlinks))"

readarray -t downlinks < <( \
  curl -s https://api.gog.com/products/$productid?expand=downloads | \
    python3 -c "$script")

for downlink in "${downlinks[@]}"; do
  response=$(curl -s -w "%{http_code}" -X GET --oauth2-bearer $token $downlink)
  content=$(head -c-4 <<< "$response")
  status=$(tail -c-4 <<< "$response")

  if [ $status = 401 ]; then
    echo -e "${RED}Bearer Token: Expired or Invalid${NOCOLOR}"
    exit 1
  fi

  if [ $status = 403 ]; then
    # There's nothing we can do, so we should just continue down the list
    continue
  fi

  script="import json, sys; "
  script+="files = json.load(sys.stdin); "
  script+="print(files['checksum'])"
  checksumLink=$(echo $content | python3 -c "$script")

  script="import sys, xml.etree.ElementTree as ET; "
  script+="root = ET.fromstring(sys.stdin.read()); "
  script+="print(f'{root.attrib['md5']} *{root.attrib['name']}')"

  curl -f -s $checksumLink | python3 -c "$script" >> $productid.md5
done

echo $productid.md5: Created