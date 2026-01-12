#!/bin/bash
# XPRO NEXUS DECODER - INSTALLATION SCRIPT
# For Kali Linux, Ubuntu, Debian, and other Linux distributions

set -e

# Colors for output
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
BOLD='\033[1m'
RESET='\033[0m'

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        ██╗  ██╗██████╗  ██████╗     ███╗   ██╗███████╗██╗  ██╗██╗   ██╗║"
echo "║        ╚██╗██╔╝██╔══██╗██╔═══██╗    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║║"
echo "║         ╚███╔╝ ██████╔╝██║   ██║    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║║"
echo "║         ██╔██╗ ██╔═══╝ ██║   ██║    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║║"
echo "║        ██╔╝ ██╗██║     ╚██████╔╝    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝║"
echo "║        ╚═╝  ╚═╝╚═╝      ╚═════╝     ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                 XPRO NEXUS DECODER INSTALLER                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}[!] Warning: Running as root${RESET}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [[ -f /etc/debian_version ]]; then
        OS=Debian
        VER=$(cat /etc/debian_version)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    echo -e "${BLUE}[*] Detected: $OS $VER${RESET}"
}

# Install dependencies based on OS
install_dependencies() {
    echo -e "\n${CYAN}[*] Installing system dependencies...${RESET}"
    
    if [[ "$OS" == *"Kali"* ]] || [[ "$OS" == *"Debian"* ]] || [[ "$OS" == *"Ubuntu"* ]]; then
        sudo apt update
        sudo apt install -y \
            python3 \
            python3-pip \
            python3-dev \
            build-essential \
            git \
            wget \
            curl \
            libssl-dev \
            libffi-dev \
            python3-venv \
            python3-wheel \
            pkg-config \
            libjpeg-dev \
            zlib1g-dev
        
    elif [[ "$OS" == *"Fedora"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"CentOS"* ]]; then
        sudo dnf install -y \
            python3 \
            python3-pip \
            python3-devel \
            gcc \
            g++ \
            make \
            git \
            wget \
            curl \
            openssl-devel \
            libffi-devel
        
    elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        sudo pacman -Syu --noconfirm \
            python \
            python-pip \
            base-devel \
            git \
            wget \
            curl \
            openssl \
            libffi
        
    else
        echo -e "${YELLOW}[!] Unknown OS. Installing generic dependencies...${RESET}"
        echo -e "${RED}[!] Manual installation may be required${RESET}"
    fi
}

# Setup Python virtual environment
setup_venv() {
    echo -e "\n${CYAN}[*] Setting up Python virtual environment...${RESET}"
    
    # Check if venv exists
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
        echo -e "${GREEN}[+] Virtual environment created${RESET}"
    else
        echo -e "${YELLOW}[!] Virtual environment already exists${RESET}"
    fi
    
    # Activate venv
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
}

# Install Python packages
install_python_packages() {
    echo -e "\n${CYAN}[*] Installing Python packages...${RESET}"
    
    # Create requirements file
    cat > requirements.txt << 'EOF'
# Core dependencies
uncompyle6>=3.9.0
decompyle3>=3.9.0
xdis>=6.0.0

# AI/ML dependencies (optional)
numpy>=1.24.0
scipy>=1.10.0
pandas>=2.0.0
scikit-learn>=1.2.0

# Utility packages
colorama>=0.4.0
tqdm>=4.65.0
psutil>=5.9.0
requests>=2.28.0
rich>=13.0.0

# Development
black>=23.0.0
flake8>=6.0.0
pytest>=7.0.0
EOF
    
    # Install packages
    echo -e "${BLUE}[*] Installing from requirements.txt...${RESET}"
    pip install -r requirements.txt
    
    # Install optional AI packages
    echo -e "\n${CYAN}[*] Installing optional AI packages...${RESET}"
    read -p "Install AI/ML packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        pip install tensorflow
        echo -e "${GREEN}[+] AI packages installed${RESET}"
    fi
}

