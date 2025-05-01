#!/bin/bash

# Author: Haitham Aouati (YHΞ)
# GitHub: github.com/haithamaouati

# ASCII format
normal="\e[0m"
bold="\e[1m"
underlined="\e[4m"
bold_green="\e[1;32m"
bold_red="\e[1;31m"

# Capture start time
start_time=$(date +%s)

# Trap Ctrl+C
trap 'end_time=$(date +%s); elapsed=$((end_time - start_time)); echo -e "\n${bold_red}Process interrupted.${normal} Total time: ${bold}$elapsed seconds.${normal}\n"; exit 0' SIGINT

# Dependency check
check_dependencies() {
    local dependencies=("curl" "grep" "sed")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo -e "${bold_red}Error:${normal} $dep is not installed. Please install it first."
            exit 1
        fi
    done
}

check_dependencies

# ASCII Banner
banner() {
    clear
    echo -e "${bold_red}"
    cat <<EOF
                 ....       ................
              .......      .................
            .........   ................
                       .............           .
        ,;,.               .....          .;;; .
        ...''......','..   ..... .',.....',,'.
      ........................................ .
   .  ..........................................
      .........................................
      .........................................
        .......................................
EOF
    echo
    echo -e "${bold_red}			Katana${normal}"
    echo -e "  	       TikTok Usernames Checker"
    echo -e "	       Author: Haitham Aouati (YHΞ)"
    echo -e "	   GitHub: ${underlined}github.com/haithamaouati${normal}"
    echo
}

banner

# Initialize available usernames file
AVAILABLE_FILE="available_usernames.txt"
> "$AVAILABLE_FILE"   # Clean file on start

# Initialize counters
total_checked=0
available_count=0
taken_count=0

usage() {
    echo "Usage: $0 -u <username>"
    echo "Options:"
    echo "  -u, --username    Username or file with usernames"
    echo -e "  -h, --help        Show this help message\n"
    exit 1
}

# Check if a username is available
check_username() {
    local username="$1"
    if [ -z "$username" ]; then
        echo -e "${bold_red}[!] Error:${normal} Empty username provided. Skipping..."
        return
    fi

    local url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"

    source_code=$(curl -sL "$url")

    uniqueId=$(echo "$source_code" | grep -oP '"uniqueId":"[^"]*"' | sed 's/"uniqueId":"//;s/"//')

    # Increment total checked
    total_checked=$((total_checked + 1))

    if [ -z "$uniqueId" ]; then
        echo -e "${bold_green}[+]${normal} Checked username: ${bold_green}@$username${normal} is available."
        echo "$username" >> "$AVAILABLE_FILE"
        # Increment available count
        available_count=$((available_count + 1))
    else
        echo -e "${bold_red}[-]${normal} Checked username: ${bold_red}@$username${normal} is already taken."
        # Increment taken count
        taken_count=$((taken_count + 1))
    fi
}

# Flags parsing
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -u|--username)
            if [[ -n "$2" && ${2:0:1} != "-" ]]; then
                TARGET="$2"
                echo -e "${bold}[*]${normal} Checking for usernames: ${bold_green}@$2${normal}\n"
                shift 2
            else
                echo -e "${bold_red}[!] Error:${normal} No username provided after -u flag.\n"
                usage
            fi
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${bold_red}[!] Unknown option:${normal} $1\n"
            usage
            ;;
    esac
done

# Validation
if [ -z "$TARGET" ]; then
    echo -e "${bold_red}[!] Error:${normal} No username or file provided.\n"
    usage
fi

# Main logic
if [ -f "$TARGET" ]; then
    while IFS= read -r username || [ -n "$username" ]; do
        [ -z "$username" ] && continue
        check_username "$username"
        sleep_time=$((RANDOM % 5 + 1))
        sleep "$sleep_time"
    done < "$TARGET"
else
    check_username "$TARGET"
fi

# Capture end time and show elapsed time
end_time=$(date +%s)
elapsed=$((end_time - start_time))

# Output process completion with stats
echo -e "\n${bold_green}[¡] Process finished.${normal} Total time: ${bold}$elapsed seconds.${normal}\n"
echo -e "${bold}[*]${normal} Total usernames checked: ${bold}$total_checked${normal}"
echo -e "${bold_green}[+]${normal} Available usernames: ${bold_green}$available_count${normal}"
echo -e "${bold_red}[-]${normal} Taken usernames: ${bold_red}$taken_count${normal}\n"
