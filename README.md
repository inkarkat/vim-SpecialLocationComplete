SPECIAL LOCATION COMPLETE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

Most custom completions are about particular bases, contexts, patterns, or
buffers, and are pretty fixed about them. But sometimes a special completion
(for example, only XML tag names) would be very useful, but it would be
overkill to write a complete custom completion for it (even though the
CompleteHelper.vim library makes this quite simple).
This plugin provides a generic, configurable framework for defining custom
completions through simple configuration objects, allowing both global and
buffer- or window-scoped completions. So if you e.g. need completion of
expressions inside &lt;% ... %&gt; for a particular filetype, you can quickly define
such, and assign it to a completion key.

### SOURCE

- [Inspiration for this plugin](http://stackoverflow.com/questions/28496473/a-particular-text-tagging-system-in-vim)

### SEE ALSO

- Check out the CompleteHelper.vim plugin page ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)) for a full
  list of insert mode completions powered by it.

USAGE
------------------------------------------------------------------------------

    In insert mode, invoke the special completion via CTRL-X CTRL-X; you will
    then be prompted for another key that selects the particular completion.
    You can then search forward and backward via CTRL-N / CTRL-P, as usual.

    CTRL-X CTRL-X {key}[...]Find special matches configured for {key}[...] (see
                            g:SpecialLocationCompletions).
                            Further use of CTRL-X CTRL-X will copy additional text
                            (what exactly is customizable, too).

    The plugin ships with the following global default completions:
    CTRL-X CTRL-X t         Find pure tag names (without attributes and the
                            surrounding <...>) in opening and closing tags.
    CTRL-X CTRL-X T         Find complete tags (everything inside and including
                            the <...>). Further use will copy following complete
                            tags (without text in between).
    CTRL-X CTRL-X CTRL-T    Find tag attributes (name="value") in tags.
    CTRL-X CTRL-X it        Text between arbitrary tags (<...>text here</...>),
                            starting with the base. If none is found, do a relaxed
                            search for the base anywhere between arbitrary tags.
                            Unlike the it text object, the surrounding tags need
                            not match; they can be _any_ opening or closing tags!
    CTRL-X CTRL-X num       Find decimal numbers starting with / containing the
                            base.
    CTRL-X CTRL-X hex       Find hexadecimal numbers (with or without "0x" prefix)
                            starting with / containing the base.
    CTRL-X CTRL-X uuid      Find UUIDs (c2e9853b-4d8e-48b6-af5a-ef0e6279fa61 and
                            c2e9853b4d8e48b6af5aef0e6279fa61) starting with /
                            containing the base.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-SpecialLocationComplete
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim SpecialLocationComplete*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.010 or
  higher.
- Requires the CompleteHelper.vim plugin ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)), version 1.40 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

This completion can provide an arbitrary number of special completions; these
can be available globally, or only in particular buffers or windows. Each
completion is defined by a configuration object under a (correspondingly
scoped) Dictionary; the key is the (sequence of) character(s) that must be
typed after the i\_CTRL-X\_CTRL-X completion mapping. The following example
shows the defaults (which are modeled after the built-in keyword completion),
and explains their use:

    let g:SpecialLocationCompletions = {
    \   'k': {

        The key(s) (after i_CTRL-X_CTRL-X) to invoke. No key-notation
        supported; i.e. use ^T (as a single char) for <C-t>. >
    \       'priority': 1000,
                Number that influences the position of the completion in the
                printed hints; lower numbers appear first. >
    \       'description': 'keywords',
                An (optional) explanation appended to the key in the prompt.

    \       'complete': '.,w,b,u'

                Specifies what is searched, like the 'complete' option. The
                default depends on the config variable scope: visible windows
                for w:, the current buffer for :b, and everything
                configured in 'complete' for g:. >
    \       'base': '\k\*\%#',
                The pattern to locate the completion base (before the cursor).

    \       'patternTemplate': '\<%s\k\+',

                With the base inserted at "%s", yields the pattern used to
                search for completions. Can also be a List of pattern
                templates; these are then searched sequentially until one
                pattern yields matches. >
    \       'emptyBasePattern': '',
                Optional alternative pattern to 'patternTemplate' that is used
                when there's no base. Can also be a List; these are then
                searched sequentially until one pattern yields matches. >
    \       'repeatPatternTemplate': '%s\zs\s*\k\+',
                When repeating the completion, yields the pattern to search
                for completions. "%s" is replaced with the full completion,
                "%S" is replaced with just the last added completion part.
                Alternatively, common repeat patterns can also be built from
                the following parts characterized by an anchor, a matching
                atom, and a non-matching in between (this is the default): >
    \       'repeatAnchorExpr': '\<',
    \       'repeatPositiveExpr': '\k',
    \       'repeatNegativeExpr': '\%(\k\@!\.\)',
                Note: You can't mix-and-match here, if you want to override
                repeatNegativeExpr, you also need to specify the previous ones! >
    \   }
    \}
In addition, any other a:options from CompleteHelper#FindMatches() can be
specified, too. These are passed to the CompleteHelper function.

If you want to use a different mapping, map your keys to the
&lt;Plug&gt;(SpecialLocationComplete) mapping target _before_ sourcing the script
(e.g. in your vimrc):

    imap <C-x><C-x> <Plug>(SpecialLocationComplete)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-SpecialLocationComplete/issues or email
(address below).

HISTORY
------------------------------------------------------------------------------

##### 2.00    19-May-2019
- FIX: CompleteHelper#Repeat#Processor() condenses a new line and the
  following indent to a single space; need to translate that. Otherwise,
  repeats using %S in the a:options.repeatPatternTemplate will not work on
  tab-indented or multi-line matches.
- ENH: Add new &lt;C-t&gt; default completion of full tag attributes (e.g. &lt;tag
  foo="bar"&gt;).
- ENH: Support Lists of a:options.patternTemplate and
  a:options.emptyBasePattern; these are searched sequentially until one yields
  matches. This allows fallbacks, e.g. a relaxed search anywhere vs. a strict
  search for base at the beginning.
- ENH: Add new it default completion for text between tags.
- ENH: Add default completions for decimal and hexadecimal numbers, UUIDs.
- ENH: Support sorting of completions via a:options.priority.

##### 1.00    24-Feb-2015
- First published version.

##### 0.01    13-Feb-2015
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2015-2019 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
