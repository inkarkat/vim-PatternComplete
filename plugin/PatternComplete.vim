" PatternComplete.vim: Insert mode completion for matches of queried / last search pattern.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - PatternComplete.vim autoload script
"
" Copyright: (C) 2011-2016 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.010	28-Apr-2016	ENH: Add <C-x>? mapping to reuse last search
"				pattern.
"   1.02.009	12-Jan-2015	Remove default g:PatternComplete_complete
"				configuration and default to 'complete' option
"				value instead.
"   1.01.008	06-Feb-2013	Move command-line insertion functions to
"				separate PatternComplete/NextSearchMatch.vim
"				script.
"   1.00.007	03-Sep-2012	Add value "b" (other listed buffers) to the
"				plugin's 'complete' option offered by
"				CompleteHelper.vim 1.20.
"	006	20-Aug-2012	Split off functions into separate autoload
"				script and documentation into dedicated help
"				file.
"	005	14-Dec-2011	BUG: Forgot to rename s:Process().
"	004	12-Dec-2011	Factor out s:ErrorMsg().
"				Error message delay is only necessary when
"				'cmdheight' is 1.
"	003	04-Oct-2011	CompleteHelper multiline handling is now
"				disabled; remove dummy function.
"	002	04-Oct-2011	Move s:Process() to CompleteHelper#Abbreviate().
"	001	03-Oct-2011	file creation from MotionComplete.vim.

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_PatternComplete') || (v:version < 700)
    finish
endif
let g:loaded_PatternComplete = 1

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


cnoremap <expr> <Plug>(PatternCompleteSearchMatch) PatternComplete#NextSearchMatch#InsertInCmdline()
if ! hasmapto('<Plug>(PatternCompleteSearchMatch)', 'c')
    cmap <C-r>& <Plug>(PatternCompleteSearchMatch)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
