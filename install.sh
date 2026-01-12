#!/bin/bash
# XPRO NEXUS DECODER - INSTALLATION SCRIPT
# Optimized for Kali Linux, Ubuntu, Debian, and other Linux distributions

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
echo "║              Optimized for Kali Linux Python 3.13            ║"
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

# Check Python version
check_python_version() {
    echo -e "\n${CYAN}[*] Checking Python version...${RESET}"
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        echo -e "${GREEN}[+] Python $PYTHON_VERSION detected${RESET}"
        
        # Check if Python 3.7 or higher
        MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d'.' -f1)
        MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d'.' -f2)
        
        if [[ $MAJOR_VERSION -lt 3 ]] || [[ $MAJOR_VERSION -eq 3 && $MINOR_VERSION -lt 7 ]]; then
            echo -e "${RED}[✗] Python 3.7 or higher is required${RESET}"
            echo -e "${YELLOW}[!] Please upgrade Python and try again${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}[✗] Python3 not found${RESET}"
        exit 1
    fi
}

# Install dependencies based on OS
install_dependencies() {
    echo -e "\n${CYAN}[*] Installing system dependencies...${RESET}"
    
    if [[ "$OS" == *"Kali"* ]]; then
        echo -e "${YELLOW}[!] Kali Linux detected - Using special mode${RESET}"
        echo -e "${WHITE}[*] Installing system packages...${RESET}"
        
        sudo apt update
        sudo apt install -y \
            python3 \
            python3-pip \
            python3-dev \
            python3-venv \
            python3-wheel \
            build-essential \
            git \
            wget \
            curl \
            libssl-dev \
            libffi-dev
        
        # Kali Linux specific fix for Python packages
        echo -e "${WHITE}[*] Configuring pip for Kali Linux...${RESET}"
        
        # Create pip config for --break-system-packages
        mkdir -p ~/.config/pip
        cat > ~/.config/pip/pip.conf << EOF
[global]
break-system-packages = true
EOF
        
        echo -e "${GREEN}[+] Kali Linux configuration applied${RESET}"
        
    elif [[ "$OS" == *"Debian"* ]] || [[ "$OS" == *"Ubuntu"* ]]; then
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
            pkg-config
        
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
        echo -e "${WHITE}[*] Creating virtual environment...${RESET}"
        python3 -m venv venv
        echo -e "${GREEN}[+] Virtual environment created${RESET}"
    else
        echo -e "${YELLOW}[!] Virtual environment already exists${RESET}"
        read -p "Recreate virtual environment? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${WHITE}[*] Removing old virtual environment...${RESET}"
            rm -rf venv
            python3 -m venv venv
            echo -e "${GREEN}[+] Virtual environment recreated${RESET}"
        fi
    fi
    
    # Activate venv
    source venv/bin/activate
    
    # Upgrade pip
    echo -e "${WHITE}[*] Upgrading pip...${RESET}"
    pip install --upgrade pip setuptools wheel
    
    # Check pip version
    PIP_VERSION=$(pip --version | awk '{print $2}')
    echo -e "${GREEN}[+] Using pip $PIP_VERSION${RESET}"
}

# Install Python packages with Kali Linux compatibility
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
    
    # Determine installation method based on OS
    if [[ "$OS" == *"Kali"* ]]; then
        echo -e "${YELLOW}[!] Kali Linux detected - Using --break-system-packages flag${RESET}"
        echo -e "${WHITE}[*] Installing packages...${RESET}"
        
        # Install packages with Kali Linux compatibility
        pip install -r requirements.txt --break-system-packages
        
        # Check for successful installation
        for pkg in uncompyle6 decompyle3 numpy; do
            if python3 -c "import $pkg" &>/dev/null; then
                echo -e "${GREEN}[✓] $pkg installed successfully${RESET}"
            else
                echo -e "${RED}[✗] $pkg installation failed${RESET}"
            fi
        done
        
    else
        # Normal installation for other OS
        echo -e "${BLUE}[*] Installing from requirements.txt...${RESET}"
        pip install -r requirements.txt
    fi
    
    # Install optional AI packages
    echo -e "\n${CYAN}[*] Optional AI/ML packages...${RESET}"
    read -p "Install advanced AI packages (PyTorch/TensorFlow)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ "$OS" == *"Kali"* ]]; then
            # Kali Linux compatible installation
            echo -e "${WHITE}[*] Installing PyTorch for CPU...${RESET}"
            pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --break-system-packages
            
            echo -e "${WHITE}[*] Installing TensorFlow...${RESET}"
            pip install tensorflow --break-system-packages
        else
            # Normal installation
            pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
            pip install tensorflow
        fi
        echo -e "${GREEN}[+] AI packages installed${RESET}"
    fi
}

