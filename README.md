# nvim-bbstatus

🧠 A lightweight Neovim plugin that shows **estimated RAM usage** of your [Bitburner](https://danielyxie.github.io/bitburner/) TypeScript scripts directly in the status bar using [vim-airline](https://github.com/vim-airline/vim-airline).

> ⚠️ This only provides an **approximate RAM estimate** based on static analysis and `bitburner-ram.json`. It does not account for dynamic imports, API overrides, or in-game execution quirks.

---

## ✨ Features

- Automatically shows estimated RAM usage when working on Bitburner `.ts` scripts
- Integrates with `vim-airline`
- Supports on-save updates and file switching
- Customizable status label (with optional powerline glyphs)

---

## 🔧 Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'vim-airline/vim-airline'
Plug 'skyroor/nvim-bbstatus'
```

Then reload Neovim and run:

```vim
:PlugInstall
```

---

## 🛠 Setup

Place this in your `init.vim` **after** setting up Airline:

```vim
" Show Bitburner RAM estimate in the status bar (right section)
let g:airline_section_x = '%{get(g:, "bitburner_ram", "")}'
```

The plugin will automatically:

- Load when opening `.ts` files
- Check for `import { NS } from '@ns'` to detect Bitburner scripts
- Update the RAM estimate:
  - On buffer read
  - On file save
  - On buffer switch

No further configuration is needed for basic use.

---

## ⚙️ Options

You can customize the **RAM label prefix** via a Vim global:

```vim
let g:bbstatus_label_prefix = "🧠 BB RAM"
```

Or call this command at any time:

```vim
:BBStatus RAM Usage
```

You can use [Powerline glyphs](https://github.com/powerline/powerline/wiki/Symbols) or Nerd Font icons as part of the label:

```vim
:BBStatus  RAM
```

> You must be using a Nerd Font or Powerline-patched font for the symbols to appear correctly.

---

## 🧪 Known Limitations

- This is an **estimate** based on static string matches (`ns.<method>`)
- Does not support advanced TypeScript transformations or inline APIs
- RAM cost may differ from the in-game `mem()` command in edge cases

---

## 💡 Credits

- [Bitburner](https://github.com/danielyxie/bitburner)
- [vim-airline](https://github.com/vim-airline/vim-airline)
- [Nerd Fonts](https://www.nerdfonts.com/)
