PATTERN COMPLETE   
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin offers completions that either use the last search pattern or
query for a regular expression, and then offer all matches for completion.

Without this plugin, you can just directly insert the contents of the last
search pattern register via CTRL-R /, but the register can contain \<word\>
boundary characters from a star search or other non-literal regexp atoms
like \V, .\*, etc., which you usually don't want inserted into the text.

### SEE ALSO

- Check out the CompleteHelper.vim plugin page ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)) for a full
  list of insert mode completions powered by it.

USAGE
------------------------------------------------------------------------------

    CTRL-X /                Use a "/"-delimited (g:PatternComplete_DelimitersPattern)
                            /{pattern}/ base before the cursor, or (if no such
                            base) the WORD before the cursor and allow further
                            refinement (press <Enter> to accept, <C-U> to discard
                            and enter something else, or just edit the preset), or
                            (if only whitespace before cursor) first query for
                            {pattern} (press <Enter> to conclude), and find
                            matches for {pattern}.
    {Visual}CTRL-X /        The completion finds matches for the selected pattern.

    CTRL-X *                Like above, but find matches for whole \<{pattern}\>,
                            or {pattern} surrounded by whitespace as a fallback.

    {Visual}CTRL-X *        Find whole word (or whole WORD as a fallback) matches
                            for the selected pattern.

    CTRL-X &                Find matches for the last search pattern, quote/.

    CTRL-R &                Insert first match for the last search pattern
                            quote/ into the command-line.

    CTRL-X ?                Find matches, reusing the {pattern} from the last
                            pattern completion.

    CTRL-X g/               Like above, but instead of offering matches as
    {Visual}CTRL-X g/       completion candidates, find common substrings and turn
    CTRL-X g*               all matches into a Bash-like Brace Expression.
    {Visual}CTRL-X g*       For example, /\<f\w\+\>/ yields foobar, fooxy and foon.
    CTRL-X g&               Those will be inserted as foo{bar,xy,n}.
    CTRL-X g?

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-PatternComplete
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim PatternComplete*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.033 or
  higher.
- Requires the CompleteHelper.vim plugin ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)), version 1.50 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

By default, the 'complete' option controls which buffers will be scanned for
completion candidates. You can override that either for the entire plugin, or
only for particular buffers; see CompleteHelper\_complete for supported
values.

    let g:PatternComplete_complete = '.,w,b,u'

The possible regular expression delimiters for a /{pattern}/ base before the
cursor (for i\_CTRL-X\_/ and i\_CTRL-X\_star) can be configured as a pattern:

    let g:PatternComplete_DelimitersPattern = '[/?#@]'

Set to an empty string to disable the special parsing of delimited {patterns}.

The Brace Expression can be created according to strict rules that allow a
expansion into the original matches:

    let g:PatternComplete_AsBraceOptions = {'strict': 1}

By default, a different algorithm is chosen that trades full equivalence
(between expression and substrings) for a shorter syntax that is better to
understand:

    let g:PatternComplete_AsBraceOptions = {'short': 1}

If you want to use different mappings, map your keys to the
 Plug>(PatternComplete) mapping targets _before_ sourcing the script (e.g.
in your vimrc):

    imap <C-x>/ <Plug>(PatternCompleteInput)
    imap <C-x>* <Plug>(PatternCompleteWordInput)
    vmap <C-x>/ <Plug>(PatternCompleteInput)
    vmap <C-x>* <Plug>(PatternCompleteWordInput)
    imap <C-x>& <Plug>(PatternCompleteSearch)
    cmap <C-r>& <Plug>(PatternCompleteSearchMatch)
    imap <C-x>? <Plug>(PatternCompleteLast)

If you don't want the mappings that return all matches as a single Bash-like
Brace Expression, you can disable them all at once via:

    let g:PatternComplete_EnableBraceMappings = 0

Alternatively, you can tweak or disable them all individually, too:

    imap <C-x>g/ <Plug>(PatternCompleteInputAsBrace)
    imap <C-x>g* <Plug>(PatternCompleteWordInputAsBrace)
    vmap <C-x>g/ <Plug>(PatternCompleteInputAsBrace)
    vmap <C-x>g* <Plug>(PatternCompleteWordInputAsBrace)
    imap <C-x>g& <Plug>(PatternCompleteSearchAsBrace)
    imap <C-x>g? <Plug>(PatternCompleteLastAsBrace)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-PatternComplete/issues or email (address
below).

HISTORY
------------------------------------------------------------------------------

##### 1.20    RELEASEME
- ENH: Add <C-x> g ... mappings to insert all pattern matches joined into a
  Bash-like Brace Expression.
- CHG: <C-x>/ and <C-x>\* insert mode mappings now grab the WORD before the
  cursor as a preset for editing (unless a separated /{pattern}/ is found).
  Using other completions to build the pattern is a common use case, the
  delimiters are often forgotten, selection is cumbersome and slow, and often
  there's a natural whitespace boundary, anyway.
  __You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.033!__

##### 1.10    16-Sep-2017
- ENH: Add <C-x>? mapping to reuse last search pattern.
- ENH: Also support visual mode variants for <C-x>/ and <C-x>\*.
- ENH: Also handle /{pattern}/ base before cursor; this is often quicker and
  more comfortable to enter (using register contents, other completions, etc.)
  than the explicit user query that has been the only possibility so far.

##### 1.02    28-Apr-2016
- Use a:options.abbreviate instead of explicit abbreviation loop. __You need
  to update to CompleteHelper.vim ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)) version 1.50!__
- Remove default g:PatternComplete\_complete configuration and default to
  'complete' option value instead.
- Use more functions from the ingo-library. __You need to update to
  ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.011!__

##### 1.01    15-Jul-2013
- DWIM: Remove the \<...\> enclosure when the last used search pattern is a
  whole word search (that just has no matches now).
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).

##### 1.00    01-Oct-2012
- First published version.

##### 0.01    03-Oct-2011
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2011-2017 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat <ingo@karkat.de>
