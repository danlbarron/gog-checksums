GOG Checksum Tool
---
This script will use the [GOG API](https://gogapidocs.readthedocs.io/en/latest) to download a list of checksums for a given game/product installer.

### Dependencies
* Bash Shell (or derivative)
* Curl
* Python 3

### Usage
To run the script, you'll need both a product id and a API bearer token.

The product id can easily be obtained by searching [GOG DB](https://www.gogdb.org). Let's say we want to download the checksums for *Resident Evil 3*. We can search GOG DB and eventually we'll find this [page](https://www.gogdb.org/product/1266089300), which the product id can either be grabbed from the URL or directly from the table contents listed front and center. Hint, the product id in this case will be ***1266089300***.

The bearer token can be obtained by logging into [GOG](https://www.gog.com) via a desktop web browser (I.E., Mozilla Firefox), opening the Web Developer Tools, navigating to a Local Storage viewer, and searching for within the scope of https://www.gog.com for ***token***; at of the time of writing, the key is *dataClient_menuData* and within the corresponding json value, there's a value for *accessToken*, which is the bearer token you'll need. Bearer Tokens have a limited lifetime, something like an hour or so, so be prepared to fetch a new bearer token each time you use this script.

I typically store my game installers in a directory like, *Downloads/GOG*, which is where I would also copy this script into.

To use this script
``` bash
./gogchecksums.sh 1266089300
# You'll be prompted for a bearer token, just copy and paste it. Bearer Tokens aren't displayed for security purposes.
# Once the script completes, it'll output 1266089300.md5: Created.

# You can take that md5 file and check it against installers. Each file should say something like, setup_resident_evil_3_1.0_hotfix3(78559).exe: OK, if the check passes.
md5sum -c 1266089300.md5
```