#!/bin/bash
# XPRO NEXUS DECODER - COMPLETE INSTALLER
# For Kali Linux, Ubuntu, Debian, macOS, and other systems

set -e

# Colors
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
echo "║                 XPRO NEXUS DECODER INSTALLER                 ║"
echo "║                   Complete Edition v10.1                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Detect OS and Python
detect_system() {
    echo -e "${BLUE}[*] Detecting system...${RESET}"
    
    # OS Detection
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        VER=$(sw_vers -productVersion)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    # Python Detection
    if command -v python3.10 &> /dev/null; then
        PYTHON_CMD="python3.10"
        echo -e "${GREEN}[+] Python 3.10 found${RESET}"
    elif command -v python3.9 &> /dev/null; then
        PYTHON_CMD="python3.9"
        echo -e "${GREEN}[+] Python 3.9 found${RESET}"
    elif command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
        echo -e "${GREEN}[+] Python $PYTHON_VERSION found${RESET}"
    else
        echo -e "${RED}[✗] Python 3 not found${RESET}"
        exit 1
    fi
    
    echo -e "${WHITE}• OS: $OS $VER${RESET}"
    echo -e "${WHITE}• Python: $($PYTHON_CMD --version)${RESET}"
}

# Install system dependencies
install_system_deps() {
    echo -e "\n${CYAN}[*] Installing system dependencies...${RESET}"
    
    if [[ "$OS" == *"Kali"* || "$OS" == *"Debian"* || "$OS" == *"Ubuntu"* ]]; then
        echo -e "${WHITE}[*] Using apt package manager${RESET}"
        sudo apt update
        sudo apt install -y \
            $PYTHON_CMD \
            $PYTHON_CMD-venv \
            $PYTHON_CMD-dev \
            $PYTHON_CMD-pip \
            build-essential \
            git \
            wget \
            curl \
            libssl-dev \
            libffi-dev
        
    elif [[ "$OS" == "macOS" ]]; then
        echo -e "${WHITE}[*] Using Homebrew (macOS)${RESET}"
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}[!] Installing Homebrew...${RESET}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install python3 git wget curl openssl
        
    elif [[ "$OS" == *"Fedora"* || "$OS" == *"Red Hat"* || "$OS" == *"CentOS"* ]]; then
        echo -e "${WHITE}[*] Using dnf package manager${RESET}"
        sudo dnf install -y \
            python3 \
            python3-devel \
            python3-pip \
            gcc \
            g++ \
            make \
            git \
            wget \
            curl \
            openssl-devel
            
    elif [[ "$OS" == *"Arch"* || "$OS" == *"Manjaro"* ]]; then
        echo -e "${WHITE}[*] Using pacman package manager${RESET}"
        sudo pacman -Syu --noconfirm \
            python \
            python-pip \
            base-devel \
            git \
            wget \
            curl \
            openssl
            
    else
        echo -e "${YELLOW}[!] Unknown OS - skipping system dependencies${RESET}"
    fi
}

# Create optimized requirements file
create_requirements() {
    echo -e "\n${CYAN}[*] Creating optimized requirements...${RESET}"
    
    cat > requirements.txt << 'EOF'
# XPRO NEXUS DECODER - Optimized Requirements
# Python 3.7-3.13 compatible

# === CORE DECOMPILERS ===
# Primary decompilers (may have issues with Python 3.13)
uncompyle6>=3.9.0,<4.0.0
decompyle3>=3.9.0,<4.0.0
xdis>=6.0.0,<7.0.0

# Alternative decompilers (Python 3.13 compatible)
pycdas==1.16.0
bytecode==0.13.0

# === ESSENTIAL UTILITIES ===
colorama>=0.4.0  # Cross-platform colored terminal
tqdm>=4.65.0     # Progress bars
rich>=13.0.0     # Rich terminal formatting
psutil>=5.9.0    # System monitoring
click>=8.1.0     # Command line interface

# === DATA PROCESSING ===
numpy>=1.24.0    # Numerical operations (for AI features)
pandas>=2.0.0    # Data analysis

# === SECURITY & ANALYSIS ===
bandit>=1.7.0    # Security analysis
safety>=2.0.0    # Dependency vulnerability scanning

# === DEVELOPMENT TOOLS ===
black>=23.0.0    # Code formatting
flake8>=6.0.0    # Code linting
pytest>=7.0.0    # Testing

# === OPTIONAL AI/ML ===
# Uncomment if you need AI features
# scipy>=1.10.0
# scikit-learn>=1.2.0
# torch>=2.0.0
# tensorflow>=2.12.0
EOF
    
    echo -e "${GREEN}[+] Created requirements.txt${RESET}"
}

# Setup virtual environment
setup_venv() {
    echo -e "\n${CYAN}[*] Setting up virtual environment...${RESET}"
    
    # Remove old venv if exists
    if [[ -d "venv" ]]; then
        echo -e "${YELLOW}[!] Removing old virtual environment...${RESET}"
        rm -rf venv
    fi
    
    # Create venv with selected python
    echo -e "${WHITE}[*] Creating virtual environment with $PYTHON_CMD...${RESET}"
    $PYTHON_CMD -m venv venv
    
    # Activate
    source venv/bin/activate
    
    # Upgrade pip
    echo -e "${WHITE}[*] Upgrading pip...${RESET}"
    pip install --upgrade pip setuptools wheel
    
    # Check pip version
    PIP_VERSION=$(pip --version | awk '{print $2}')
    echo -e "${GREEN}[+] Using pip $PIP_VERSION${RESET}"
}

