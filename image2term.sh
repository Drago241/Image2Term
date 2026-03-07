#!/usr/bin/env bash
#
# ASCII Converter: Convert images to ASCII art with jp2a or chafa
#
# Usage:
#   ./image2term.sh -i <input_image> [options]
#
# Options:
#   -i <image>           Input image file (required)
#   -o <output_file>     Output file to save ASCII art (default: ascii_output.txt)
#   -w <width>           Custom width for output ASCII art (overrides auto sizing)
#   -h <height>          Custom height for output ASCII art (overrides auto sizing)
#   -s <style>           Style for jp2a engine (default: standard)
#   -ch <chars>          Custom characters for jp2a engine (overrides -s)
#   -pt <percent>        Padding top in percent of image height (default: 0)
#   -pb <percent>        Padding bottom in percent of image height (default: 0)
#   -pl <percent>        Padding left in percent of image width (default: 0)
#   -pr <percent>        Padding right in percent of image width (default: 0)
#   -c <color_mode>      Color mode: auto (default), none, 256, truecolor
#   -e <engine>          ASCII engine to use: jp2a (default), chafa
#   --symbols <set>      Symbol set for chafa (block, ascii, braille, etc.)
#   --fg-only            Use only foreground colors (chafa only)
#   --preview            Show generated ASCII art in terminal after creation
#   --random-all         Randomize all unspecified settings (style, symbols, colors, paddings… 
#                        and randomly toggle --fg-only for chafa if not explicitly set)
#   --help               Show this help message and exit
#
# jp2a Styles (-s):
#   standard       → A@#&%*+:-.
#   fullblocks     → ██
#   net            → 🮐🮐
#   bars           → █▌▐
#   cutblock       → 🭁🭁
#   agean          → 𐄊𐄎𐄗𐄞𐄧𐄳
#   chess          → ♜♞♝♛♚♝♞♜♟♙♖♘♗♕♔♗♘♖
#   dots           → •°·.
#   braille        → ⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿
#   enclosed       → 🅐🅑🅒🅓🅔🅕🅖🅗🅘🅙🅚🅛🅜🅝🅞🅟🅠🅡🅢🅣🅤🅥🅦🅧🅨🅩
#   fade           → '@B%8&WM#*oahkbdpqwmZ0OQLCJUYXzcvunxrjft/|()1{}[]?-_+~<>i!lI;:,"^`\'.
#   alchemy        → 🜀🜁🜂🜃🜄🜅🜆🜇🜈🜉... (full Unicode alchemy set)
#   greek          → ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρστυφχψω
#   runes          → ᚠᚡᚢᚣᚤᚥ...ᛗ 
#   border         → ─│┌┐└┘
#   fwquartersquare→ 🙾🙾
#   bwquartersquare  → 🙿🙿
#   fwslash        → 🙼🙼
#   bwslash        → 🙽🙽
#   floral         → 🙨🙪
#   music          → 𝄞𝄆𝄇♩♪♫♬
#   ornaments      → ♡♥❤❥❢❣❡☙❦❧🙰🙱🙲...🙭 
#   cuneiform      → 𒄙𒄩𒄦𒃽...𒃷
#   dominoh        → 🁣🁤🁥...🂓🁢
#   dominov        → 🀱🀲🀳...🁡🀰
#   cards          → 🂱🂲🂳...🃞🂠🃟
#   tinycards      → 🂿🃠🃡...🃵
#   suits          → ♠♣♥♦♤♧♡♢
#   hieroglyphs    → 𓇈𓆅𓇙...𓅶
#   hexagram       → ䷀䷁䷂...䷿
#   geometricshapes→ 🞄●⬤◯⚬○...⯄
#   stars          → ★⭑🟉🟊☆⭒...❆✿❀❁✾
#   mahajong       → 🀇🀈🀉...🀪
#   domino         → 🁣🁤🁥...🀰
#   playingcards   → ♠♣♥♦♤♧♡♢...🃵
#
# chafa Symbols (--symbols):
#   block      → █ ▓ ▒ ░
#   ascii      → @ # % * + - :
#   braille    → ⠁ ⠃ ⠉ ⠙ ⠿
#   sextant    → ▀ ▄ █ ▐ ▌
#   quad       → ▖ ▘ ▚ ▞
#   border     → ─ │ ┌ ┐ └ ┘
#   space      → (whitespace only)
#
# Examples:
#   ./ascii.sh -i image.png --preview
#   ./ascii.sh -i photo.jpg -o output.txt -w 100 -h 40 -s dense -c truecolor
#   ./ascii.sh -i pic.png --random-all --preview -o rand_output.txt
#
# Notes:
# - Requires 'jp2a' or 'chafa' installed for ASCII conversion.
# - Requires 'identify' from ImageMagick for image dimensions.
# - Padding is spacing only (no background color applied).
# - The preview prints ASCII art, not the original image.
#

