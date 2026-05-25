# 🔧 Dotfiles

My personal dotfiles configuration for zsh, oh-my-posh, zed, and other tools.

## 📁 Structure

```
dotfiles/
├── config/              # XDG config directory
│   ├── zsh/            # Zsh shell configuration
│   ├── oh-my-posh/     # Oh-my-posh prompt themes
│   └── zed/            # Zed editor settings
├── home/               # Files for home directory
│   └── .zshenv         # Zsh environment variables
├── local/bin/          # Custom scripts and executables
├── install.sh          # Installation script
└── README.md           # This file
```

## ⚡ Quick Start

### Clone the repo
```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Run the installer
```bash
chmod +x install.sh
./install.sh
```

### Restart your shell
```bash
exec zsh
```

## 🔄 What Gets Installed

The `install.sh` script creates symlinks for:

- **zsh config** → `~/.config/zsh`
- **oh-my-posh config** → `~/.config/oh-my-posh`
- **zed config** → `~/.config/zed`
- **zsh environment** → `~/.zshenv`
- **bin scripts** → `~/.local/bin/`

## 📝 Customizing

### Add new configurations

1. Create the config directory in the repo:
   ```bash
   mkdir -p config/myapp
   ```

2. Add your config file

3. Update `install.sh` to symlink it:
   ```bash
   ln -sfv "$DOTFILES_DIR/config/myapp" ~/.config/myapp
   ```

### Update existing configs

Just edit files in the repo and run `install.sh` again (safe to re-run).

## 🚫 Excluded Files

These files are NOT stored (and should be in `.gitignore`):

- `~/.cache/` - Runtime cache files
- `~/.local/share/` - Auto-generated data
- `.omp.cache` files - Oh-my-posh cache
- `.DS_Store` - macOS files
- Zed extensions and logs

## 🛠 Requirements

- zsh shell
- oh-my-posh (optional)
- zed editor (optional)

## 📖 XDG Base Directory

This repo follows the [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) standard:

- `$XDG_CONFIG_HOME` → `~/.config`
- `$XDG_DATA_HOME` → `~/.local/share`
- `$XDG_CACHE_HOME` → `~/.cache`

## 🔗 Useful Links

- [Oh-my-posh Docs](https://ohmyposh.dev)
- [Zed Editor](https://zed.dev)
- [XDG Base Directory Spec](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

## 📄 License

Feel free to use and modify as needed!
