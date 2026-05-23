# 🐬 Flipper Zero Deploy Script

A straightforward shell script to manage & deploy [DarkFlippers/unleashed-firmware](https://github.com/DarkFlippers/unleashed-firmware) files to your Flipper Zero.

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
 ├── flipper-z-f7-update-unlshd-089.tgz (optional)
 ├── flipper-z-f7-update-unlshd-089c.tgz
 └── flipper-z-f7-update-unlshd-089e.tgz (optional)
```
