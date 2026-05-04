# 🐬 Flipper Zero Deploy Script

A straightforward shell script to deploy files to your Flipper Zero.

---

## 📦 Overview

`flipper.sh` is a minimal automation tool for pushing files to a Flipper Zero.

It handles common repetitive tasks such as:

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
./flipper.sh
```

📁 Expected structure

Typical Flipper Zero layout:
/ext/
 ├── apps/
 ├── badusb/
 ├── subghz/
 └── nfc/
