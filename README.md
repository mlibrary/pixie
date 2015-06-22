Pixie
=====

Sinatra App for iPXE booting servers. Currently supports booting Debian 8 only. Managment of DHCP/TFTP server (for PXE) coming soon.

## Usage
User is expected to be an expert Debian admin, but the rack app, ruby and iPXE can remain opaque. To this end an iPXE script for loading Debian is included, but you supply your own preseed.cfg and partman-recipe (samples included). All files in /public are available at the root of the app. Append a .erb extension and they will be served as templates instead.

## Quick Start
* Put your preseed.cfg and partman-recipe in /public
* Modify /config/subnets.yml to list your server subnets
* Provide forward and reverse DNS for your new server on public DNS
* Boot server to iPXE (this step will be optional once I add DHCP/TFTP/PXE support)
* when iPXE boots:

```
^B
dhcp
chain http://$BOOT_SERVER/boot
```
## Web Interface
The web interface provides a list of all paths Pixie can serve. This includes both internal funcitons and the files/templates in /public. You can preview the template results for any server with overrides provided in the web interface.

Also available are the internal data structures used to fill the templates. These are provided in JSON. If you want them to be pretty, install a JSON pretty print extension like JSONView for your browser:

* FireFox: [Download Page](https://addons.mozilla.org/en-US/firefox/addon/jsonview/)                                 | [GitHub](https://github.com/bhollis/jsonview/)
* Chrome: [Download Page](https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc?hl=en) | [GitHub](https://github.com/gildas-lormeau/JSONView-for-Chrome)
* Safari: [Download Page](https://extensions.apple.com/details/?id=com.acrogenesis.jsonview-56Q494QF3L)              | [GitHub](https://github.com/acrogenesis/jsonview-safari)