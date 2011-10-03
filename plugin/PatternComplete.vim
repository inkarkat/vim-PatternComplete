" PatternComplete.vim: Insert mode completion that completes matches of queried
" {pattern} or last search pattern. 
"
" DESCRIPTION:
"   Most insert mode completions complete only the current word (or an entire
"
" USAGE:
"								    *i_CTRL-X_/*
" <i_CTRL-X_/>		The completion first queries for {pattern} (press
"			<Enter> to conclude), then finds matches for {pattern}. 
"								    *i_CTRL-X_**
" <i_CTRL-X_*>		The completion first queries for {pattern} (press
"			<Enter> to conclude), then finds matches for
"			\<{pattern}\>, or {pattern} surrounded by whitespace as
"			a fallback. 
"								    *i_CTRL-X_&*
" <i_CTRL-X_&>		Find matches for the last search pattern, |"/|. 
"								    *c_CTRL-R_&*
" <c_CTRL-R_&>		Insert first match for the last search pattern, |"/|. 
"
" INSTALLATION:
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script. 
"
" CONFIGURATION:
" INTEGRATION:
" LIMITATIONS:
" ASSUMPTIONS:
" KNOWN PROBLEMS:
" TODO:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	001	03-Oct-2011	file creation from MotionComplete.vim. 

" Avoid installing twice or when in unsupported Vim version. 
if exists('g:loaded_PatternComplete') || (v:version < 700)
    finish
endif
let g:loaded_PatternComplete = 1

if ! exists('g:PatternComplete_complete')
    let g:PatternComplete_complete = '.,w'
endif

function! s:GetCompleteOption()
    return (exists('b:PatternComplete_complete') ? b:PatternComplete_complete : g:PatternComplete_complete)
endfunction

function! s:TabReplacement()
    if ! exists('s:tabReplacement')
	let s:tabReplacement = matchstr(&listchars, 'tab:\zs..')
	let s:tabReplacement = (empty(s:tabReplacement) ? '^I' : s:tabReplacement)
    endif
    return s:tabReplacement
endfunction
function! s:Process( match )
    " Shorten the match abbreviation; also change (invisible) <Tab> characters. 
    let l:abbreviatedMatch = substitute(a:match.word, '\t', s:TabReplacement(), 'g')
    let l:maxDisplayLen = &columns / 2
    if len(l:abbreviatedMatch) > l:maxDisplayLen
	let a:match.abbr = EchoWithoutScrolling#TruncateTo(l:abbreviatedMatch, l:maxDisplayLen)
    endif

    return a:match
endfunction
function! PatternComplete#PatternComplete( findstart, base )
    if a:findstart
	" This completion does not consider the text before the cursor. 
	return col('.') - 1
    else
	try
	    let l:matches = []
	    call CompleteHelper#FindMatches( l:matches, s:pattern, {'complete': s:GetCompleteOption()} )
	    call map(l:matches, 's:Process(v:val)')
	    return l:matches
	catch /^Vim\%((\a\+)\)\=:E/
	    " v:exception contains what is normally in v:errmsg, but with extra
	    " exception source info prepended, which we cut away. 
	    let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	    echohl ErrorMsg
	    echomsg v:errmsg
	    echohl None

	    sleep 500m
	    return []
	endtry
    endif
endfunction
function! PatternComplete#WordPatternComplete( findstart, base )
    if a:findstart
	" This completion does not consider the text before the cursor. 
	return col('.') - 1
    else
	try
	    let l:matches = []
	    call CompleteHelper#FindMatches( l:matches, '\<\%(' . s:pattern . '\m\)\>', {'complete': s:GetCompleteOption()} )
	    if empty(l:matches)
		call CompleteHelper#FindMatches( l:matches, '\%(^\|\s\)\zs\%(' . s:pattern . '\m\)\ze\%($\|\s\)', {'complete': s:GetCompleteOption()} )
	    endif

	    call map(l:matches, 's:Process(v:val)')
	    return l:matches
	catch /^Vim\%((\a\+)\)\=:E/
	    " v:exception contains what is normally in v:errmsg, but with extra
	    " exception source info prepended, which we cut away. 
	    let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	    echohl ErrorMsg
	    echomsg v:errmsg
	    echohl None

	    sleep 500m
	    return []
	endtry
    endif
endfunction

function! s:PatternInput( isWordInput )
    call inputsave()
    let s:pattern = input('Pattern to find ' . (a:isWordInput ? 'word-' : '') . 'completions: ')
    call inputrestore()
