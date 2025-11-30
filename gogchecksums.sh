# SPDX-FileCopyrightText: 2025-2025 Danl Barron
# SPDX-License-Identifier: MIT

if [ -z ${1+x} ]; then echo 'product id is required as an argument'; exit; fi
productid=$1

stty -echo
read -s -p 'Bearer Token: ' token; echo
stty echo

rm $productid.md5 > /dev/null 2>&1

readarray -t downlinks < <(curl -s https://api.gog.com/products/$productid?expand=downloads | python3 -c "import json, os, sys; downloads = json.load(sys.stdin)['downloads']; print(os.linesep.join([file['downlink'] for keys in downloads for key in downloads[keys] for file in key['files']]))")

for downlink in "${downlinks[@]}"; do
  readarray -t details < <(curl -s -X GET --oauth2-bearer $token $downlink | python3 -c "import json, sys; files = json.load(sys.stdin); print(files['downlink']); print(files['checksum'])")

  curl -f -s ${details[1]} | python3 -c "import sys, xml.etree.ElementTree as ET; root = ET.fromstring(sys.stdin.read()); print(f'{root.attrib['md5']} *{root.attrib['name']}')" >> $productid.md5
done

echo $productid.md5: Created