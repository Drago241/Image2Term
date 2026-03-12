# 🖼️ image2term.sh

A feature-rich, cross-platform CLI tool to convert images to ASCII art with style. Works on **Linux** and **macOS**.

`image2term.sh` is a versatile bash utility that transforms images into high-quality ASCII or ANSI art directly in your terminal. It serves as a powerful wrapper for the `jp2a` and `chafa` engines, offering extensive customization through unique character styles, color modes, and layout controls.

## ✨ Features

* **Dual-Engine Support:** Choose between `jp2a` for classic character-based ASCII or `chafa` for advanced terminal graphics.
* **Massive Style Library:** Over 30 curated character sets for `jp2a`, including Alchemy symbols, Runes, Cuneiform, Braille, and Emoji-like enclosed letters.
* **Flexible Color Modes:** Supports `none`, `256-color`, and `truecolor` (24-bit) outputs.
* **Smart Auto-Sizing:** Automatically scales the output to fit your terminal dimensions while maintaining aspect ratio.
* **Padding Controls:** Add percentage-based margins (top, bottom, left, right) to frame your art.
* **Chaos Mode:** Use `--random-all` to generate unpredictable, artistic variations of your images.

## 🚀 Installation

### 1. Prerequisites

The script requires `ImageMagick`, `jp2a`, and `chafa`. Install them based on your operating system:

**On macOS (using [Homebrew](https://brew.sh)):**

```bash
brew install imagemagick jp2a chafa

```

**On Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install imagemagick jp2a chafa

```

**On Fedora/RHEL:**

```bash
sudo dnf install ImageMagick jp2a chafa

```

### 2. Setup

Clone this repository or download the script, then make it executable:

```bash
chmod +x image2term.sh

```

## 🛠 Usage

### Basic Conversion

Instantly preview an image in your terminal:

```bash
./image2term.sh -i my_photo.jpg --preview

```

### Advanced Customization

Generate a 100-character wide art piece using the `alchemy` style and `truecolor`:

```bash
./image2term.sh -i logo.png -w 100 -s alchemy -c truecolor --preview

```

### Randomize Everything

Let the script decide the engine, style, and colors for you (great for discovering new looks):

```bash
./image2term.sh -i scenery.jpg --random-all --preview

```

## ⚙️ Options

| Flag | Description |
| --- | --- |
| `-i <file>` | **Required:** Input image path. |
| `-o <file>` | Output filename (Default: `ascii_output.txt`). |
| `-w` / `-h` | Custom width or height (overrides auto-sizing). |
| `-e <engine>` | Choose engine: `jp2a` or `chafa`. |
| `-s <style>` | `jp2a` style (e.g., `runes`, `stars`, `chess`, `braille`). |
| `-c <mode>` | Color mode: `auto`, `none`, `256`, `truecolor`. |
| `--symbols` | `chafa` symbol set: `block`, `ascii`, `braille`, etc. |
| `-pt` / `-pb` | Padding Top / Bottom (percentage of height). |
| `--preview` | **Terminal-only mode:** Prints result to terminal and skips file saving. |
| `--random-all` | Randomizes all unset parameters for artistic variety. |

## 🎨 jp2a Style Gallery

The script includes dozens of built-in styles for the `jp2a` engine, such as:

* **Geometric:** `fullblocks`, `dots`, `geometricshapes`.
* **Thematic:** `chess`, `cards`, `music`, `alchemy`, `mahajong`.
* **Ancient Scripts:** `hieroglyphs`, `cuneiform`, `runes`, `greek`.
* **Ornate:** `floral`, `ornaments`, `stars`.

---

**Tip for Mac Users:** If you use the default "Terminal.app," for the best experience with `truecolor` and `chafa` graphics, consider using [iTerm2](https://iterm2.com/) or [Ghostty](https://ghostty.org/).
