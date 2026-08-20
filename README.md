# 🐬 Flipper Zero UFW Deploy Script

A straightforward shell script to manage & deploy [DarkFlippers/unleashed-firmware](https://github.com/DarkFlippers/unleashed-firmware) files to your Flipper Zero.

When it comes to computers I'm cursed with a ritualistic OCD way of doing things, everytime there was a new UFW version I would manually format the SDCARD and copy around 20.000 files by hand. I know that's essentially not necessary, but then this would be echoing in my head, so I've automated it.

---

## 📦 Overview

`flipper.sh` is a minimal automation tool for pushing files to a Flipper Zero every time there is a new UFW version release.

It handles common repetitive tasks such as:

- Download new UFW releases
- File transfers
- Directory organization
- Quick payload deployment

The goal is simple: **reduce friction and avoid mistakes**.


---

## ⚙️ Requirements

- Flipper Zero connected via USB
- Mounted filesystem or accessible device path
- Linux environment (or WSL)

No heavy dependencies expected.

---


## 🚀 Usage

Clone the repository:

```bash
git clone https://github.com/NUMAflex/flipperzero-deploy.git
cd flipperzero-deploy
```

Make the script executable:
```bash
chmod +x flipper.sh
```

Run it:
```bash
./flipper.sh --help

 Commands:
 --clean-fap   erase all your previous fap
 --clean-totp  erase all your previous totp plugins
 --new-fw      copy new firmware version from released zip files
 --copy-sd     copy files to sd card
 --get-fw      download new firmware version zip files
 --get-apps    download base and extra apps zip files
 --uberguidoz  clone UberGuidoZ repository (or update if present)
 --help (this screen)
 --about
```


📁 Expected structure

Typical Directory layout:
```bash
Flipper/
 ext/
 ├── apps/
 ├── apps_data/
 ├── badusb/
 ├── infrared/
 ├── music_player/
 ├── nfc/
 ├── pocsag/ (optional)
 ├── subghz/
 ├── subghz_remote/
 ├── subplaylist/
 └── tama_p1/
 fw/
 ├── all-the-apps-base.zip
 ├── all-the-apps-extra.zip
 ├── flipper-z-f7-update-unlshd-###.tgz (optional)
 ├── flipper-z-f7-update-unlshd-###c.tgz
 └── flipper-z-f7-update-unlshd-###e.tgz (optional)
```

You can create the expected directory structure with:
```bash
./flipper.sh --bootstrap
and
./flipper.sh --dbootstrap (this will create a folder acting as the SDCARD, for testing purpose)
```

## 🔗 Links
- **Unleashed web page:** [flipperunleashed.com](https://flipperunleashed.com)

## Disclaimer
"This project is independent and is not affiliated with, sponsored by, or otherwise authorized by [DarkFlippers/unleashed-firmware](https://github.com/DarkFlippers/unleashed-firmware)."