endfunction
function! s:PatternCompleteInputExpr( isWordInput )
    call s:PatternInput(a:isWordInput)
    if empty(s:pattern)
	" Note: When nothing is returned, the command-line isn't cleared
	" correctly, so it isn't clear that we're back in insert mode. Avoid
	" this by making a no-op insert. 
	"return ''
	return "$\<BS>"
    endif

    if a:isWordInput
	set completefunc=PatternComplete#WordPatternComplete
    else
	set completefunc=PatternComplete#PatternComplete
    endif
    return "\<C-x>\<C-u>"
endfunction
inoremap <script> <expr> <Plug>(PatternCompleteInput)     <SID>PatternCompleteInputExpr(0)
inoremap <script> <expr> <Plug>(PatternCompleteWordInput) <SID>PatternCompleteInputExpr(1)
function! s:PatternCompleteSearchExpr()
    if empty(@/)
	let v:errmsg = 'E35: No previous regular expression'
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None

	return "$\<BS>"
    endif

    let s:pattern = @/
    set completefunc=PatternComplete#PatternComplete
    return "\<C-x>\<C-u>"
endfunction
inoremap <script> <expr> <Plug>(PatternCompleteSearch) <SID>PatternCompleteSearchExpr()

if ! hasmapto('<Plug>(PatternCompleteInput)', 'i')
    imap <C-x>/ <Plug>(PatternCompleteInput)
endif
if ! hasmapto('<Plug>(PatternCompleteWordInput)', 'i')
    imap <C-x>* <Plug>(PatternCompleteWordInput)
endif
if ! hasmapto('<Plug>(PatternCompleteSearch)', 'i')
    imap <C-x>& <Plug>(PatternCompleteSearch)
endif

"-------------------------------------------------------------------------------

function! PatternComplete#SubstForSearchMatch( text )
    " As the command-line is directly set via c_CTRL-\_e, no translation of
    " newlines is necessary. However, we need to pass a function to
    " CompleteHelper#FindMatches() to avoid the default behavior of removing
    " newlines. 
    return a:text
endfunction
function! PatternComplete#GetNextSearchMatch( completeOption )
    " As an optimization, try a buffer-search from the cursor position first,
    " before triggering the full completion search over all windows. 
    let l:startPos = searchpos(@/, 'cnw')
    if l:startPos != [0, 0]
	let l:endPos = searchpos(@/, 'enw')
	if l:endPos != [0, 0]
	    let l:searchMatch = CompleteHelper#ExtractText(l:startPos, l:endPos, {})
	    if ! empty(l:searchMatch)
		return l:searchMatch
	    endif
	endif
    endif

    if empty(a:completeOption) || a:completeOption ==# '.'
	" No completion from other buffers desired. 
	return @/
    endif

    " Do a full completion search. 
    " XXX: As the CompleteHelper#FindMatches() implementation visits every
    " window (and this is not allowed in a :cmap), we need to jump out of
    " command-line mode for that, and then do the insertion into the
    " command-line ourselves. 
    let [s:cmdline, s:cmdpos] = [getcmdline(), getcmdpos()]
    return "\<C-c>:call PatternComplete#SetSearchMatch(" . string(a:completeOption) . ")\<CR>"
endfunction
function! PatternComplete#SetSearchMatch( completeOption )
    try
	let l:completeMatches = []
	call CompleteHelper#FindMatches(l:completeMatches, @/, {'complete': a:completeOption, 'multiline': function('PatternComplete#SubstForSearchMatch')})
	if ! empty(l:completeMatches)
	    let s:match = l:completeMatches[0].word
	else
	    " Fall back to returning the search pattern itself. It's up to the
	    " user to turn it into literal text by editing out the regular
	    " expression atoms. 
	    let s:match = @/
	endif

	call feedkeys(":\<C-\>e(PatternComplete#SetSearchMatchCmdline())\<CR>")
    catch /^Vim\%((\a\+)\)\=:E/
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endtry
endfunction
function! PatternComplete#SetSearchMatchCmdline()
    call setcmdpos(s:cmdpos + len(s:match))
    return strpart(s:cmdline, 0, s:cmdpos - 1) . s:match . strpart(s:cmdline, s:cmdpos - 1)
endfunction
function! PatternComplete#SearchMatch()
    " For the command-line, newlines must be represented by a ^@; otherwise, the
    " newline would be interpreted as <CR> and prematurely execute the
    " command-line. 
    return substitute(PatternComplete#GetNextSearchMatch(s:GetCompleteOption()), '\n', "\<C-v>\<C-@>", 'g')
endfunction
cnoremap <expr> <Plug>(PatternCompleteSearchMatch) PatternComplete#SearchMatch()
if ! hasmapto('<Plug>(PatternCompleteSearchMatch)', 'c')
    cmap <C-r>& <Plug>(PatternCompleteSearchMatch)
endif

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
