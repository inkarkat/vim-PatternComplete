" PatternComplete.vim: Insert mode completion for matches of queried / last search pattern.
"
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"
" Copyright: (C) 2011-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.013	15-Sep-2017	ENH: Handle pattern selected in visual mode by
"				factoring out s:Expr() and adding
"				PatternComplete#Selected().
"				ENH: Handle /{pattern}/ base before cursor. The
"				source of the complete base is now in
"				s:selected, which is evaluated by
"				s:GetSelectedBase().
"   1.10.012	28-Apr-2016	ENH: Add <C-x>? mapping to reuse last search
"				pattern.
"   1.02.011	12-Jan-2015	Remove default g:PatternComplete_complete
"				configuration and default to 'complete' option
"				value instead.
"   1.02.010	18-Dec-2014	Use a:options.abbreviate instead of explicit
"				abbreviation loop.
"   1.01.009	14-Jun-2013	Use ingo/msg.vim.
"   1.01.008	06-Feb-2013	Move command-line insertion functions to
"				separate PatternComplete/NextSearchMatch.vim
"				script. Only need to additionally expose
"				s:GetCompleteOption().
"   1.00.007	01-Sep-2012	Make a:matchObj in CompleteHelper#ExtractText()
"				optional; it's not used there, anyway.
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

function! PatternComplete#GetCompleteOption()
    return ingo#plugin#setting#GetBufferLocal('PatternComplete_complete', &complete)
endfunction

function! s:ErrorMsg( exception )
    call ingo#msg#VimExceptionMsg()

    if &cmdheight == 1
	sleep 500m
    endif
endfunction
let s:pattern = ''
function! s:FindBase()
    return (s:selectedBaseCol ? s:selectedBaseCol - 1 : col('.') - 1)
endfunction
function! s:GetSelectedBase( base )
    execute 'return' s:selected
endfunction
function! PatternComplete#PatternComplete( findstart, base )
    if a:findstart
	return s:FindBase()
    else
	try
	    let l:base = s:GetSelectedBase(a:base)
	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches, l:base, {'complete': PatternComplete#GetCompleteOption(), 'abbreviate': 1})
	    return l:matches
	catch /^Vim\%((\a\+)\)\=:/
	    call s:ErrorMsg(v:exception)
	    return []
	endtry
    endif
endfunction
function! PatternComplete#WordPatternComplete( findstart, base )
    if a:findstart
	return s:FindBase()
    else
	try
	    let l:base = s:GetSelectedBase(a:base)
	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches, '\<\%(' . l:base . '\m\)\>', {'complete': PatternComplete#GetCompleteOption(), 'abbreviate': 1})
	    if empty(l:matches)
		call CompleteHelper#FindMatches(l:matches, '\%(^\|\s\)\zs\%(' . l:base . '\m\)\ze\%($\|\s\)', {'complete': PatternComplete#GetCompleteOption()})
	    endif
	    return l:matches
	catch /^Vim\%((\a\+)\)\=:/
	    call s:ErrorMsg(v:exception)
	    return []
	endtry
    endif
endfunction

function! s:PatternInput( isWordInput )
    call inputsave()
    let s:pattern = input('Pattern to find ' . (a:isWordInput ? 'word-' : '') . 'completions: ')
    call inputrestore()
endfunction
function! s:Expr( isWordInput )
    if a:isWordInput
	set completefunc=PatternComplete#WordPatternComplete
    else
	set completefunc=PatternComplete#PatternComplete
    endif
    let s:completefunc = &completefunc
    return "\<C-x>\<C-u>"
endfunction
function! s:CapturePatternBeforeCursor()
    let l:delimitersPattern = ingo#plugin#setting#GetBufferLocal('PatternComplete_DelimitersPattern')
    let s:selectedBaseCol = searchpos('\(' . l:delimitersPattern . '\)\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\1\|\%(\1\@!.\)\)*\1\%#', 'bn', line('.'))[1]
    return (s:selectedBaseCol > 0)
endfunction
function! PatternComplete#InputExpr( isWordInput )
    if s:CapturePatternBeforeCursor()
	let s:selected = 'a:base[1:-2]'
    else
	let s:selectedBaseCol = 0
	let s:selected = 's:pattern'
	call s:PatternInput(a:isWordInput)

	if empty(s:pattern)
	    " Note: When nothing is returned, the command-line isn't cleared
	    " correctly, so it isn't clear that we're back in insert mode. Avoid
	    " this by making a no-op insert.
	    "return ''
	    return "$\<BS>"
	endif
    endif

    return s:Expr(a:isWordInput)
endfunction
function! PatternComplete#Selected( isWordInput )
    call s:Expr(a:isWordInput)
    let s:selectedBaseCol = col("'<")
    let s:selected = 'a:base'

    return "g`>" . (col("'>") == (col('$')) ? 'a' : 'i') . "\<C-x>\<C-u>"
endfunction

function! PatternComplete#SearchExpr()
    if empty(@/)
	call ingo#msg#ErrorMsg('E35: No previous regular expression')
	return "$\<BS>"
    endif

    let s:pattern = @/
    set completefunc=PatternComplete#PatternComplete
    let s:completefunc = &completefunc
    return "\<C-x>\<C-u>"
endfunction
function! PatternComplete#LastExpr()
    if empty(s:pattern)
	call ingo#msg#ErrorMsg('E35: No previous regular expression')
	return "$\<BS>"
    endif

    let &completefunc = s:completefunc
    return "\<C-x>\<C-u>"
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
