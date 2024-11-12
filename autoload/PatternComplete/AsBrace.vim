" PatternComplete/AsBrace.vim: Insert mode completion of all pattern matches as Brace Expression.
"
" DEPENDENCIES:
"   - CompleteHelper/Abbreviate.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"   - ingo/subs/BraceCreation.vim autoload script
"
" Copyright: (C) 2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! PatternComplete#AsBrace#Converter( matches )
    let l:matchNum = len(a:matches)
    if l:matchNum <= 1
	return a:matches
    endif

    let l:braceExpression = ingo#subs#BraceCreation#FromList(
    \   map(a:matches, 'v:val.word'),
    \   ingo#plugin#setting#GetBufferLocal('PatternComplete_AsBraceOptions')
    \)

    return [CompleteHelper#Abbreviate#Word({
    \   'word': l:braceExpression,
    \   'menu': printf('%d combined matches', l:matchNum)
    \})]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