# Configure the decoder
configure_decoder() {
    echo -e "\n${CYAN}[*] Configuring XPRO Decoder...${RESET}"
    
    # Make main script executable
    if [[ -f "xpro_decoder.py" ]]; then
        chmod +x xpro_decoder.py
        echo -e "${GREEN}[+] Main script made executable${RESET}"
    else
        echo -e "${RED}[✗] Main script not found${RESET}"
        echo -e "${YELLOW}[!] Please make sure xpro_decoder.py is in the current directory${RESET}"
        exit 1
    fi
    
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
    "backup_files": true,
    "kali_mode": true
}
EOF
    
    # Create examples directory
    mkdir -p examples
    cat > examples/example_encrypted.py << 'EOF'
# Example marshal encrypted file
import marshal
exec(marshal.loads(b'\xe3\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\xf3\x10\x00\x00\x00\x97\x00d\x00\x83\x01Z\x00d\x01S\x00)\x02N\xe9\x01\x00\x00\x00)\x01\xda\x05print\xa9\x00r\x03\x00\x00\x00r\x03\x00\x00\x00\xfa\x08<module>\xda\x08<module>\x01\x00\x00\x00\xf3\x00\x00\x00\x00'))
EOF
    
    # Create run script
    cat > run.sh << 'EOF'
#!/bin/bash
# XPRO NEXUS DECODER - Run Script

# Colors
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
RESET='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║             XPRO NEXUS DECODER v10.0                ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Check if virtual environment exists
if [[ -d "venv" ]]; then
    echo -e "${GREEN}[*] Activating virtual environment...${RESET}"
    source venv/bin/activate
else
    echo -e "${YELLOW}[!] Virtual environment not found${RESET}"
    echo -e "${CYAN}[*] Using system Python${RESET}"
fi

# Run the decoder
python3 xpro_decoder.py

# Deactivate venv if it was activated
if [[ -d "venv" ]]; then
    deactivate 2>/dev/null
fi
EOF
    chmod +x run.sh
    
    echo -e "${GREEN}[+] Configuration complete${RESET}"
}

