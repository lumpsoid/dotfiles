export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# for zsh to respect xdg env
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export PATH="$HOME/.local/bin:$PATH"

# Rust XDG setup
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"

# Add Cargo bin directory to PATH
export PATH="${CARGO_HOME}/bin:$PATH"

# Additional Rust environment variables (optional)
export CARGO_CACHE_DIR="${XDG_CACHE_HOME}/cargo"
export RUSTUP_TMPDIR="${XDG_CACHE_HOME}/rustup/tmp"

# Go XDG setup
export GOPATH="${XDG_DATA_HOME}/go"
export GOMODCACHE="${XDG_CACHE_HOME}/go/mod"
export GOCACHE="${XDG_CACHE_HOME}/go/build"
export GOENV="${XDG_CONFIG_HOME}/go/env"

# Add Go bin directories to PATH
export PATH="${GOPATH}/bin:$PATH"

# Ruby XDG setup
export GEM_HOME="${XDG_DATA_HOME}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem"
export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME}/bundle"
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle"
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle"
export IRBRC="${XDG_CONFIG_HOME}/irb/irbrc"
export PRYRC="${XDG_CONFIG_HOME}/pry/pryrc"
export SOLARGRAPH_CACHE="${XDG_CACHE_HOME}/solargraph"

# Add local gem binaries to PATH
export PATH="${GEM_HOME}/bin:$PATH"

# Flutter/Dart XDG setup
export FLUTTER_ROOT="${XDG_DATA_HOME}/flutter"
export PUB_CACHE="${XDG_CACHE_HOME}/pub"
export DART_USER_HOME="${XDG_DATA_HOME}/dart"

# Flutter tool analytics/settings
export FLUTTER_CONFIG="${XDG_CONFIG_HOME}/flutter"

# Alternative to storing analyzer cache in ~/.dartServer
export ANALYZER_DIAGNOSTIC_SERVER_CACHE="${XDG_CACHE_HOME}/dart/analyzer_server"

# Add Flutter and Dart binaries to PATH
export PATH="${FLUTTER_ROOT}/bin:${PUB_CACHE}/bin:$PATH"
# Flutter path to the chromium executable
export CHROME_EXECUTABLE=/usr/bin/brave

# Android development XDG setup
export ANDROID_HOME="${XDG_DATA_HOME}/android/sdk"
export ANDROID_SDK_ROOT="${XDG_DATA_HOME}/android/sdk"
export ANDROID_AVD_HOME="${XDG_DATA_HOME}/android/avd"
export ANDROID_USER_HOME="${XDG_CONFIG_HOME}/android"
export ANDROID_EMULATOR_HOME="${XDG_DATA_HOME}/android/emulator"
export ADB_VENDOR_KEYS="${XDG_CONFIG_HOME}/android/adb_keys"

# Gradle XDG setup (used by Android build tools)
export GRADLE_USER_HOME="${XDG_DATA_HOME}/gradle"

# Android tools paths
export PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin:$PATH"

# Python XDG setup
export PYTHONUSERBASE="${XDG_DATA_HOME}/python"
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export IPYTHONDIR="${XDG_CONFIG_HOME}/ipython"
export JUPYTER_CONFIG_DIR="${XDG_CONFIG_HOME}/jupyter"
export PYLINTHOME="${XDG_CACHE_HOME}/pylint"
export PYTHON_EGG_CACHE="${XDG_CACHE_HOME}/python-eggs"
export PIP_CONFIG_FILE="${XDG_CONFIG_HOME}/pip/pip.conf"
export PIP_CACHE_DIR="${XDG_CACHE_HOME}/pip"
export POETRY_HOME="${XDG_DATA_HOME}/poetry"
export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export MYPY_CACHE_DIR="${XDG_CACHE_HOME}/mypy"
export PYTEST_CACHE_DIR="${XDG_CACHE_HOME}/pytest"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Add Python user bin directory to PATH
export PATH="${PYTHONUSERBASE}/bin:${POETRY_HOME}/bin:${PYENV_ROOT}/bin:$PATH"