# Configure the decoder
configure_decoder() {
    echo -e "\n${CYAN}[*] Configuring XPRO Decoder...${RESET}"
    
    # Make main script executable
    chmod +x xpro_decoder.py
    
    # Create config file
    cat > config.json << 'EOF'
{
    "version": "10.0",
    "author": "XPRO-NEXUS",
    "max_threads": 16,
    "max_processes": 8,
    "timeout": 60,
    "output_dir": "XPRO_OUTPUT",
    "enable_ai": true,
    "enable_logging": true,
    "backup_files": true
}
EOF
    
    # Create examples directory
    mkdir -p examples
    cat > examples/example_encrypted.py << 'EOF'
# Example marshal encrypted file
import marshal
exec(marshal.loads(b'\xe3\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\xf3\x10\x00\x00\x00\x97\x00d\x00\x83\x01Z\x00d\x01S\x00)\x02N\xe9\x01\x00\x00\x00)\x01\xda\x05print\xa9\x00r\x03\x00\x00\x00r\x03\x00\x00\x00\xfa\x08<module>\xda\x08<module>\x01\x00\x00\x00\xf3\x00\x00\x00\x00'))
EOF
    
    echo -e "${GREEN}[+] Configuration complete${RESET}"
}

# Test installation
test_installation() {
    echo -e "\n${CYAN}[*] Testing installation...${RESET}"
    
    # Test Python
    if python3 --version; then
        echo -e "${GREEN}[✓] Python is working${RESET}"
    else
        echo -e "${RED}[✗] Python test failed${RESET}"
        exit 1
    fi
    
    # Test main script
    if [[ -f "xpro_decoder.py" ]]; then
        echo -e "${GREEN}[✓] Main script found${RESET}"
    else
        echo -e "${RED}[✗] Main script not found${RESET}"
        exit 1
    fi
    
    # Quick functionality test
    echo -e "\n${BLUE}[*] Running quick test...${RESET}"
    timeout 5 python3 -c "import marshal, uncompyle6; print('✓ All imports successful')" && \
    echo -e "${GREEN}[✓] Basic functionality test passed${RESET}" || \
    echo -e "${YELLOW}[!] Some imports failed (may need manual installation)${RESET}"
}

# Main installation function
main_install() {
    detect_os
    install_dependencies
    setup_venv
    install_python_packages
    configure_decoder
    test_installation
    
    echo -e "\n${GREEN}========================================${RESET}"
    echo -e "${GREEN}✅ XPRO NEXUS DECODER INSTALLATION COMPLETE!${RESET}"
    echo -e "${GREEN}========================================${RESET}"
    
    echo -e "\n${CYAN}📦 Installation Summary:${RESET}"
    echo -e "${WHITE}• Python virtual environment: ${GREEN}venv/${RESET}"
    echo -e "${WHITE}• Main decoder script: ${GREEN}xpro_decoder.py${RESET}"
    echo -e "${WHITE}• Configuration: ${GREEN}config.json${RESET}"
    echo -e "${WHITE}• Examples: ${GREEN}examples/${RESET}"
    
    echo -e "\n${MAGENTA}🚀 Quick Start:${RESET}"
    echo -e "${WHITE}1. Activate virtual environment:${RESET}"
    echo -e "   ${CYAN}source venv/bin/activate${RESET}"
    echo -e "${WHITE}2. Run the decoder:${RESET}"
    echo -e "   ${CYAN}python3 xpro_decoder.py${RESET}"
    echo -e "${WHITE}3. Follow the interactive prompts${RESET}"
    
    echo -e "\n${YELLOW}💡 Tip:${RESET} Run ${CYAN}./install.sh update${RESET} to update the decoder"
    
    # Create update script
    cat > update.sh << 'EOF'
#!/bin/bash
# Update script for XPRO NEXUS Decoder

echo "Updating XPRO NEXUS Decoder..."
git pull origin main
source venv/bin/activate
pip install --upgrade -r requirements.txt
echo "Update complete!"
EOF
    chmod +x update.sh
}

# Update function
update_decoder() {
    echo -e "${CYAN}[*] Updating XPRO NEXUS Decoder...${RESET}"
    
    if [[ -d ".git" ]]; then
        git pull origin main
    else
        echo -e "${YELLOW}[!] Not a git repository${RESET}"
    fi
    
    source venv/bin/activate
    pip install --upgrade -r requirements.txt
    
    echo -e "${GREEN}[+] Update complete${RESET}"
}

# Uninstall function
uninstall_decoder() {
    echo -e "${YELLOW}[!] This will remove XPRO NEXUS Decoder${RESET}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf venv
        rm -f requirements.txt config.json
        echo -e "${GREEN}[+] Uninstalled${RESET}"
    fi
}

# Handle arguments
case "$1" in
    "update")
        update_decoder
        ;;
    "uninstall")
        uninstall_decoder
        ;;
    "test")
        test_installation
        ;;
    *)
        main_install
        ;;
esac

exit 0