# Test installation
test_installation() {
    echo -e "\n${CYAN}[*] Testing installation...${RESET}"
    
    # Activate virtual environment
    if [[ -d "venv" ]]; then
        source venv/bin/activate
        IN_VENV=true
    fi
    
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
        
        # Quick syntax check
        if python3 -m py_compile xpro_decoder.py 2>/dev/null; then
            echo -e "${GREEN}[✓] Main script syntax is valid${RESET}"
            rm -f __pycache__/*.pyc 2>/dev/null
            rmdir __pycache__ 2>/dev/null
        else
            echo -e "${YELLOW}[!] Syntax check warning${RESET}"
        fi
    else
        echo -e "${RED}[✗] Main script not found${RESET}"
        exit 1
    fi
    
    # Test core dependencies
    echo -e "\n${WHITE}[*] Testing core dependencies...${RESET}"
    
    REQUIRED_PACKAGES=("marshal" "uncompyle6" "decompyle3" "numpy")
    
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if python3 -c "import $pkg" &>/dev/null; then
            echo -e "${GREEN}[✓] $pkg import successful${RESET}"
        else
            echo -e "${YELLOW}[!] $pkg import failed${RESET}"
        fi
    done
    
    # Deactivate venv if activated
    if [[ "$IN_VENV" = true ]]; then
        deactivate
    fi
    
    echo -e "\n${GREEN}[✅] Installation test completed${RESET}"
}

# Main installation function
main_install() {
    detect_os
    check_python_version
    install_dependencies
    setup_venv
    install_python_packages
    configure_decoder
    test_installation
    
    echo -e "\n${GREEN}========================================${RESET}"
    echo -e "${GREEN}✅ XPRO NEXUS DECODER INSTALLATION COMPLETE!${RESET}"
    echo -e "${GREEN}========================================${RESET}"
    
    echo -e "\n${CYAN}📦 Installation Summary:${RESET}"
    echo -e "${WHITE}• Operating System: ${GREEN}$OS $VER${RESET}"
    echo -e "${WHITE}• Python Version: ${GREEN}$PYTHON_VERSION${RESET}"
    echo -e "${WHITE}• Virtual Environment: ${GREEN}venv/${RESET}"
    echo -e "${WHITE}• Main decoder script: ${GREEN}xpro_decoder.py${RESET}"
    echo -e "${WHITE}• Configuration: ${GREEN}config.json${RESET}"
    echo -e "${WHITE}• Run script: ${GREEN}run.sh${RESET}"
    echo -e "${WHITE}• Examples: ${GREEN}examples/${RESET}"
    
    echo -e "\n${MAGENTA}🚀 Quick Start Commands:${RESET}"
    echo -e "${WHITE}1. Run with virtual environment:${RESET}"
    echo -e "   ${CYAN}./run.sh${RESET}"
    echo -e "${WHITE}2. Or manually:${RESET}"
    echo -e "   ${CYAN}source venv/bin/activate${RESET}"
    echo -e "   ${CYAN}python3 xpro_decoder.py${RESET}"
    echo -e "   ${CYAN}deactivate${RESET}"
    
    echo -e "\n${YELLOW}💡 Tips for Kali Linux:${RESET}"
    echo -e "${WHITE}• If you get 'externally-managed-environment' error:${RESET}"
    echo -e "  ${CYAN}Use ./run.sh or activate venv first${RESET}"
    echo -e "${WHITE}• To update packages:${RESET}"
    echo -e "  ${CYAN}source venv/bin/activate && pip install --upgrade -r requirements.txt${RESET}"
    
    # Create update script
    cat > update.sh << 'EOF'
#!/bin/bash
# Update script for XPRO NEXUS Decoder

RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
CYAN='\033[0;96m'
RESET='\033[0m'

echo -e "${CYAN}[*] Updating XPRO NEXUS Decoder...${RESET}"

# Update from git if available
if [[ -d ".git" ]]; then
    echo -e "${CYAN}[*] Pulling latest changes from Git...${RESET}"
    git pull origin main
else
    echo -e "${YELLOW}[!] Not a git repository - skipping Git update${RESET}"
fi

# Update Python packages
if [[ -d "venv" ]]; then
    source venv/bin/activate
    
    echo -e "${CYAN}[*] Updating Python packages...${RESET}"
    
    # Check if Kali Linux
    if [[ -f /etc/os-release ]] && grep -q "Kali" /etc/os-release; then
        echo -e "${YELLOW}[!] Kali Linux detected - using special mode${RESET}"
        pip install --upgrade -r requirements.txt --break-system-packages
    else
        pip install --upgrade -r requirements.txt
    fi
    
    deactivate
    echo -e "${GREEN}[+] Update complete!${RESET}"
else
    echo -e "${RED}[✗] Virtual environment not found${RESET}"
    echo -e "${YELLOW}[!] Please run the installer again${RESET}"
fi
EOF
    chmod +x update.sh
}

# Update function
update_decoder() {
    echo -e "${CYAN}[*] Updating XPRO NEXUS Decoder...${RESET}"
    
    if [[ -d "venv" ]]; then
        source venv/bin/activate
        
        if [[ -f /etc/os-release ]] && grep -q "Kali" /etc/os-release; then
            echo -e "${YELLOW}[!] Kali Linux detected - using --break-system-packages${RESET}"
            pip install --upgrade -r requirements.txt --break-system-packages
        else
            pip install --upgrade -r requirements.txt
        fi
        
        deactivate
        echo -e "${GREEN}[+] Update complete${RESET}"
    else
        echo -e "${RED}[✗] Virtual environment not found${RESET}"
        echo -e "${YELLOW}[!] Please run the installer first${RESET}"
        exit 1
    fi
}

# Uninstall function
uninstall_decoder() {
    echo -e "${YELLOW}[!] This will remove XPRO NEXUS Decoder${RESET}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${WHITE}[*] Removing virtual environment...${RESET}"
        rm -rf venv
        
        echo -e "${WHITE}[*] Removing configuration files...${RESET}"
        rm -f requirements.txt config.json
        
        echo -e "${WHITE}[*] Removing scripts...${RESET}"
        rm -f run.sh update.sh
        
        echo -e "${WHITE}[*] Cleaning up...${RESET}"
        rm -rf __pycache__ *.pyc
        
        echo -e "${GREEN}[+] XPRO NEXUS Decoder has been uninstalled${RESET}"
    fi
}

# Help function
show_help() {
    echo -e "${CYAN}XPRO NEXUS DECODER - Installer Script${RESET}"
    echo ""
    echo "Usage: ./install.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  (no option)   Run full installation"
    echo "  update        Update installed packages"
    echo "  uninstall     Remove XPRO NEXUS Decoder"
    echo "  test          Test the installation"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./install.sh          # Full installation"
    echo "  ./install.sh update   # Update packages"
    echo "  ./install.sh test     # Test installation"
    echo ""
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
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        main_install
        ;;
esac

exit 0