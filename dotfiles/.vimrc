" Source Meta's master vimrc on DevVMs only
if filereadable(expand("$LOCAL_ADMIN_SCRIPTS/master.vimrc"))
    source $LOCAL_ADMIN_SCRIPTS/master.vimrc
endif

" Basic fallback settings
set nocompatible
set number
set relativenumber
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set hlsearch
set incsearch
syntax on
