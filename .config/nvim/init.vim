"行番号を表示
set number
"タブ文字の代わりにスペースを使う
set expandtab
"プログラミング言語に合わせて適切にインデントを自動挿入
set smartindent
"各コマンドやsmartindentで挿入する空白の量
set shiftwidth=4
"Tabキーで挿入するスペースの数
set softtabstop=4
"カレントディレクトリを自動で移動
set autochdir
"バッファ内で扱う文字コード
set encoding=utf-8
"書き込む文字コード : この場合encodingと同じなので省略可
set fileencoding=utf-8
"読み込む文字コード : この場合UTF-8を試し、だめならShift_JIS
set fileencodings=utf-8,cp932
"Vimの無名レジスタとシステムのクリップボードを連携 : ダメならxclipをインストールで使えるかも
set clipboard+=unnamed,unnamedplus
"eコマンド等でTabキーを押すとパスを保管する : この場合まず最長一致文字列まで補完し、2回目以降は一つづつ試す
set wildmode=longest,full
"zsh
set shell=zsh

"LeaderキーをSpaceに設定(これだけでは意味をなさない)
let mapleader = "\<Space>"

"C++,Java等のインラインブロックを中括弧付きのブロックに展開
nnoremap <C-j> ^/(<CR>%a{<CR><Esc>o}<Esc>
"カーソル上の単語を置換
nnoremap <expr> S* ':%s/\<' . expand('<cword>') . '\>/'

"挿入モード終了時にIMEをオフ
inoremap <silent> <Esc> <Esc>:call system('fcitx-remote -c')<CR>

"下部分にターミナルウィンドウを作る
function! Myterm()
    split
    wincmd j
    resize 10
    terminal
    wincmd k
endfunction
command! Myterm call Myterm()

"起動時にターミナルウィンドウを設置
if has('vim_starting')
    Myterm
endif

"上のエディタウィンドウと下のターミナルウィンドウ(ターミナル挿入モード)を行き来
tnoremap <C-t> <C-\><C-n><C-w>k
nnoremap <C-t> <C-w>ji
"ターミナル挿入モードからターミナルモードへ以降
tnoremap <Esc> <C-\><C-n>

"ファイルタイプごとにコンパイル/実行コマンドを定義
function! Setup()
    "フルパスから拡張子を除いたもの
    let l:no_ext_path = printf("%s/%s", expand("%:h"), expand("%:r"))
    "各言語の実行コマンド
    let g:compile_command_dict = {
                \'c': printf('gcc -std=gnu11 -O2 -lm -o %s.out %s && %s/%s.out', expand("%:r"), expand("%:p"), expand("%:h"), expand("%:r")),
                \'cpp': printf('g++ -std=gnu++17 -O2 -o %s.out %s && %s/%s.out', expand("%:r"), expand("%:p"), expand("%:h"), expand("%:r")),
                \'java': printf('javac %s && java %s', expand("%:p"), expand("%:r")),
                \'cs': printf('mcs -r:System.Numerics -langversion:latest %s && mono %s/%s.exe', expand("%:p"), expand("%:h"), expand("%:r")),
                \'python': printf('python3 %s', expand("%:p")),
                \'ruby': printf('ruby %s', expand("%:p")),
                \'javascript': printf('node %s', expand("%:p")),
                \'sh': printf('chmod u+x %s && %s', expand("%:p"), expand("%:p"))
                \}
    "実行コマンド辞書に入ってたら実行キーバインドを設定
    if match(keys(g:compile_command_dict), &filetype) >= 0
        "下ウィンドウがターミナルであることを前提としている
        nnoremap <expr> <F5> '<C-w>ji<C-u>' . g:compile_command_dict[&filetype] . '<CR>'
    endif
endfunction
command! Setup call Setup()

"ファイルを開き直したときに実行コマンドを再設定
autocmd BufNewFile,BufRead * Setup
"RubyとJSではインデントを2マスにする
autocmd FileType ruby,javascript set shiftwidth=2 softtabstop=2

" deinの設定
" dein.vim settings {{{
" install dir {{{
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" }}}

" dein installation check {{{
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif
" }}}

" begin settings {{{
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  let s:rc_dir = expand('~/.vim')
  if !isdirectory(s:rc_dir)
    call mkdir(s:rc_dir, 'p')
  endif
  let s:toml = s:rc_dir . '/dein.toml'

  " read toml and cache
  call dein#load_toml(s:toml, {'lazy': 0})

  " end settings
  call dein#end()
  call dein#save_state()
endif
" }}}

" plugin installation check {{{
if dein#check_install()
  call dein#install()
endif
" }}}

" plugin remove check {{{
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif
" }}}


" lspの設定
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <C-]> <plug>(lsp-definition)
  nmap <buffer> <f2> <plug>(lsp-rename)
  nmap <buffer> <Leader>d <plug>(lsp-type-definition)
  nmap <buffer> <Leader>r <plug>(lsp-references)
  nmap <buffer> <Leader>i <plug>(lsp-implementation)
  inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
command! LspDebug let lsp_log_verbose=1 | let lsp_log_file = expand('~/lsp.log')

let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
" let g:asyncomplete_auto_popup = 1
" let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 200
let g:lsp_text_edit_enabled = 1
let g:lsp_preview_float = 1
let g:lsp_diagnostics_float_cursor = 1
let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']

let g:lsp_settings = {}
let g:lsp_settings['gopls'] = {
  \  'workspace_config': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \  'initialization_options': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \}

" For snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

set completeopt+=menuone


" tab completion
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" force refresh
imap <c-space> <Plug>(asyncomplete_force_refresh)

" allow modifying the completeopt variable, or it will
" be overridden all the time
let g:asyncomplete_auto_completeopt = 0

set completeopt=menuone,noinsert,noselect,preview
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
