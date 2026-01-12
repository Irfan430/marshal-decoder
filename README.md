# XPRO NEXUS DECODER

<div align="center">
  
![Version](https://img.shields.io/badge/version-10.0-blue)
![Python](https://img.shields.io/badge/python-3.7%2B-green)
![Platform](https://img.shields.io/badge/platform-Linux%20|%20Kali%20|%20Termux-brightgreen)
![License](https://img.shields.io/badge/license-MIT-orange)

**Ultimate Marshal File Recovery Tool**  
*Recover encrypted Python files with AI-powered parallel decoding*

</div>

## 📦 Installation

```bash
# Clone repository
git clone https://github.com/xpro-nexus/marshal-decoder.git
cd marshal-decoder

# Run installer
chmod +x install.sh
./install.sh
```

🚀 Quick Start

```bash
# Run decoder (interactive mode)
python3 xpro_decoder.py

# Or specify file directly
python3 xpro_decoder.py encrypted_file.py

# Use AI-powered decoding
python3 xpro_decoder.py --ai --threads 8 encrypted.py
```

✨ Features

🔧 Multiple Decoding Methods

· UNCOMPYLE6 - Industry standard decompiler
· DECOMPYLE3 - Modern decompilation engine
· BYTECODE_AI - AI-powered bytecode analysis
· EXECUTION_TRACE - Runtime environment capture
· PATTERN_MATCH - Advanced pattern matching
· HYBRID_FUSION - Combined best results
· DEEP_DECODE - Comprehensive analysis

⚡ Performance

· Parallel processing using all CPU cores
· Memory efficient (handles large files)
· Real-time progress tracking
· Automatic fallback on failures

📊 Output Structure

```
XPRO_OUTPUT_TIMESTAMP/
├── decoded/              # All decoded versions
├── analysis/             # Analysis data
├── reports/              # Comprehensive reports
├── logs/                 # Session logs
├── backup/               # Original data backup
└── bytecode/             # Bytecode analysis
```

📖 Usage Examples

Example 1: Basic Decoding

```bash
python3 xpro_decoder.py my_encrypted_script.py
```

Example 2: Batch Processing

```bash
python3 xpro_decoder.py --batch ./encrypted_files/
```

Example 3: Advanced Options

```bash
python3 xpro_decoder.py encrypted.py \
  --threads 16 \
  --processes 8 \
  --ai \
  --output ./results/
```

🛠️ Command Line Options

```bash
python3 xpro_decoder.py --help

Options:
  --batch, -b       Batch decode multiple files
  --threads, -t     Set number of threads (default: auto)
  --processes, -p   Set number of processes (default: auto)
  --output, -o      Custom output directory
  --ai, -a          Enable AI-powered decoding
  --no-ai           Disable AI modules
  --verbose, -v     Show detailed output
  --quiet, -q       Minimal output
  --version         Show version information
```

📝 Decoding Process

1. Extract marshal data from encrypted file
2. Analyze bytecode and patterns
3. Decode using 8 different methods in parallel
4. Combine best results into final output
5. Generate comprehensive report

🔒 Supported Files

· Python files encrypted with marshal.loads()
· Files containing exec(marshal.loads(b'...'))
· Both single files and batch processing
· Compatible with Python 3.7+

🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

📄 License

MIT License - see LICENSE file for details.

📞 Support

· GitHub Issues: Report bugs/request features
· Email: support@xpro-nexus.dev

---

<div align="center">⭐ If this project helped you, please give it a star! ⭐

</div>
```


## Usage (Updated)

Run the decoder and provide the encrypted marshal file path when prompted.
Example:

python3 xpro_decoder.py

Drag & drop also supported.