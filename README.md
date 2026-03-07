This script, `image2term.sh`, is a versatile bash utility that transforms images into high-quality ASCII or ANSI art directly in your terminal. It serves as a powerful wrapper for the `jp2a` and `chafa` engines, offering extensive customization through unique character styles, color modes, and layout controls.

---

# 🖼️ image2term.sh

**A feature-rich CLI tool to convert images to ASCII art with style.**

## ✨ Features

* **Dual-Engine Support:** Choose between `jp2a` for classic character-based ASCII or `chafa` for advanced terminal graphics.
* **Massive Style Library:** Over 30 curated character sets for `jp2a`, including Alchemy symbols, Runes, Cuneiform, Braille, and Emoji-like enclosed letters.
* **Flexible Color Modes:** Supports `none`, `256-color`, and `truecolor` (24-bit) outputs.
* **Smart Auto-Sizing:** Automatically scales the output to fit your terminal dimensions while maintaining aspect ratio.
* **Padding Controls:** Add percentage-based margins (top, bottom, left, right) to frame your art.
* **Chaos Mode:** Use `--random-all` to generate unpredictable, artistic variations of your images.

---

## 🚀 Installation

### 1. Prerequisites

Ensure you have the following dependencies installed on your system:

* **ImageMagick** (specifically the `identify` command).
* **jp2a** (for classic ASCII styles).
* **chafa** (for modern block/symbol art).

**On Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install jp2a chafa imagemagick

```

### 2. Setup

Clone this repository or download the script, then make it executable:

```bash
chmod +x image2term.sh

```

---

## 🛠 Usage

### Basic Conversion

```bash
./image2term.sh -i my_photo.jpg --preview

```

### Advanced Customization

Generate a 100-character wide art piece using the `alchemy` style and `truecolor`:

```bash
./image2term.sh -i logo.png -w 100 -s alchemy -c truecolor --preview

```

### Randomize Everything

Let the script decide the engine, style, and colors for you:

```bash
./image2term.sh -i scenery.jpg --random-all --preview

```

---

## ⚙️ Options

| Flag | Description |
| --- | --- |
| `-i <file>` | **Required:** Input image path. |
| `-o <file>` | Output filename (Default: `ascii_output.txt`). |
| `-w / -h` | Custom width or height (overrides auto-sizing). |
| `-e <engine>` | Choose engine: `jp2a` or `chafa`. |
| `-s <style>` | `jp2a` style (e.g., `runes`, `stars`, `chess`, `braille`). |
| `-c <mode>` | Color mode: `auto`, `none`, `256`, `truecolor`. |
| `--symbols` | `chafa` symbol set: `block`, `ascii`, `braille`, etc.. |
| `-pt / -pb` | Padding Top / Bottom (percentage of height). |
| `--preview` | Instantly print the result to the terminal. |

---

## 🎨 jp2a Style Gallery

The script includes dozens of built-in styles for the `jp2a` engine, such as:

* **Geometric:** `fullblocks`, `dots`, `geometricshapes`.
* **Thematic:** `chess`, `cards`, `music`, `alchemy`, `mahajong`.
* **Ancient Scripts:** `hieroglyphs`, `cuneiform`, `runes`, `greek`.
* **Ornate:** `floral`, `ornaments`, `stars`.

---