set -e

# ========== Defaults ==========
OUTPUT="ascii_output.txt"
STYLE="standard"
CUSTOM_CHARS=""
CHAFA_SYMBOLS=""
CHAFA_FG_ONLY=false
PADDING_TOP=0
PADDING_BOTTOM=0
PADDING_LEFT=0
PADDING_RIGHT=0
COLOR_MODE="auto"
ENGINE="jp2a"  # default
PREVIEW=false
RANDOM_ALL=false
USER_SET_FLAGS=()

TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
MAX_WIDTH=80
if [ "$TERM_WIDTH" -gt "$MAX_WIDTH" ]; then
    TERM_WIDTH=$MAX_WIDTH
fi

# ========== Randomization Arrays ==========
ENGINES=("jp2a" "chafa")
JP2A_STYLES=("standard" "fullblock" "net" "bars" "fade" "braille" "enclosed" "greek" "runes" "alchemy" "hieroglyphs" "cuneiform" "ornaments" "cutblock" "agean" "chess" "dots" "border" "fwquartersquare" "bwquartersquare" "fwslash" "bwslash" "floral" "music" "dominoh" "dominov" "cards" "tinycards" "suits" "hexagram" "geometricshapes" "stars" "mahajong" "domino" "playingcards")
CHAFA_SYMBOL_SETS=("block" "ascii" "braille" "sextant" "quad" "border" "space")
COLOR_MODES=("auto" "none" "256" "truecolor")
CUSTOM_CHARS_OPTIONS=("" "@%#*+=-:. " "01" "ⒶⒷ🄰🄱🅐🅑①②" "⠁⠃⠉⠙⠿" "▓▒░" "@Oo*+-." "•°·." "ΣΠ∞∂≈√" "#*·")

# ========== Parse Flags ==========
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i) IMAGE="$2"; USER_SET_FLAGS+=("i"); shift ;;
        -o) OUTPUT="$2"; USER_SET_FLAGS+=("o"); shift ;;
        -w) CUSTOM_WIDTH="$2"; USER_SET_FLAGS+=("w"); shift ;;
        -h) CUSTOM_HEIGHT="$2"; USER_SET_FLAGS+=("h"); shift ;;
        -s) STYLE="$2"; USER_SET_FLAGS+=("s"); shift ;;
        -ch) CUSTOM_CHARS="$2"; USER_SET_FLAGS+=("ch"); shift ;;
        --symbols) CHAFA_SYMBOLS="$2"; USER_SET_FLAGS+=("symbols"); shift ;;
        --fg-only) CHAFA_FG_ONLY=true; USER_SET_FLAGS+=("fg-only") ;;
        -pt) PADDING_TOP="$2"; USER_SET_FLAGS+=("pt"); shift ;;
        -pb) PADDING_BOTTOM="$2"; USER_SET_FLAGS+=("pb"); shift ;;
        -pl) PADDING_LEFT="$2"; USER_SET_FLAGS+=("pl"); shift ;;
        -pr) PADDING_RIGHT="$2"; USER_SET_FLAGS+=("pr"); shift ;;
        -c) COLOR_MODE="$2"; USER_SET_FLAGS+=("c"); shift ;;
        -e) ENGINE="$2"; USER_SET_FLAGS+=("e"); shift ;;
        --preview) PREVIEW=true; USER_SET_FLAGS+=("preview") ;;
        --random-all) RANDOM_ALL=true ;;
        --help) grep '^#' "$0" | sed 's/^#//' ; exit 0 ;;
        *) echo "Unknown option $1"; exit 1 ;;
    esac
    shift
