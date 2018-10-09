# MuseIC


MuseIC is a fast and simple music player with remote control from any device through internet browser.

![MuseIC Screenshoot](/data/museic_screenshoot.png)

- Play music files and add them to music library
- Sort by name, artis and album (it handles ID3 metadata tags)
- Connect to the address given by MuseIC and control the media from any device (mobile phone, tablet, etc.) with a web browser:


![MuseIC Client Screenshoot](/data/museic_client_screenshoot.png)


Any resemblance between the name and some awesome music band is pure coincidence.

## Installation

### Elementary App Store

Download MuseIC through the elementary app store. It's always updated to lastest version.
Easy and fast.

### Manual Instalation

Download last release (zip file), extract files and enter to the folder where they where extracted.

Install your application with the following commands:
- mkdir build
- cd build
- cmake -DCMAKE_INSTALL_PREFIX=/usr ../
- make
- sudo make install

DO NOT DELETE FILES AFTER MANUAL INSTALLATION, THEY ARE NEEDED DURING UNINSTALL PROCESS

### Python Script

Download last release (zip file), extract files and enter to the folder where they where extracted. Then, run the script "cmake_installer.py" from its original location. It must be run as sudo:

- sudo python3 cmake_installer.py

This script simply does the same that you would have done in manual installation. So we give the same advice:

DO NOT DELETE FILES AFTER INSTALLATION, THEY ARE NEEDED DURING UNINSTALL PROCESS

## Uninstall

### Elementary App Store

Just go to store and click on uninstall :)

### Manual Uninstall

To uninstall your application, run the script "cmake_uninstaller.py" (in the folder where files where originally extracted for manual installation).

It must be run as sudo:
- sudo python3 cmake_uninstaller.py
