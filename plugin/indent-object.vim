" vim: noet sw=2 ts=2
"--------------------------------------------------------------------------------
"
"  Copyright (c) 2010 Michael Smith <msmith@msmith.id.au>
"
"  http://github.com/michaeljsmith/vim-indent-object
"
"  Permission is hereby granted, free of charge, to any person obtaining a copy
"  of this software and associated documentation files (the "Software"), to
"  deal in the Software without restriction, including without limitation the
"  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
"  sell copies of the Software, and to permit persons to whom the Software is
"  furnished to do so, subject to the following conditions:
"  
"  The above copyright notice and this permission notice shall be included in
"  all copies or substantial portions of the Software.
"  
"  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
"  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
"  IN THE SOFTWARE.
"
"--------------------------------------------------------------------------------

" Mappings excluding line below.
onoremap <silent>ai :<C-u>cal TextObject(0, 0, [line("."), line(".")])<CR>
onoremap <silent>ii :<C-u>cal TextObject(1, 0, [line("."), line(".")])<CR>
vnoremap <silent>ai :<C-u>cal TextObject(0, 0, [line("'<"), line("'>")])<CR><Esc>gv
vnoremap <silent>ii :<C-u>cal TextObject(1, 0, [line("'<"), line("'>")])<CR><Esc>gv

" Mappings including line below.
onoremap <silent>aI :<C-u>cal TextObject(0, 1, [line("."), line(".")])<CR>
onoremap <silent>iI :<C-u>cal TextObject(1, 1, [line("."), line(".")])<CR>
vnoremap <silent>aI :<C-u>cal TextObject(0, 1, [line("'<"), line("'>")])<CR><Esc>gv
vnoremap <silent>iI :<C-u>cal TextObject(1, 1, [line("'<"), line("'>")])<CR><Esc>gv

function! TextObjectCount(inner, incbelow, range, count)

	" Record the current state of the visual region.
	let l0 = a:range[0]
	let l1 = a:range[1]

	" Repeatedly increase the scope of the selection.
	let cnt = a:count
	while cnt > 0

		" Look for the minimum indentation in the current visual region.
		" Skip empty lines.
		let l = l0
		let idnt = indent(nextnonblank(l))
		while l > 0 && l <= l1
			let idnt = min([idnt, indent(l)])
			let l = nextnonblank(l+1)
		endwhile

		" Search backward for the first line with less indent than the target
		" indent (skipping blank lines).
		let l_1 = l0
		let l_1o = l_1
		while l_1 > 0 && indent(l_1) >= idnt
			let l_1o = l_1
			let l_1 = prevnonblank(l_1-1)
		endwhile

		" Search forward for the first line with more indent than the target
		" indent (skipping blank lines).
		let l2 = l1
		let l2o = l2
		while l2 != 0 && indent(l2) >= idnt
			let l2o = l2
			let l2 = nextnonblank(l2+1)
		endwhile

		" Determine which of these extensions to include. Include neither if
		" we are selecting an 'inner' object. Exclude the bottom unless are
		" told to include it.
		let idnt2 = max([indent(l_1), indent(l2)])
		if indent(l_1) < idnt2 || a:inner
			let l_1 = l_1o
		endif
		if indent(l2) < idnt2 || a:inner || !a:incbelow
			let l2 = l2o
		endif
		let l_1 = max([l_1, 1])
		let l2 = min([l2, line("$")])

		" Check whether the visual region has changed.
		let chg = 0
		let chg = chg || l0 != l_1
		let chg = chg || l1 != l2

		" Update the vars.
		let l0 = l_1
		let l1 = l2

		" If there was no change, then don't decrement the count (it didn't
		" count because it didn't do anything).
		if chg
			let cnt = cnt - 1
		else
			let l0 = prevnonblank(l0-1)
		endif

	endwhile

	" Apply the range we have found.
	call cursor(l0, 1)
	normal! V
	call cursor(l1, 1)

endfunction

function! TextObject(inner, incbelow, range)
	call TextObjectCount(a:inner, a:incbelow, a:range, v:count1)
endfunction