done

# ========== Check Required Input ==========
if [ -z "$IMAGE" ]; then
    echo "Error: Input image not provided. Use -i <image>"
    exit 1
fi

# ========== Randomize if requested ==========
if [ "$RANDOM_ALL" = true ]; then
    if [[ ! " ${USER_SET_FLAGS[@]} " =~ " e " ]]; then
        ENGINE=${ENGINES[$RANDOM % ${#ENGINES[@]}]}
    fi
    if [ "$ENGINE" = "jp2a" ] && [[ ! " ${USER_SET_FLAGS[@]} " =~ " s " && ! " ${USER_SET_FLAGS[@]} " =~ " ch " ]]; then
        STYLE=${JP2A_STYLES[$RANDOM % ${#JP2A_STYLES[@]}]}
    fi
    if [ "$ENGINE" = "chafa" ] && [[ ! " ${USER_SET_FLAGS[@]} " =~ " symbols " ]]; then
        CHAFA_SYMBOLS=${CHAFA_SYMBOL_SETS[$RANDOM % ${#CHAFA_SYMBOL_SETS[@]}]}
    fi
    if [[ ! " ${USER_SET_FLAGS[@]} " =~ " c " ]]; then
        COLOR_MODE=${COLOR_MODES[$RANDOM % ${#COLOR_MODES[@]}]}
    fi
    if [[ ! " ${USER_SET_FLAGS[@]} " =~ " pt " ]]; then
        PADDING_TOP=$((RANDOM % 11))
    fi
    if [[ ! " ${USER_SET_FLAGS[@]} " =~ " pb " ]]; then
        PADDING_BOTTOM=$((RANDOM % 11))
    fi
    if [[ ! " ${USER_SET_FLAGS[@]} " =~ " pl " ]]; then
        PADDING_LEFT=$((RANDOM % 11))
    fi
    if [[ ! " ${USER_SET_FLAGS[@]} " =~ " pr " ]]; then
        PADDING_RIGHT=$((RANDOM % 11))
    fi
    if [ "$ENGINE" = "jp2a" ] && [[ ! " ${USER_SET_FLAGS[@]} " =~ " ch " ]]; then
        CUSTOM_CHARS=${CUSTOM_CHARS_OPTIONS[$RANDOM % ${#CUSTOM_CHARS_OPTIONS[@]}]}
    fi
    if [ "$ENGINE" = "chafa" ] && [[ ! " ${USER_SET_FLAGS[@]} " =~ " fg-only " ]]; then
        CHAFA_FG_ONLY=$((RANDOM % 2))
    fi
fi

# ========== Dependencies ==========
check_command() { command -v "$1" &> /dev/null; }
install_package() {
    local package=$1
    echo "The program '$package' is required but not installed."
    exit 1
}
if [ "$ENGINE" = "jp2a" ]; then
    check_command jp2a || install_package "jp2a"
else
    check_command chafa || install_package "chafa"
fi
check_command identify || install_package "ImageMagick"

# ========== Image Dimensions ==========
IMG_DIMENSIONS=$(identify -format "%w %h" "$IMAGE")
IMG_WIDTH=$(echo "$IMG_DIMENSIONS" | cut -d' ' -f1)
IMG_HEIGHT=$(echo "$IMG_DIMENSIONS" | cut -d' ' -f2)

CHAR_ASPECT_RATIO=0.5

if [ -n "$CUSTOM_WIDTH" ] && [ -n "$CUSTOM_HEIGHT" ]; then
    FINAL_WIDTH="$CUSTOM_WIDTH"
    FINAL_HEIGHT="$CUSTOM_HEIGHT"
else
    TERM_COLS=$(tput cols 2>/dev/null || echo 80)
    TERM_LINES=$(tput lines 2>/dev/null || echo 24)
    TERM_COLS=$((TERM_COLS - 4))
    TERM_LINES=$((TERM_LINES - 4))
    IMAGE_RATIO=$(awk "BEGIN {print $IMG_WIDTH / $IMG_HEIGHT}")
    TERMINAL_RATIO=$(awk "BEGIN {print $TERM_COLS / ($TERM_LINES * $CHAR_ASPECT_RATIO)}")
    if [ -n "$CUSTOM_WIDTH" ]; then
        FINAL_WIDTH="$CUSTOM_WIDTH"
        FINAL_HEIGHT=$(awk "BEGIN {printf \"%d\", $CUSTOM_WIDTH / $IMAGE_RATIO * $CHAR_ASPECT_RATIO}")
    elif [ -n "$CUSTOM_HEIGHT" ]; then
        FINAL_HEIGHT="$CUSTOM_HEIGHT"
        FINAL_WIDTH=$(awk "BEGIN {printf \"%d\", $CUSTOM_HEIGHT * $IMAGE_RATIO / $CHAR_ASPECT_RATIO}")
    else
        if awk "BEGIN {exit !($IMAGE_RATIO > $TERMINAL_RATIO)}"; then
            FINAL_WIDTH="$TERM_COLS"
            FINAL_HEIGHT=$(awk "BEGIN {printf \"%d\", $FINAL_WIDTH / $IMAGE_RATIO * $CHAR_ASPECT_RATIO}")
        else
            FINAL_HEIGHT="$TERM_LINES"
            FINAL_WIDTH=$(awk "BEGIN {printf \"%d\", $FINAL_HEIGHT * $IMAGE_RATIO / $CHAR_ASPECT_RATIO}")
        fi
    fi
fi

# ========== Color handling ==========
COLOR_FLAG=""
if [ "$ENGINE" = "jp2a" ]; then
    case "$COLOR_MODE" in
        auto)
            if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
                COLOR_FLAG="--colors"
            elif [[ $(tput colors 2>/dev/null) -ge 256 ]]; then
                COLOR_FLAG="--color"
            fi
            ;;
        none) COLOR_FLAG="" ;;
        256) COLOR_FLAG="--color" ;;
        truecolor) COLOR_FLAG="--colors" ;;
    esac
else # chafa
    case "$COLOR_MODE" in
        auto)
            if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
                COLOR_FLAG="--colors=full"
            elif [[ $(tput colors 2>/dev/null) -ge 256 ]]; then
                COLOR_FLAG="--colors=256"
            else
                COLOR_FLAG="--colors=16"
            fi
            ;;
        none) COLOR_FLAG="--colors=none" ;;
        256) COLOR_FLAG="--colors=256" ;;
        truecolor) COLOR_FLAG="--colors=full" ;;
    esac
fi

# ========== Style mapping (JP2A only) ==========
if [ "$ENGINE" = "jp2a" ]; then
    if [ -n "$CUSTOM_CHARS" ]; then
        JP2A_CHARS="--chars=$CUSTOM_CHARS"
    else
        case "$STYLE" in
            standard) JP2A_CHARS="--chars=A@#&%*+:-." ;;
            fullblocks) JP2A_CHARS="--chars=██" ;;   
            net) JP2A_CHARS="--chars=🮐🮐" ;;
            bars) JP2A_CHARS="--chars=█▌▐" ;;
            cutblock) JP2A_CHARS="--chars=🭁🭁" ;;
            agean) JP2A_CHARS="--chars=𐄊𐄎𐄗𐄞𐄧𐄳" ;;
            chess) JP2A_CHARS="--chars=♜♞♝♛♚♝♞♜♟♙♖♘♗♕♔♗♘♖" ;;
            dots) JP2A_CHARS="--chars=•°·." ;;            
            braille) JP2A_CHARS="--chars=⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿" ;;
            enclosed) JP2A_CHARS="--chars=🅐🅑🅒🅓🅔🅕🅖🅗🅘🅙🅚🅛🅜🅝🅞🅟🅠🅡🅢🅣🅤🅥🅦🅧🅨🅩" ;;
            fade) JP2A_CHARS="--chars=@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,'\"^. " ;;
            alchemy) JP2A_CHARS="--chars=🜀🜁🜂🜃🜄🜅🜆🜇🜈🜉🜊🜋🜌🜍🜎🜏🜐🜑🜒🜓🜔🜕🜖🜗🜘🜙🜚🜛🜜🜝🜞🜟🜠🜡🜢🜣🜤🜥🜦🜧🜨🜩🜪🜫🜬🜭🜮🜯🜰🜱🜲🜳🜴🜵🜶🜷🜸🜹🜺🜻🜼🜽🜾🜿🝀🝁🝂🝃🝄🝅🝆🝇🝈🝉🝊🝋🝌🝍🝎🝏🝐🝑🝒🝓🝔🝕🝖🝗🝘🝙🝚🝛🝜🝝🝞🝟🝠🝡🝢🝣🝤🝥🝦🝧🝨🝩🝪🝫🝬🝭🝮🝯🝰🝱🝲🝳" ;;
            greek) JP2A_CHARS="--chars=ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξοπρστυφχψω" ;;
            runes) JP2A_CHARS="--chars= ᚠᚡᚢᚣᚤᚥᚦᚧᚨᚩᚪᚫᚬᚭᚮᚯᚰᚱᚲᚳᚴᚵᚶᚷᚸᚹᚺᚻᚼᚽᚾᚿᛀᛁᛂᛃᛄᛅᛆᛇᛈᛉᛊᛋᛌᛍᛎᛏᛐᛑᛒᛓᛔᛕᛖᛗᛘᛙᛚᛛᛜᛝᛞᛟᛠᛡᛢᛣᛤᛥᛦᛧᛨᛩᛪ᛫᛬᛭ᛴᛵᛶᛷᛸᛮᛯᛰᛱᛲᛳ" ;;
            border) JP2A_CHARS="--chars=─│┌┐└┘" ;;
            fwquartersquare) JP2A_CHARS="--chars=🙾🙾" ;;
            bwquartersquare) JP2A_CHARS="--chars=🙿🙿" ;;
            fwslash) JP2A_CHARS="--chars=🙼🙼" ;;
            bwslash) JP2A_CHARS="--chars=🙽🙽" ;;
            floral) JP2A_CHARS="--chars=🙨🙪" ;;
            music) JP2A_CHARS="--chars=𝄞𝄆𝄇♩♪♫♬" ;;
            ornaments) JP2A_CHARS="--chars=♡♥❤❥❢❣❡☙❦❧🙰🙱🙲🙳🙴🙵🙐🙑🙒🙓🙔🙕🙖🙗🙚🙘🙛🙙🙞🙜🙟🙝🙠🙡🙢🙣🙤🙥🙦🙧🙬🙭🙮🙯🙶🙷🙸" ;;
            cuneiform) JP2A_CHARS="--chars=𒄙𒄩𒄦𒃽𒄣𒃫𒁽𒃠𒄉𒄂𒂌𒄇𒃰𒂜𒃿𒄆𒃠𒃦𒂞𒂸𒁾𒄈𒃼𒃯𒄜𒂀𒄡𒃡𒁺𒃳𒃪𒃲𒂻𒂍𒃺𒂶𒄤𒃾𒄥𒂝𒃥𒃹𒃾𒄋𒃲𒃸𒄜𒃚𒃭𒃔𒃞𒄃𒄢𒄞𒄧𒄫𒄇𒃮𒃛𒂈𒃜𒃩𒃹𒃺𒄆𒃙𒁾𒃟𒂃𒂌𒄖𒄧𒃭𒄚𒃝𒃯𒂽𒃡𒄉𒃸𒄛𒂎𒃴𒄌𒄛𒄘𒄨𒄗𒃧𒃻𒄞𒃕𒄁𒃣𒄨𒃻𒃖𒂂𒄍𒃚𒂝𒄅𒄄𒃥𒃓𒂠𒃤𒃘𒄟𒂍𒃝𒄃𒃷𒁽𒄬𒃩𒂀𒃮𒄠𒃱𒂎𒂺𒃙𒄗𒄦𒃘𒄌𒃕𒃬𒂼𒃼𒄒𒄄𒃷𒄟𒂃𒃓𒃞𒃳𒃔𒃱𒄙𒄤𒂈𒄖𒁻𒃢𒄢𒄂𒃿𒁿𒃣𒄫𒃽𒂞𒄀𒃗𒂜𒄅𒄚𒁿𒄠𒄍𒄝𒂂𒂁𒄪𒂵𒃖𒄊𒄩𒁹𒄎𒃶𒃗𒂾𒄥𒄁𒁼𒄎𒄝𒃰𒂿𒃛𒃨𒄒𒃜𒃬𒃨𒃶𒄪𒄀𒃫𒄘𒃴𒄊𒃤𒄡𒂁𒃪𒂠𒄈𒃟𒃦" ;;
            dominoh) JP2A_CHARS="--chars=🁣🁤🁥🁦🁧🁨🁩🁪🁫🁬🁭🁮🁯🁰🁱🁲🁳🁴🁵🁶🁷🁸🁹🁺🁻🁼🁽🁾🁿🂀🂁🂂🂃🂄🂅🂆🂇🂈🂉🂊🂋🂌🂍🂎🂏🂐🂑🂒🂓🁢" ;;
            dominov) JP2A_CHARS="--chars=🀱🀲🀳🀴🀵🀶🀷🀸🀹🀺🀻🀼🀽🀾🀿🁀🁁🁂🁃🁄🁅🁆🁇🁈🁉🁊🁋🁌🁍🁎🁏🁐🁑🁒🁓🁔🁕🁖🁗🁘🁙🁚🁛🁜🁝🁞🁟🁠🁡🀰" ;;
            cards) JP2A_CHARS="--chars=🂱🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂼🂽🂾🂡🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂬🂭🂮🃁🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃌🃍🃎🃑🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃜🃝🃞🂠🃟" ;;
            tinycards) JP2A_CHARS="--chars=🂿🃠🃡🃢🃣🃤🃥🃦🃧🃨🃪🃫🃬🃭🃮🃯🃰🃱🃲🃳🃴🃵" ;;
            suits) JP2A_CHARS="--chars=♠♣♥♦♤♧♡♢" ;;
            hieroglyphs) JP2A_CHARS="--chars=𓄒𓄇𓎌𓍸𓄧𓁽𓇼𓇩𓎘𓂪𓇞𓂱𓆆𓇜𓂦𓁾𓎔𓍀𓍌𓊨𓎤𓆅𓏟𓎓𓍦𓏃𓄎𓄒𓄲𓂨𓇈𓆅𓇙𓍨𓇥𓆇𓍃𓄢𓄮𓍐𓇖𓍗𓁘𓄳𓄙𓄏𓂼𓋆𓍂𓊦𓁋𓎪𓋒𓇮𓄉𓏛𓅴𓆀𓋕𓍅𓄠𓆀𓊎𓇶𓏏𓍰𓇎𓊮𓊮𓍫𓆀𓂿𓁏𓇗𓎥𓂿𓎹𓇕𓊣𓏏𓎯𓎡𓇠𓎑𓇗𓏠𓆇𓇎𓎎𓋖𓄞𓇨𓍞𓆄𓋗𓄴𓏂𓆆𓄄𓊙𓂉𓍈𓍸𓊙𓂔𓎩𓇌𓂙𓇜𓊗𓂣𓇄𓋜𓏞𓊄𓍪𓇗𓇐𓄤𓇿𓊻𓏖𓄭𓎮𓂧𓇄𓄧𓅶𓎂𓎂𓆆𓎄𓄑𓇍𓊆𓋏𓄃𓆇𓄊𓂢𓇀𓂝𓇹𓇱𓍕𓇚𓆄𓎣𓄤𓋆𓊗𓍼𓄤𓂿𓍠𓅨𓎔𓂾𓊗𓊯𓎼𓇽𓍹𓇑𓆇𓇼𓊗𓂼𓎭𓍭𓎫𓄻𓎗𓍄𓇹𓄨𓍭𓎃𓎄𓍧𓍱𓊡𓄘𓆇𓎡𓎞𓇬𓎒𓇚𓆇𓇗𓋗𓆇𓇷𓋚𓊣𓂽𓎵𓄖𓏗𓏄𓊄𓆆𓇷𓎔𓄐𓄡𓊲𓏆𓍻" ;;

            hexagram) JP2A_CHARS="--chars=䷀䷁䷂䷃䷄䷅䷆䷇䷈䷉䷊䷋䷌䷍䷎䷏䷐䷑䷒䷓䷔䷕䷖䷗䷘䷙䷚䷛䷜䷝䷞䷟䷠䷡䷢䷣䷤䷥䷦䷧䷨䷩䷪䷫䷬䷭䷮䷯䷰䷱䷲䷳䷴䷵䷶䷷䷸䷹䷺䷻䷼䷽䷾䷿" ;;
            geometricshapes) JP2A_CHARS="--chars=🞄●⬤◯⚬○🞅🞆🞇🞈🞉◌❍🔾🔿◙◍🞊🞋◴◵◶◷◔◕◖◗⯊⯋◚◛◐◑◓◒⚆⚇⚈⚉◜◝◞◟◠◡⯀■◼▪🞍🞌□◻▫🞎🞏🞐🞑🞒🞓🞔▣🞕🞖⧆⧇⧈⛋▢⧉⧠❏❐❑❒◰◱◲◳◧◨◩◪◫⧄⧅🟗🟘▤▥▦▧▨▩▬▮▭▯◬⟁⛛◀▶▲▼⯇⯈⯅⯆◂▸▴▾◁▷△▽◃▹▵▿🞀🞂🞁🞃◸◹◺◿◤◥◣◢◭◮⧨⧩🟕🟖⯁◆⬥🞙⬩🞘🞗❖♦♢◇⬦🞛◈🞚⟐🞜⬖⬗⬘⬙⯌⯎⟡⯍⯏⌑◊⧫🞟🞝🞞🞠▰▱⬟⯂⬢⬣⯃⯄" ;;
            stars) JP2A_CHARS="--chars=★⭑🟉🟊☆⭒⚝✩✯✰✪✫✬✭✮⛤⛥⛦⛧🟀🟁🟂🟃✦✧🟄🟅🟆🟇🟈🟋🟌🟍✶✡✴❂✵✷✸🟎🟏🟐🟑✹🟒🟓🟔*⁎⁑✱✲⧆꙳✻✼✽❃❉✢✣✤✥🞯🞰🞱🞲🞳🞴🞵🞶🞷🞸🞹🞺🞻🞼🞽🞾🞿✳❊❋✺❇❈❄❅❆✿❀❁✾" ;;
            mahajong) JP2A_CHARS="--chars=🀇🀈🀉🀊🀋🀌🀍🀎🀏🀐🀑🀒🀓🀔🀕🀖🀗🀘🀙🀚🀛🀜🀝🀞🀟🀠🀡🀀🀁🀂🀃🀢🀣🀤🀥🀦🀧🀨🀩🀅🀆🀪" ;;
            domino) JP2A_CHARS="--chars=🁣🁤🁥🁦🁧🁨🁩🁪🁫🁬🁭🁮🁯🁰🁱🁲🁳🁴🁵🁶🁷🁸🁹🁺🁻🁼🁽🁾🁿🂀🂁🂂🂃🂄🂅🂆🂇🂈🂉🂊🂋🂌🂍🂎🂏🂐🂑🂒🂓🁢🀱🀲🀳🀴🀵🀶🀷🀸🀹🀺🀻🀼🀽🀾🀿🁀🁁🁂🁃🁄🁅🁆🁇🁈🁉🁊🁋🁌🁍🁎🁏🁐🁑🁒🁓🁔🁕🁖🁗🁘🁙🁚🁛🁜🁝🁞🁟🁠🁡🀰" ;;
            playingcards) JP2A_CHARS="--chars=♠♣♥♦♤♧♡♢🂱🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂼🂽🂾🂡🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂬🂭🂮🃁🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃌🃍🃎🃑🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃜🃝🃞🂠🃟🂿🃠🃡🃢🃣🃤🃥🃦🃧🃨🃪🃫🃬🃭🃮🃯🃰🃱🃲🃳🃴🃵" ;;
            *) JP2A_CHARS="" ;;
        esac
    fi
