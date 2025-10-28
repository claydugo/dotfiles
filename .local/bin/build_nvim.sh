#!/usr/bin/env bash
set -e
set -u

NEOVIM_DIR="$HOME/git/upstream/neovim"
NEOVIM_REPO="https://github.com/neovim/neovim.git"
FORCE_REBUILD=false
CLEAN_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_REBUILD=true
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -f, --force   Force rebuild even if already up to date"
            echo "  -c, --clean   Run 'make distclean' before building"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ ! -d "$NEOVIM_DIR" ]; then
    echo "Neovim directory not found. Cloning repository..."
    mkdir -p "$(dirname "$NEOVIM_DIR")"
    git clone "$NEOVIM_REPO" "$NEOVIM_DIR"
fi

cd "$NEOVIM_DIR" || exit 1

echo "Fetching latest changes..."
git fetch origin

# Check if we're already up to date
CURRENT_COMMIT=$(git rev-parse HEAD)
UPSTREAM_COMMIT=$(git rev-parse origin/master)

if [ "$CURRENT_COMMIT" = "$UPSTREAM_COMMIT" ] && [ "$FORCE_REBUILD" = false ]; then
    echo "Already up to date ($(git rev-parse --short HEAD)). Use -f to force rebuild."
    exit 0
fi

if [ "$CURRENT_COMMIT" != "$UPSTREAM_COMMIT" ]; then
    echo "Pulling changes..."
    git pull
fi

# Clean build artifacts if they exist and have permission issues
if [ -d ".deps" ] || [ -d "build" ]; then
    if ! [ -w ".deps" ] 2>/dev/null || ! [ -w "build" ] 2>/dev/null; then
        echo "Cleaning up build directories (requires sudo due to previous builds)..."
        sudo rm -rf .deps build
    fi
fi

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo "Running clean build..."
    pixi run with-compilers "cd '$NEOVIM_DIR' && make distclean"
fi

# Show version info
if command -v nvim &> /dev/null; then
    CURRENT_VERSION=$(nvim --version | head -n1)
    echo "Currently installed: $CURRENT_VERSION"
fi
NEW_VERSION=$(git describe --tags --always)
echo "Building version: $NEW_VERSION"

# Build without sudo (parallel using all CPU cores)
echo "Building Neovim..."
pixi run with-compilers "cd '$NEOVIM_DIR' && make CMAKE_BUILD_TYPE=RelWithDebInfo -j\$(nproc)"

# Only use sudo for installation
echo "Installing Neovim (requires sudo)..."
if ! sudo -v; then
    echo "This script requires sudo privileges for installation."
    exit 1
fi

sudo rm -rf /usr/local/share/nvim
sudo make install

echo "Neovim has been successfully updated and installed ($(git rev-parse --short HEAD))."
