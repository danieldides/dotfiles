# Dotfiles
All my various configurations and customizatoins, accumulated in one place.

## NeoVim
(Requires >= 0.5)

Install language servers:

```bash
npm install -g pyright typescript typescript-language-server prettier
luarocks install --server=https://luarocks.org/dev luaformatter
```

## Awesome
Largely based off of: https://github.com/WillPower3309/awesome-dotfiles.

Components:
* Titlebars:    https://raw.githubusercontent.com/1jss/awesome-lighter/main/awesome/components/titlebar.lua

## Fish Shell

### Installation

1. Link the fish configuration:
   ```bash
   ln -s $HOME/dotfiles/fish $HOME/.config/fish
   ```

2. Create system-specific configuration from the template:
   ```bash
   cp $HOME/.config/fish/secret.example.fish $HOME/.config/fish/secret.fish
   ```

3. Edit `secret.fish` to add your system-specific settings:
   - Kubernetes configuration paths
   - AWS profile
   - System-specific paths
   - API keys and tokens (NEVER commit these)
   - PYENV_ROOT if different from default

4. Install Fisher (package manager):
   ```bash
   fish
   curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
   fisher install jorgebucaran/fisher
   ```

5. Install plugins from `fish/fish_plugins`:
   ```bash
   fisher install
   ```

### Plugin Management

Plugins are managed via Fisher using `fish/fish_plugins` as the source of truth.

To add a new plugin, add it to `fish/fish_plugins` and run:
```bash
fisher install
```

To remove a plugin, remove it from `fish/fish_plugins` and run:
```bash
fisher install
```

To get a list of currently installed plugins:
```bash
fisher list > fish/fish_plugins
```

**Important**: Do not commit plugin files (`fish/functions/*`, `fish/conf.d/*`) as they are generated from `fish/fish_plugins`.

### Important Notes

- `fish/secret.fish` is gitignored and should contain system-specific or sensitive configuration
- `fish/fish_variables` is gitignored as it contains system-specific universal variables
- Use `secret.example.fish` as a template for new systems
- `fish/conf.d/fish_frozen_*.fish` are migration files from fish 4.3 upgrade; these are system-specific and can be safely deleted if they cause issues
- **Committed custom functions**: `fish/functions/aidev.fish`, `fish/functions/helm-readme.fish`, `fish/functions/whoseport.fish`
- **Ignored plugin functions**: All Fisher plugin files (`fisher.fish`, `__z*.fish`, `_nvm*.fish`, `nvm.fish`, `z.fish`, `nvm.fish` in conf.d/) are generated from `fish/fish_plugins` and should not be committed
- Color themes and key bindings are system-specific; customize them using `fish_config` or by editing `~/.config/fish/conf.d/` files