fi

# ========== Handle File Overwrite ==========
if [ -f "$OUTPUT" ]; then
    read -p "File '$OUTPUT' exists. Overwrite? (y/n): " choice
    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# ========== Generate ASCII ==========
ASCII_TEMP=$(mktemp)

if [ "$ENGINE" = "chafa" ]; then
    SYMBOLS_FLAG=""
    if [ -n "$CHAFA_SYMBOLS" ]; then
        SYMBOLS_FLAG="--symbols=$CHAFA_SYMBOLS"
    fi
    FG_ONLY_FLAG=""
    if [ "$CHAFA_FG_ONLY" = true ] || [ "$CHAFA_FG_ONLY" -eq 1 ]; then
        FG_ONLY_FLAG="--fg-only"
    fi
    chafa --size="${FINAL_WIDTH}x${FINAL_HEIGHT}" $COLOR_FLAG $SYMBOLS_FLAG $FG_ONLY_FLAG "$IMAGE" > "$ASCII_TEMP"
else
    jp2a --width="$FINAL_WIDTH" --height="$FINAL_HEIGHT" $COLOR_FLAG $JP2A_CHARS "$IMAGE" > "$ASCII_TEMP"
fi

# ========== Apply Padding ==========
PAD_TOP=$(awk "BEGIN {print int($FINAL_HEIGHT * $PADDING_TOP / 100)}")
PAD_BOTTOM=$(awk "BEGIN {print int($FINAL_HEIGHT * $PADDING_BOTTOM / 100)}")
PAD_LEFT=$(awk "BEGIN {print int($FINAL_WIDTH * $PADDING_LEFT / 100)}")
PAD_RIGHT=$(awk "BEGIN {print int($FINAL_WIDTH * $PADDING_RIGHT / 100)}")