# Install Python packages with smart strategy
install_python_packages() {
    echo -e "\n${CYAN}[*] Installing Python packages...${RESET}"
    
    # Get Python version
    PY_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
    PY_MAJOR=$(echo $PY_VERSION | cut -d'.' -f1)
    PY_MINOR=$(echo $PY_VERSION | cut -d'.' -f2)
    
    echo -e "${WHITE}[*] Python $PY_VERSION detected${RESET}"
    
    # Different strategies for different Python versions
    if [[ $PY_MAJOR -eq 3 ]] && [[ $PY_MINOR -ge 13 ]]; then
        echo -e "${YELLOW}[!] Python 3.13+ detected - using compatibility mode${RESET}"
        echo -e "${WHITE}[*] Installing core packages only...${RESET}"
        
        # Core packages that work with Python 3.13
        pip install numpy colorama tqdm rich psutil click pandas
        
        # Try to install decompilers with compatibility
        pip install uncompyle6 decompyle3 --no-deps || true
        echo -e "${YELLOW}[!] Some decompilers may not work perfectly with Python 3.13${RESET}"
        
    else
        echo -e "${GREEN}[+] Installing all packages...${RESET}"
        
        # Determine installation method based on OS
        if [[ "$OS" == *"Kali"* ]]; then
            echo -e "${YELLOW}[!] Kali Linux detected - using --break-system-packages${RESET}"
            pip install -r requirements.txt --break-system-packages
        else
            pip install -r requirements.txt
        fi
    fi
    
    # Verify installations
    echo -e "\n${WHITE}[*] Verifying installations...${RESET}"
    
    REQUIRED=("colorama" "tqdm" "numpy")
    OPTIONAL=("uncompyle6" "decompyle3" "rich")
    
    echo -e "${WHITE}Required packages:${RESET}"
    for pkg in "${REQUIRED[@]}"; do
        if python -c "import $pkg" &>/dev/null; then
            echo -e "  ${GREEN}✓ $pkg${RESET}"
        else
            echo -e "  ${RED}✗ $pkg${RESET}"
        fi
    done
    
    echo -e "\n${WHITE}Optional packages:${RESET}"
    for pkg in "${OPTIONAL[@]}"; do
        if python -c "import $pkg" &>/dev/null; then
            echo -e "  ${GREEN}✓ $pkg${RESET}"
        else
            echo -e "  ${YELLOW}⚠ $pkg (not critical)${RESET}"
        fi
    done
}

# Configure the decoder
configure_decoder() {
    echo -e "\n${CYAN}[*] Configuring XPRO Decoder...${RESET}"
    
    # Make main script executable
    chmod +x xpro_decoder.py
    
    # Create config file
    cat > config.json << EOF
{
    "version": "10.1",
    "author": "XPRO-NEXUS",
    "codename": "DEEPSEEK-PRO",
    "python_version": "$($PYTHON_CMD --version | cut -d' ' -f2)",
    "os": "$OS $VER",
    "install_date": "$(date -Iseconds)",
    "settings": {
        "max_threads": 16,
        "max_processes": 8,
        "timeout": 60,
        "enable_ai": true,
        "compatibility_mode": true,
        "auto_update": true
    }
}
EOF
    
    # Create run scripts
    cat > run.sh << 'EOF'
#!/bin/bash
# XPRO NEXUS DECODER - Run Script

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "🚀 Starting XPRO NEXUS DECODER v10.1"
echo "========================================"

# Check for virtual environment
if [[ -d "venv" ]]; then
    echo "[*] Activating virtual environment..."
    source venv/bin/activate
    IN_VENV=true
else
    echo "[!] Virtual environment not found"
    echo "[*] Using system Python..."
fi

# Check Python version
PY_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
echo "[*] Python $PY_VERSION detected"

# Run the decoder
python3 xpro_decoder.py

# Deactivate venv if activated
if [[ "$IN_VENV" = true ]]; then
    deactivate 2>/dev/null
fi

echo "========================================"
echo "✅ XPRO NEXUS DECODER finished"
EOF
    
    chmod +x run.sh
    
    # Create quick test script
    cat > test_decoder.sh << 'EOF'
#!/bin/bash
# Test script for XPRO Decoder

echo "🧪 Testing XPRO NEXUS DECODER..."
echo "========================================"

# Test 1: Check Python
if python3 --version &>/dev/null; then
    echo "✓ Python is working"
else
    echo "✗ Python not found"
    exit 1
fi

# Test 2: Check main script
if [[ -f "xpro_decoder.py" ]]; then
    echo "✓ Main script found"
else
    echo "✗ Main script not found"
    exit 1
fi

# Test 3: Check imports
echo "Testing imports..."
IMPORTS=("marshal" "dis" "ast" "re")
for imp in "${IMPORTS[@]}"; do
    if python3 -c "import $imp" &>/dev/null; then
        echo "  ✓ $imp"
    else
        echo "  ✗ $imp"
    fi
done

# Test 4: Create test file
cat > test_marshal.py << 'TEST'
import marshal
code = compile('print("Hello from XPRO!")', '<string>', 'exec')
data = marshal.dumps(code)
print(f"Created test marshal data: {len(data)} bytes")
with open('test.marshal', 'wb') as f:
    f.write(data)
print("Test file saved: test.marshal")
TEST

python3 test_marshal.py
rm -f test_marshal.py

echo "========================================"
echo "✅ All tests passed!"
echo "Run './run.sh' to start the decoder"
EOF
    
    chmod +x test_decoder.sh
    
    # Create examples
    mkdir -p examples
    cat > examples/README.md << 'EOF'
# XPRO NEXUS DECODER - Examples

## Example Files

### 1. Basic Marshal File
```python
# basic_encrypted.py
import marshal
code = compile('print("Hello World")', '<string>', 'exec')
exec(marshal.loads(marshal.dumps(code)))