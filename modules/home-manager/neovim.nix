{ config, lib, pkgs, flake, ... }:
{
  config = {
    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      /*
      extraPackages = [
        #rustChannel.rust
        #rustChannel.rust-src
        pkgs.rustPackages.rustc
        pkgs.rustPackages.cargo
        pkgs.rustPackages.rustfmt
        pkgs.rustPackages.rustPlatform.rustLibSrc
        ];
        */

        /*
      extraPython3Packages = ps: with ps; [
        #pyls-mypy
        #pyls-isort
        #pyls-black
        ];
        */

      extraConfig = ''
          filetype plugin on
          syntax enable
          set background=dark
          colorscheme default

          set laststatus=2
          set shortmess=aoOW

          set showcmd
          set undolevels=1000
          set undoreload=-1

          " Hybrid mode
          set number relativenumber

          " System clipboard
          set clipboard=unnamed

          " Set a column at the 80-character mark
          set colorcolumn=80
          hi ColorColumn ctermbg=black

          " Highlight the line the cursor is on
          set cursorline

          " Shows matching brackets (add < and > as matches)
          set showmatch
          set matchpairs+=<:>

          " Highlight matching patterns
          set hlsearch
          set incsearch

          " Keep at least 15 lines above and below cursor when scrolling
          set scrolloff=15

          set hidden
          set list
          set listchars=tab:::,trail:.,extends:#,nbsp:.

          set nowrap
          set smartindent
          set expandtab
          set tabstop=4
          set softtabstop=4
          set shiftwidth=4
          set pastetoggle=<F12>
          set foldmethod=syntax
          set mouse=v

          " let $LOG_LEVEL='TRACE'
          " let $RUST_LOG='rls=TRACE'
          " let $RUST_SRC_PATH='rustChannel.rust-src/lib/rustlib/src/rust/library'
          " let $RUST_SRC_PATH='${pkgs.rustPackages.rustPlatform.rustLibSrc}'
      '';

      plugins = with pkgs.vimPlugins; [
        # LSP configs
        {
          plugin = nvim-lspconfig;
          config = ''
            lua << EOF
              vim.cmd("nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>")
              vim.cmd("nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>")
              vim.cmd("nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>")
              vim.cmd("nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>")
              -- vim.cmd('nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>')
              vim.cmd('command! -nargs=0 LspVirtualTextToggle lua require("lsp/virtual_text").toggle()')

              -- symbols for autocomplete
              vim.lsp.protocol.CompletionItemKind = {
                "   (Text) ",
                "   (Method)",
                "   (Function)",
                "   (Constructor)",
                " ﴲ  (Field)",
                "[] (Variable)",
                "   (Class)",
                " ﰮ  (Interface)",
                "   (Module)",
                " 襁 (Property)",
                "   (Unit)",
                "   (Value)",
                " 練 (Enum)",
                "   (Keyword)",
                "   (Snippet)",
                "   (Color)",
                "   (File)",
                "   (Reference)",
                "   (Folder)",
                "   (EnumMember)",
                " ﲀ  (Constant)",
                " ﳤ  (Struct)",
                "   (Event)",
                "   (Operator)",
                "   (TypeParameter)"
              }
            EOF
          '';
        }
        {
          plugin = lazy-lsp-nvim;
          config = ''
            lua << EOF
              require('lazy-lsp').setup {
                excluded_servers = {
                  "sqls",
                },
                default_config = {
                  flags = {
                    debounce_text_changes = 150,
                    on_attach = on_attach,
                    capabilities = capabilities,
                  },
                },
              }
            EOF
          '';
        }
        {
          plugin = lspsaga-nvim;
          config = ''
            " show hover doc
            nnoremap <silent>K :Lspsaga hover_doc<CR>

            " lsp provider to find the cursor word definition and reference
            nnoremap <silent> gh :Lspsaga lsp_finder<CR>

            " show code actions from lsp
            nnoremap <silent> ca :Lspsaga code_action<CR>

            " Jump between diagnostics
            nnoremap <silent> <C-p> :Lspsaga diagnostic_jump_prev<CR>
            nnoremap <silent> <C-n> :Lspsaga diagnostic_jump_next<CR>

            " scroll down hover doc or scroll in definition preview
            nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
            " scroll up hover doc
            nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>
          '';
        }

        # Autocomplete
        {
          plugin = nvim-compe;
          config = ''
            lua << EOF
              vim.o.completeopt = "menuone,noselect"

              require'compe'.setup {
                enabled = true;
                autocomplete = true;
                debug = false;
                min_length = 1;
                preselect = 'enable';
                throttle_time = 80;
                source_timeout = 200;
                incomplete_delay = 400;
                max_abbr_width = 100;
                max_kind_width = 100;
                max_menu_width = 100;
                documentation = false;

                source = {
                  path = true;
                  buffer = true;
                  calc = true;
                  vsnip = true;
                  nvim_lsp = true;
                  nvim_lua = true;
                  spell = true;
                  tags = true;
                  snippets_nvim = true;
                  treesitter = true;
                };
              }
              local t = function(str)
                return vim.api.nvim_replace_termcodes(str, true, true, true)
              end

              local check_back_space = function()
                local col = vim.fn.col('.') - 1
                if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                  return true
                else
                  return false
                end
              end

              -- Use (s-)tab to:
              --- move to prev/next item in completion menuone
              --- jump to prev/next snippet's placeholder
              _G.tab_complete = function()
                if vim.fn.pumvisible() == 1 then
                  return t "<C-n>"
                elseif vim.fn.call("vsnip#available", {1}) == 1 then
                  return t "<Plug>(vsnip-expand-or-jump)"
                elseif check_back_space() then
                  return t "<Tab>"
                else
                  return vim.fn['compe#complete']()
                end
              end
              _G.s_tab_complete = function()
                if vim.fn.pumvisible() == 1 then
                  return t "<C-p>"
                elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
                  return t "<Plug>(vsnip-jump-prev)"
                else
                  -- If <S-Tab> is not working in your terminal, change it to <C-h>
                  return t "<S-Tab>"
                end
              end

              vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
              vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
              vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
              vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
            EOF
          '';
        }
        {
          plugin = vim-vsnip;
          config = ''
            " Expand
            imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
            smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

            " Expand or jump
            imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
            smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

            " Jump forward or backward
            imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
            smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
            imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
            smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

            " Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
            " See https://github.com/hrsh7th/vim-vsnip/pull/50
            nmap        s   <Plug>(vsnip-select-text)
            xmap        s   <Plug>(vsnip-select-text)
            nmap        S   <Plug>(vsnip-cut-text)
            xmap        S   <Plug>(vsnip-cut-text)

            " If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
            " let g:vsnip_filetypes = {}
            " let g:vsnip_filetypes.javascriptreact = ['javascript']
            " let g:vsnip_filetypes.typescriptreact = ['typescript']
          '';
        }

        # Changes behavior to use the special airline-style fonts
        {
          plugin = vim-airline;
          config = "let g:airline_powerline_fonts = 1";
        }
        vim-airline-themes

        nvim-treesitter

        #The_NERD_Commenter
        #The_NERD_tree

        # Git support
        fugitive

        # Language support
        csv
        rust-vim
        vim-nix
        vim-go
        vim-glsl
        vim-javascript
        vim-json
        vim-orgmode
        vim-ruby
        vim-scala
        vim-toml
        elm-vim
      ];
    };

    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
