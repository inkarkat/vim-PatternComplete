" PatternComplete.vim: Insert mode completion for matches of queried / last search pattern.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - PatternComplete.vim autoload script
"   - PatternComplete/AsBrace.vim autoload script
"   - PatternComplete/NextSearchMatch.vim autoload script
"
" Copyright: (C) 2011-2022 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_PatternComplete') || (v:version < 700)
    finish
endif
let g:loaded_PatternComplete = 1

"- configuration ---------------------------------------------------------------

if ! exists('g:PatternComplete_DelimitersPattern')
    let g:PatternComplete_DelimitersPattern = '[/?#@]'
endif
if ! exists('g:PatternComplete_EnableBraceMappings')
    let g:PatternComplete_EnableBraceMappings = 1
endif
if ! exists('g:PatternComplete_AsBraceOptions')
    let g:PatternComplete_AsBraceOptions = {'short': 1}
endif



"- mappings --------------------------------------------------------------------

inoremap <script> <expr> <Plug>(PatternCompleteInput)     PatternComplete#InputExpr(0)
inoremap <script> <expr> <Plug>(PatternCompleteWordInput) PatternComplete#InputExpr(1)
inoremap <script> <expr> <Plug>(PatternCompleteSearch)    PatternComplete#SearchExpr()
inoremap <script> <expr> <Plug>(PatternCompleteLast)      PatternComplete#LastExpr()
if ! hasmapto('<Plug>(PatternCompleteInput)', 'i')
    imap <C-x>/ <Plug>(PatternCompleteInput)
endif
if ! hasmapto('<Plug>(PatternCompleteWordInput)', 'i')
    imap <C-x>* <Plug>(PatternCompleteWordInput)
endif
if ! hasmapto('<Plug>(PatternCompleteSearch)', 'i')
    imap <C-x>& <Plug>(PatternCompleteSearch)
endif
if ! hasmapto('<Plug>(PatternCompleteLast)', 'i')
    imap <C-x>? <Plug>(PatternCompleteLast)
endif


nnoremap <script> <expr> <SID>(PatternCompleteInput)     PatternComplete#Selected(0)
nnoremap <script> <expr> <SID>(PatternCompleteWordInput) PatternComplete#Selected(1)
" Note: Must leave selection first; cannot do that inside the expression mapping
" because the visual selection marks haven't been set there yet.
vnoremap <silent> <script> <Plug>(PatternCompleteInput) <C-\><C-n><SID>(PatternCompleteInput)
vnoremap <silent> <script> <Plug>(PatternCompleteWordInput) <C-\><C-n><SID>(PatternCompleteWordInput)

if ! hasmapto('<Plug>(PatternCompleteInput)', 'v')
    vmap <C-x>/ <Plug>(PatternCompleteInput)
endif
if ! hasmapto('<Plug>(PatternCompleteWordInput)', 'v')
    vmap <C-x>* <Plug>(PatternCompleteWordInput)
endif

if g:PatternComplete_EnableBraceMappings
inoremap <script> <expr> <Plug>(PatternCompleteInputAsBrace)     PatternComplete#InputExpr(0, 'PatternComplete#AsBrace#Converter')
inoremap <script> <expr> <Plug>(PatternCompleteWordInputAsBrace) PatternComplete#InputExpr(1, 'PatternComplete#AsBrace#Converter')
inoremap <script> <expr> <Plug>(PatternCompleteSearchAsBrace)    PatternComplete#SearchExpr('PatternComplete#AsBrace#Converter')
inoremap <script> <expr> <Plug>(PatternCompleteLastAsBrace)      PatternComplete#LastExpr('PatternComplete#AsBrace#Converter')
if ! hasmapto('<Plug>(PatternCompleteInputAsBrace)', 'i')
    imap <C-x>g/ <Plug>(PatternCompleteInputAsBrace)
endif
if ! hasmapto('<Plug>(PatternCompleteWordInputAsBrace)', 'i')
    imap <C-x>g* <Plug>(PatternCompleteWordInputAsBrace)
endif
if ! hasmapto('<Plug>(PatternCompleteSearchAsBrace)', 'i')
    imap <C-x>g& <Plug>(PatternCompleteSearchAsBrace)
endif
if ! hasmapto('<Plug>(PatternCompleteLastAsBrace)', 'i')
    imap <C-x>g? <Plug>(PatternCompleteLastAsBrace)
endif


nnoremap <script> <expr> <SID>(PatternCompleteInputAsBrace)     PatternComplete#Selected(0, 'PatternComplete#AsBrace#Converter')
nnoremap <script> <expr> <SID>(PatternCompleteWordInputAsBrace) PatternComplete#Selected(1, 'PatternComplete#AsBrace#Converter')
" Note: Must leave selection first; cannot do that inside the expression mapping
" because the visual selection marks haven't been set there yet.
vnoremap <silent> <script> <Plug>(PatternCompleteInputAsBrace) <C-\><C-n><SID>(PatternCompleteInputAsBrace)
vnoremap <silent> <script> <Plug>(PatternCompleteWordInputAsBrace) <C-\><C-n><SID>(PatternCompleteWordInputAsBrace)

if ! hasmapto('<Plug>(PatternCompleteInputAsBrace)', 'v')
    vmap <C-x>g/ <Plug>(PatternCompleteInputAsBrace)
endif
if ! hasmapto('<Plug>(PatternCompleteWordInput)', 'v')
    vmap <C-x>g* <Plug>(PatternCompleteWordInput)
endif
endif


cnoremap <expr> <Plug>(PatternCompleteSearchMatch) PatternComplete#NextSearchMatch#InsertInCmdline(@/)
if ! hasmapto('<Plug>(PatternCompleteSearchMatch)', 'c')
    cmap <C-r>& <Plug>(PatternCompleteSearchMatch)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
