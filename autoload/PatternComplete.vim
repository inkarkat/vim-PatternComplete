" PatternComplete.vim: Insert mode completion for matches of queried / last search pattern.
"
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"   - ingo/str/find.vim autoload script
"   - ingo/text.vim autoload script
"
" Copyright: (C) 2011-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

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
function! s:Convert( matches )
    return (empty(s:Converter) ? a:matches : call(s:Converter, [a:matches]))
endfunction
function! PatternComplete#PatternComplete( findstart, base )
    if a:findstart
	return s:FindBase()
    else
	try
	    let s:pattern = s:GetSelectedBase(a:base)
	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches, s:pattern, {'complete': PatternComplete#GetCompleteOption(), 'abbreviate': 1})
	    return s:Convert(l:matches)
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
	    let s:pattern = '\<\%(' . l:base . '\m\)\>'
	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches, s:pattern, {'complete': PatternComplete#GetCompleteOption(), 'abbreviate': 1})
	    if empty(l:matches)
		let s:pattern = '\%(^\|\s\)\zs\%(' . l:base . '\m\)\ze\%($\|\s\)'
		call CompleteHelper#FindMatches(l:matches, s:pattern, {'complete': PatternComplete#GetCompleteOption()})
	    endif
	    return s:Convert(l:matches)
	catch /^Vim\%((\a\+)\)\=:/
	    call s:ErrorMsg(v:exception)
	    return []
	endtry
    endif
endfunction

function! s:PatternInput( isWordInput, preset )
    call inputsave()
    let s:pattern = input('Pattern to find ' . (a:isWordInput ? 'word-' : '') . 'completions: ', a:preset)
    call inputrestore()
endfunction
function! s:Expr( isWordInput, ... )
    let s:Converter = (a:0 ? a:1 : '')

    if a:isWordInput
	set completefunc=PatternComplete#WordPatternComplete
    else
	set completefunc=PatternComplete#PatternComplete
    endif
    let s:completefunc = &completefunc

    if s:selected ==# 's:pattern' && empty(s:pattern)
	" Note: When nothing is returned, the command-line isn't cleared
	" correctly, so it isn't clear that we're back in insert mode. Avoid
	" this by making a no-op insert.
	"return ''
	return "$\<BS>"
    endif

    return "\<C-x>\<C-u>"
endfunction
function! s:CapturePatternBeforeCursor( isWordInput )
    let s:selectedBaseCol = 0

    " Try delimited regexp before cursor first (if delimiters are defined).
    let l:delimitersPattern = ingo#plugin#setting#GetBufferLocal('PatternComplete_DelimitersPattern')
    if ! empty(l:delimitersPattern)
	let s:selectedBaseCol = searchpos('\(' . l:delimitersPattern . '\)\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\\1\|\%(\1\@!.\)\)*\1\%#', 'bn', line('.'))[1]
    endif

    if s:selectedBaseCol > 0
	let s:selected = 'a:base[1:-2]'
	return 1
    endif

    " Fallback to WORD before cursor, use as preset for pattern input.
    let s:selectedBaseCol = searchpos('\S\+\%#', 'bn', line('.'))[1]
    if s:selectedBaseCol > 0
	let l:base = ingo#text#Get([line('.'), s:selectedBaseCol], getpos('.')[1:2], 1)
	let s:selected = 's:pattern'
	call s:PatternInput(a:isWordInput, l:base)

	let l:baseIndex = ingo#str#find#StartIndex(l:base, s:pattern)
	" -1: The user did not accept the WORD before cursor preset; do not
	"     remove the base occupied by it.
	"  0: The user accepted WORD and just appended to it.
	" >0: The user partially accepted WORD, but removed parts at the
	"     beginning. Shift the start of the base accordingly.
	let s:selectedBaseCol = (l:baseIndex == -1 ? 0 : s:selectedBaseCol + l:baseIndex)

	return 1
    endif
    return 0
endfunction
function! PatternComplete#InputExpr( isWordInput, ... )
    if ! s:CapturePatternBeforeCursor(a:isWordInput)
	let s:selectedBaseCol = 0
	let s:selected = 's:pattern'
	call s:PatternInput(a:isWordInput, '')
    endif

    return call('s:Expr', [a:isWordInput] + a:000)
endfunction
function! PatternComplete#Selected( isWordInput, ... )
    call call('s:Expr', [a:isWordInput] + a:000)
    let s:selectedBaseCol = col("'<")
    let s:selected = 'a:base'

    return "g`>" . (col("'>") == (col('$')) ? 'a' : 'i') . "\<C-x>\<C-u>"
endfunction

function! PatternComplete#SearchExpr( ... )
    if empty(@/)
	call ingo#msg#ErrorMsg('E35: No previous regular expression')
	return "$\<BS>"
    endif

    let s:pattern = @/
    let s:selectedBaseCol = 0
    let s:selected = 's:pattern'

    return call('s:Expr', [0] + a:000)
endfunction
function! PatternComplete#LastExpr( ... )
    if empty(s:pattern)
	call ingo#msg#ErrorMsg('E35: No previous regular expression')
	return "$\<BS>"
    endif

    let s:selectedBaseCol = 0
    let s:selected = 's:pattern'

    return call('s:Expr', [(s:completefunc ==# 'PatternComplete#WordPatternComplete')] + a:000)
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