PADDED_OUTPUT=$(mktemp)

# Top padding
for i in $(seq 1 $PAD_TOP); do echo ""; done >> "$PADDED_OUTPUT"

# Left & Right padding lines
while IFS= read -r line; do
    printf "%*s%s%*s\n" "$PAD_LEFT" "" "$line" "$PAD_RIGHT" "" >> "$PADDED_OUTPUT"
done < "$ASCII_TEMP"

# Bottom padding
for i in $(seq 1 $PAD_BOTTOM); do echo ""; done >> "$PADDED_OUTPUT"

mv "$PADDED_OUTPUT" "$OUTPUT"
rm -f "$ASCII_TEMP"

# ========== Preview output if requested ==========
if [ "$PREVIEW" = true ]; then
    echo "📺 Preview of ASCII art:"
    cat "$OUTPUT"
fi

echo "✅ ASCII art saved to $OUTPUT"
echo "   Engine: $ENGINE | Width: $FINAL_WIDTH | Height: $FINAL_HEIGHT | Color: $COLOR_MODE | Style: $STYLE | Symbols: $CHAFA_SYMBOLS | FG-only: $CHAFA_FG_ONLY | Padding top:$PADDING_TOP% bottom:$PADDING_BOTTOM% left:$PADDING_LEFT% right:$PADDING_RIGHT%"
