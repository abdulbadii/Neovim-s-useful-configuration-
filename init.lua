A =vim.api
local O,o = vim.o,vim.opt
local Akm, Ac = A.nvim_set_keymap, A.nvim_command
local Inp, Afk,Trm = A.nvim_input, A.nvim_feedkeys,A.nvim_replace_termcodes
--[[local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
 vim.fn.system({
	"git", "clone", "https://github.com/folke/lazy.nvim.git",
	"--branch=stable", lazypath,
 })
end
vim.opt.rtp:prepend(lazypath)
--require("lazy").setup({
--}) ]]
o.cursorline=true -- Cursor line hilite. On either one, comment out the other by --[=[	]=]
--[=[-- GUI
A.nvim_exec([[
highlight LineNr guifg=#DFDFDF
highlight CursorLine guibg=#001927 gui=NONE
highlight CursorLineNr guibg=#FFF009 guifg=#000019 gui=NONE
highlight Search guibg=#D03000 guifg=#FFFF00 gui=NONE
highlight Visual guibg=#FF09F0 guifg=#000000
autocmd!
autocmd InsertLeave * highlight CursorLine guibg=#001927 gui=NONE
autocmd InsertLeave * highlight CursorLineNr guibg=#FFF009 guifg=#000019
autocmd InsertEnter * highlight CursorLine guifg=NONE guibg=NONE gui=underline
autocmd InsertEnter * highlight CursorLineNr guibg=#0303EE guifg=#FBFB00 ]],
false) --]=]
---[=[ --Terminal
A.nvim_exec([[
highlight LineNr ctermfg=254
highlight CursorLine ctermbg=17 cterm=NONE
highlight CursorLineNr ctermbg=yellow ctermfg=black cterm=NONE
highlight Search ctermbg=88 ctermfg=11 cterm=NONE
highlight Visual ctermbg=9 ctermfg=0
autocmd!
autocmd InsertLeave * highlight CursorLine ctermbg=17 cterm=NONE
autocmd InsertLeave * highlight CursorLineNr ctermbg=yellow ctermfg=black
autocmd InsertEnter * highlight CursorLine ctermfg=NONE ctermbg=236 cterm=underline
autocmd InsertEnter * highlight CursorLineNr ctermbg=19 ctermfg=yellow
]],false)
--]=]
-- no auto comment, cursor at last position at scr center, leader key TO, etc
A.nvim_exec([[
autocmd FileType * setlocal formatoptions-=cro
autocmd VimLeavePre * let @c = &cmdheight
autocmd VimEnter * let &cmdheight= @c
	set tabstop=2
	set shiftwidth=2
	set breakindent
	set breakindentopt=shift:0
	set number
	set whichwrap+=<,>,[,],l
	highlight TrWSpc ctermbg=241 guibg=#494949
	match TrWSpc /\s\+$/
autocmd CmdlineLeave * if getcmdtype()=~'[/?]' |call searchcount() |endif
autocmd InsertEnter * set timeoutlen=199
autocmd InsertLeave * set timeoutlen=449 |autocmd TextChangedI * lua sTmrK()
autocmd InsertCharPre * lua navK()
autocmd TextChangedI * lua sTmrK()
autocmd BufReadPost * if line("'\"")>0 && line("'\"") <=line('$') |exe "normal! g`\"zz\<C-y>" |endif
]],false)
--"set showbreak=⮡
--"autocmd ModeChanged [vV\x16]:* let g:kmV_B=0
o.clipboard:append('unnamedplus')
--[=[ A.nvim_exec([[
if vim.fn.has('win32') then
vim.g.clipboard = {
name = 'win32yank',
 copy = {
	['+'] ='win32yank.exe -i --crlf',
	['*'] ='win32yank.exe -i --crlf',
	},
 paste = {
	['+'] ='win32yank.exe -o --lf',
	['*'] ='win32yank.exe -o --lf',
	},
	cache_enabled=0 }
end]])
]=]
vim.g.mapleader=' ' --spacebar is leader key --vim.g.maplocalleader = "9"
O.guicursor='n-v-sm-i-ci-ve:block,i:ver49-iCursor,r:hor49,a:blinkoff99-blinkon710-Cursor/lCursor'

Akm('v', '<Esc>', '<cmd>let g:WDx=0<CR><Esc>', {noremap=true,silent=true})
local preK, lasT,C = '',0,1 -- Fast repetitive nav. keys in Insert will exit it
function navK()
local now,k= vim.loop.hrtime(), vim.v.char
if preK==k and k:match('[jlki;]') then C=C+1
	if C>3 then
		if now-lasT<449*1e6 then
			if k==';' then
				Afk(Trm('<Right>'..string.rep('\b',C+1)..'<ESC>`^', true, false, true), 'n',true)
				Akm('n', ';', '', {})
				vim.defer_fn(function()
					Akm('n', ';', "col('.')==col('$')-1? ':lua dEol()<CR>': '\"_x'",{noremap=true,expr=true})
				end, 740)
			else Afk(Trm(string.rep('\b',C)..'<ESC>`^', 1,nil,1), 'n',1) end
		end C=1
	end
else preK=k; C=1;lasT=now end
end
Tmr = vim.loop.new_timer()
local inT1=nil
function sTmrK() -- Timer to auto exit Insert
	Tmr:stop()
	local now, T, t = vim.loop.hrtime()
	t= Last and (now-Last)/1e6 or 3300
	inT1= inT1 and inT1 or (t<900 and (t>610 and 1330 or 850) or 4700)
	PreT=PreT and PreT or t
	inT1=inT1+(t-PreT>90 and 197 or (t-PreT>0 and 69 or 0))
	Tmr:start( (PreT+t+inT1)/2, 0, function()
		vim.schedule(function()
		Afk(Trm("<ESC>`^", 1, nil, 1), 'n',true)
		Last=nil;inT1=nil;PreT=nil
		end)
	end)
	Last=now; PreT=t
end
-- Normal's ENTER like Insert's, Leader ENTER drops current line down
Akm('n', '<CR>', 'i<CR><Esc>', {noremap=true,silent=true})
Akm('n', '<Leader><CR>', 'kA<CR><Space><BS><Esc>', {noremap=true})
Akm('n', '<M-CR>', "col('.')<col('$')-1? 'i<CR><Esc>k$': 'a<CR>.<BS><Esc>'", {expr=true,noremap=true})
Akm('v', '<CR>', [[g:kmV_B? '<Esc>:let g:kmV_B=0<CR>' :'d']], {expr=true,noremap=true})
vim.g.kmV_B=0
Hld=1 -- h into Insert mode, Leader h toggle to keep/clear auto exit
Akm('n', 'h', "col('.')<col('$')-1? ':lua Last=vim.loop.hrtime();PreT=nil<CR>i' :':lua Last=vim.loop.hrtime();PreT=nil<CR>a'", {expr=true,noremap=true,silent=true})
Akm('v', 'h', [[mode()=="\<C-v>"? 'c': col('.')<col('$')-1? '<cmd>lua Last=vim.loop.hrtime()<CR>"_xi' :'<cmd>lua Last=vim.loop.hrtime()<CR>"_xa']], {expr=true,noremap=true,silent=true})
Akm('v', '<Leader>h', [[mode()=="\<C-v>"? 'c': col('.')<col('$')-1? '<cmd>lua Last=vim.loop.hrtime()<CR>di' :'<cmd>lua Last=vim.loop.hrtime()<CR>da']], {expr=true,noremap=true,silent=true})
Akm('i', '<Leader>h', "<C-o>:lua if PreT then if Hld then Tmr:stop();inT1=nil;Hld=nil;print('No auto exit to Normal') vim.cmd[[autocmd! TextChangedI]] else PreT=nil;Last=vim.loop.hrtime();Hld=1;print('Auto exit on timeout') vim.cmd[[autocmd TextChangedI * lua sTmrK()]]end else vim.cmd[[stopinsert]] end<CR>", {noremap=true,silent=true})
Akm('n', '<Leader>h', "col('.')<col('$')-1? '' :'<cmd>lua Last=vim.loop.hrtime()<CR>i'", {expr=true,noremap=true})
Akm('v', '<Leader>i', [[mode()=="\<C-v>" ? '<cmd>lua Last=vim.loop.hrtime()<CR>I': '']],{expr=true,noremap=true})
Akm('n', 's', '<cmd>lua Last=vim.loop.hrtime()<CR>"_s', {noremap=true})
-- INS is into replace mode, toggling there. else does ESC, exit
Akm('n', '<Insert>', ':lua Last=vim.loop.hrtime()<CR>R', {noremap=true})
Akm('i', '<Insert>', "luaeval('PreT and 1 or 0')? '<Insert>': '<C-o>:stopinsert<CR>'", {expr=true,noremap=true,silent=true})
Akm('c', '<Insert>', '<C-c>', {noremap=true})
vim.keymap.set({'v','o','s','t'}, '<Insert>', '<cmd>let g:WDx=0<CR><Esc>', {noremap=true})

Akm('n', '<Space>', "col('.')<col('$')-1? 'i <Esc>`^': 'a <Esc>`^'", {expr=true,noremap=true})
Akm('v', '<Space>', [[mode()=='v'? '<C-v>': mode()=="\<C-v>"? 'V' :'<C-v>']], {expr=true,noremap=true})
--Akm('n', '<C-Space>', "col('.')<col('$')-1? '': 'i <Esc>`^'", {expr=true,noremap=true}) --GUI
Akm('n', '<M-Space>', "col('.')<col('$')-1? '': 'i <Esc>`^'", {expr=true,noremap=true})
-- p behaves P except at EOL, vice versa P behaves p, in visual it'll swap selc./register
local virC=vim.fn.virtcol
function nlP(E)
local l, s,t = {}
local _,R,C=unpack(vim.fn.getpos('.'))
t=vim.fn.getregtype("")
s=vim.fn.getreg("")
if E or t=='V' then
	if string.sub(t,1,1)=='\022' then
		if E>1 then
			s=s:gsub('\n',' ')
			A.nvim_buf_set_text(0, R-1,C-1, R-1,C-1, {s})
			Ac('normal! '..virC({R,C})..'|v'..virC({R,C+#s})..'|')
		else vim.cmd('normal! '..(E==1 and 'p' or 'P')..'`[`]') end
	else
		s=s:gsub('^%s+',''):gsub('%s+$',''):gsub('\n','')
		C=C+(E or 0)
		A.nvim_buf_set_text(0, R-1,C-1, R-1,C-1, {s})
		Ac('normal! '..virC({R,C+#s})..'|')
	end
else
	if t=='v' then vim.cmd[[ exe "normal! ^i\<CR>\<Esc>kp`[".getregtype("")."`]=\<Esc>"]]
	else
		for m in (s..'\n'):gmatch("(.-)"..'\n') do table.insert(l,m) end
		vim.cmd('normal! 0i'..string.rep('\013',#l)..'\027'..#l..'-P')
	end
end
end
Akm('n', 'p', [[ getline('.') !~ "\\S" || col('.')<col('$')-1? getregtype("")=~'^[\x16]'? 'P`['.nr2char(22).'`]' : getregtype("")=~'V'? 'Pl`['.getregtype("").'`]=<Esc>' :'Pl' : ':lua nlP(1)<CR>']], {expr=true,noremap=true,silent=true})
Akm('n','P','pl',{noremap=true,silent=true})
Akm('v', 'p', [[mode()=='V'? 'p': getregtype("")=='v'? col('.')<col('$')-1? '"_xPl': '"_xpl': '"_x<cmd>lua nlP(2)<CR>']], {expr=true,noremap=true,silent=true})
Akm('v','P', [[getregtype("")=~'^[\x16]'? '"_x<cmd>:lua nlP(0)<CR>': 'pl']] ,{expr=true,noremap=true})
Akm('n', '<Leader>p', [[col('.')<col('$')-1? ':lua nlP()<CR>': ':lua nlP(0)<CR>']], {expr=true,noremap=true,silent=true})
Akm('n', '<Leader>P', [[getregtype("")[0]==nr2char(22)? ':lua nlP(2)<CR>':'']], {expr=true,noremap=true,silent=true})
Akm('n', '<Leader>4', [['`['.getregtype("").'`]']], {expr=true})
vim.g.Cwl=nil
-- Navigator
local C,ltsT = 1,0 -- Progressive/incr. scroll
function iScrl(U)
	local now, R =vim.loop.hrtime(), U and U or 'j'
	if now-ltsT< 299*1e6 then
		if C<16 then Ac('normal! '..(vim.g.Cwl and 'g' or '')..R)
			if C==15 then Ac('normal! mk') end
		elseif C<43 then Ac('normal! '..(math.floor(C/8))..R) vim.g.Cwl=nil
		elseif C<85 then Ac('normal! '..(math.ceil(C/6))..R)
		elseif C<121 then Ac('normal! '..(math.ceil(C/4))..R)
		else Ac('normal! '..(math.ceil(C/2))..R) end
		C=C+1
		if C%5==0 then ltsT=now end
	else Ac('normal! '..(vim.g.Cwl and 'g' or '')..R) C=1
		ltsT=now end
end
Akm('n', 'j', [[col('.')==1? "k$:if virtcol('$')>winwidth(0)-&numberwidth |let g:Cwl=1 |endif<CR>" :'h']], {expr=true,noremap=true,silent=true})
Akm('n', 'l', [[col('.')==col('$')-1? "j^:if virtcol('$')>winwidth(0)-&numberwidth |let g:Cwl=1 |endif<CR>" :'l']], {expr=true,noremap=true,silent=true})
Akm('n', 'i', ":lua iScrl('k')<CR>", {noremap=true,silent=true})
Akm('n', 'k', ':lua iScrl()<CR>', {noremap=true,silent=true})
Akm('v', 'j', [[col('.') == 1? 'k$<cmd>let g:kmV_B=0<CR>': 'h<cmd>let g:kmV_B=0<CR>']], {noremap=true,expr=true})
Akm('v', 'l', [[col('.') == col('$')-1? 'j0<cmd>let g:kmV_B=0<CR>' : 'l<cmd>let g:kmV_B=0<CR>']], { noremap=true, expr=true })
Akm('v', 'i', 'k<cmd>let g:kmV_B=0<CR>', { noremap=true,silent=true })
Akm('v', 'k', 'j<cmd>let g:kmV_B=0<CR>', { noremap=true,silent=true })
Akm('n', '<Up>', '<C-u>', { noremap=true})
Akm('n', '<Down>', '<C-d>', { noremap=true})
Akm('n', '<C-u>', '<C-e>', {noremap=true})
local R,C, Lc,Rc, I,S, Pt,Pre, Wrp = 0,0,0,0,0 -- Get through end points on line
function eol(i)
local r,c,x = unpack(vim.fn.getpos('.'),2,3)
if i~=Pre or r~=R or c~=Pt then
	Wrp= Wrp and Wrp or vim.fn.winwidth(0)-vim.opt.numberwidth:get()
	if r==R and (c<=Lc or Rc<=c) then c=C end
	if i then S={'^','0', virC({r,c})..'|','g_','$'}
	else
		S={'g_','$', virC({r,c})..'|','^','0'}
		for e= Wrp,vim.fn.col('$'), Wrp do table.insert( S,3,e..'|') end
	end
	vim.g.Cwl= Wrp<vim.fn.col('$') and 1 or nil
	I=0; R=r;C=c; Pre=i; Pt=0
end
while	1 do I=I+1
	Ac( 'normal! '..S[I])
	x=vim.fn.col('.')
	if I==1 then if i then Lc=x else Rc=x end
	elseif I==4 then if i then Rc=x else Lc=x end end
	if x~=Pt then Pt=x break end
	I=I % #S
end
I=I % #S
end
Akm('n', '[', ':lua eol()<CR>', {silent=true,noremap=true})
Akm('n', '0', ':lua eol(1)<CR>', {silent=true,noremap=true})
Akm('v', '0', '<cmd>lua eol(1)<CR>', {silent=true,noremap=true})
Akm('n', '<Leader>l', 'v<cmd>lua eol()<CR>', {silent=true,noremap=true})
Akm('v', '<Leader>l', '<cmd>lua eol()<CR>', {silent=true,noremap=true})
Akm('v', 'u', '<Esc>u', {noremap=true})
-- ;, n, Del, etc will delete literally, unlike d or x' cut
function dEol()
	Ac("nnoremap ; \\<Nop> |normal! \"_x")
	vim.defer_fn(function()
		Akm('n', ';', "col('.')==col('$')-1? ':lua dEol()<CR>': '\"_x'", {noremap=true,expr=true}) end, 870)
end
Akm('n', ';', "col('.')==col('$')-1? ':lua dEol()<CR>': '\"_x'", {noremap=true,expr=true})
Akm('v', ';', '"_d', { noremap=true })
Akm('n', '<Leader>;', '"_d$', { noremap=true })
Akm('n', 'D', '"_D', { noremap=true })
Akm('i', "<Leader>;", '<C-o>"_d$', { noremap=true })
Akm('n', '<Del>', [[col('.') >= col('$')-1 ? '"_xa': '"_x']], { noremap=true,expr=true})
Akm('i', '<Del>', [[col('.') == col('$') ? '': '<C-o>"_x']], { noremap=true,expr=true })
Akm('v', '<Del>', '"_x', { noremap=true })
Akm('n', '<BS>', [[col('.') == 1 ? '' : 'h"_x']], { noremap=true,expr=true })
Akm('i', '<BS>', "col('.') == 1 ? '' : '<BS>'", { noremap=true,expr=true })
Akm('n', '<Leader>d', '"_d', { noremap=true })
Akm('n', 'n', '"_dd', { noremap=true, silent=true })
Akm('n', '<Leader>t', 'i	<Esc>`^', {noremap=true}) --Tab
Akm('i', '<Leader>t', '	', {noremap=true})
Akm('n', '<M-o>', 'o', {noremap=true}) --Vim o by Alt+o
Akm('n', 'd', 'mld', { noremap=true })
Akm('n', 'y', 'mly', { noremap=true })
-- Search. Alt+BACKSP clears cmd entry
Ac([[
cnoremap <M-BS> <C-u>
function! LnM()
	let c=line('.')| let b=line('w$')| let t=line('w0')
	if c>b-5 |exe 'normal! '.(7-b+c)."\<C-e>"
	elseif c<t+5 |exe 'normal! '.(7-c+t)."\<C-y>" |endif
endfunction
nnoremap <silent> <C-n> n:call LnM()<CR>
nnoremap <silent> <C-b> N:call LnM()<CR>
nnoremap <silent> u u:call LnM()<CR>
nnoremap <silent> o <C-r>:call LnM()<CR>
function! EdE()
	call feedkeys("/\<C-u>\\v<".@/.'>', 'nt')
	if mapcheck('<M-CR>','c') != ''|cunmap <M-CR>|endif
endfunction
function! KM_EdE()
	set hlsearch| cnoremap <M-CR> <CR>:call EdE()<CR>
endfunction
nnoremap / :call KM_EdE()<CR>/<C-r><C-w>
function! SSel()
	let [R,C,r,c] = getpos("'<")[1:2]+getpos("'>")[1:2]
	if R!=r |echo "Can't be Multi-line"| return|endif
	call feedkeys('/'.getline(R)[C-1:c-1], 'nt')
	set hlsearch
	cnoremap <M-CR> <CR>:call EdE()<CR>
endfunction
vnoremap / :call SSel()<CR>
function! SSel()
	let [R,C,r,c] = getpos("'<")[1:2]+getpos("'>")[1:2]
	if R!=r |echo "Can't be Multi-line"| return|endif
	call feedkeys('/'.getline(R)[C-1:c-1], 'nt')
	set hlsearch
	cnoremap <M-CR> <CR>:call EdE()<CR>
endfunction
vnoremap ? :call SubS()<CR>
]])
-- Selection
Akm('n', '<Leader><Space>', 'V', {noremap=true,silent=true})
Akm('n', '<Leader>j', 'v', {noremap=true,silent=true})
Akm('n', '<Leader>v', '<C-v>', {noremap=true})
vim.g.WDx=0;vim.g.J='' --Select word, or through words string joined by .-=/\+*
Ac([[
function! s:wdx()
if !g:WDx
	let [R,C]=getpos("'<")[1:2]
	let c=getpos("'>")[2]
	let s=getline(R)
	echo 'J' g:J
	let Jno= g:J==''
	let g:J= Jno? '[-.=/\\+*]' : '['.g:J.']'
	let [t,b,en]=matchstrpos(s,"\\v^\\w+\\zs%((".g:J.")\\w+%(\\1\\w+)*)?", C-1)
	let s:ST=[] |let s:o=[R,C]
	let FND= b!=en |let b+=1
	if b
		if FND && Jno |let g:J='['.t[0].']' |endif
	else |let en=c
	endif
	let [_,B,E]= matchstrpos(s[0:c-1], "\\v\\w+\\ze%(".g:J."\\w+)+$")
	let B+=1
	if B
		let s:ST= [ virtcol([R,B]).'|v'.virtcol([R,en]).'|' ]
	elseif !b |return 0|endif
	if b && FND
		let s:ST += [ virtcol([R,C]).'|v'.virtcol([R,en]).'|' ]
		let e=0
		while 1 |do
			let e=matchend( t,"\\v^".g:J."\\w+", e)
			let m=b-1+e
			if m>=en ||e<0 |break|endif
			let s:ST += [ virtcol([R,C]).'|v'.virtcol([R,m]).'|' ]
		endwhile
	endif
	if B
		let e=0
		while 1 |do
			let s:ST += [ virtcol([R,B]).'|v'.virtcol([R,E+e]).'|' ]
			let e=matchend( s[E:],"\\v^".g:J."\\w+", e)
			if e<0 |break|endif
		endwhile
	endif
	let g:WDx=1 |let s:I=0
endif
if s:I==len(s:ST) |let g:WDx=0|exe "normal! \<Esc>".virtcol(s:o).'|' |return|endif
exe 'normal! '.s:ST[s:I]
let s:I+=1
endfunction
function! WDX()
	let s=getline('.') |let c=col('.')
	if s[c-1] =~ '\w' | let g:J=''| normal! viw
	elseif s[c-2:c] =~ '\w[-.=/\\+*]\w'
		exe "normal! lviw\<Esc>"
		let B=match(s,"\\v\\w+\\zs([-.=/\\+*])\\w+%(\\1\\w+)*.{,".(col('$')-c-strlen(expand('<cword>')))."}$")
		if B+1 |let g:J=s[B:B] |let g:WDx=0 |call <SID>wdx()
	endif|endif
endfunction
nnoremap <silent> <Leader>y :call WDX()<CR>
vnoremap <silent> <M-y> :call <SID>wdx()<CR>
nnoremap <Leader>6 vb
nnoremap <Leader>7 ve
]])
local Sw2n, LEN,Len,R,C,r,c = nil,0,0 --2 words/selections swap
function swS()
	local VBlk, t, Y,X, y,x = vim.fn.mode()=='\022'
	--vim.cmd "highlight Word guibg=#00EF00 guifg=#FF00BB" --GUI
	vim.cmd "highlight Word ctermbg=10 ctermfg=0"
	if VBlk then
		V_C=virC({R,C})
		V_c=virC({r,c})
	elseif Sw2n then
		Ac('normal! '..(vSl and '' or 'viw')..'\027')
		_,Y,X = unpack(vim.fn.getpos("'<"))
		_,y,x = unpack(vim.fn.getpos("'>"))
		t=A.nvim_buf_get_text(0, Y-1,X-1, y-1,x, {})
		for _,s in ipairs(t) do Len=Len+#s end
		Ac('normal! gvP')
		A.nvim_buf_add_highlight(0, 0, 'Word', Y-1, X-1, X-1+LEN)
		A.nvim_buf_set_text(0, R-1,C-1, r-1, c, t)
		A.nvim_buf_add_highlight(0,-1, 'Word', R-1, C-1, C-1+Len)
		vim.defer_fn(function()
			A.nvim_buf_clear_namespace(0, -1, R-1, R)
			A.nvim_buf_clear_namespace(0, 0, Y-1, Y) end,2770)
		Sw2n=nil
	else LEN=0; Len=0
		Ac('normal! '..(vSl and 'y' or 'viwy'))
		_,R,C = unpack(vim.fn.getpos("'<"))
		_,r,c = unpack(vim.fn.getpos("'>"))
		t=A.nvim_buf_get_text(0, R-1,C-1, r-1,c, {})
		for _,s in ipairs(t) do LEN=LEN+#s end
		A.nvim_buf_add_highlight(0,-1, 'Word', R-1, C-1, C-1+LEN)
		print('Go on next selection or word to swap') Sw2n=1
	end
	vSl=nil
end
Akm('n', '<Leader>P', ':lua swS()<CR>', {noremap=true})
Akm('v', '<Leader>P', '<cmd>lua vSl=1;swS()<CR>', {})
-- Duplicate line or selection
Akm('n', 'b', ':t.<CR>', {})
function dup(S)
	local VBlk, isVL, blk, of, nl, t, b,d= vim.fn.mode()=='\022', vim.fn.mode()=='V', {}, 0,0
	Ac('normal! \027')
	local _, R,C = unpack(vim.fn.getpos("'<"))
	local _, r,c = unpack(vim.fn.getpos("'>"))
	V_C=virC({R,C})
	V_c=virC({r,c})
	if VBlk then
		if V_C>V_c then
			wd=V_C-V_c
			C= c+V_c-virC({R,c})
			V_C=virC({R,C})
		else wd=V_c-V_C end
		for i= R,r do
			d=C+V_C-virC({i, C})
			table.insert(blk, vim.fn.getline(i):sub( d,d+wd))
		end
		C=C+wd+1
		b=C+virC({R,C})
		for i,l in ipairs(blk) do
			if S then C=1
				A.nvim_buf_set_text(0, R-2+i, 0, R-2+i, 0, {l,''})
			else
				d=b-virC({R-1+i,C})-1
				A.nvim_buf_set_text(0, R-2+i, d, R-2+i, d, {l}) end
		end
		Ac('normal! '..R..'G'..virC({R,C})..'|')
		A.nvim_input('\\<C-v>')
		c=C+wd
		d=c+virC({R,c})-virC({r,c})
		Ac('normal! v'..r..'G'..virC({r,d})..'|')
	else
		c= isVL and vim.fn.col({r,'$'})-1 or c
		t= A.nvim_buf_get_text(0, R-1,C-1, r-1, c, {})
		d=c+1
		if R==r then of=c
		elseif C==1 then table.insert(t,1,'') -- prepend newline
			nl=1 ;d=1 end
		c= c==vim.fn.col('$') and c-1 or c -- don't get newline col
		A.nvim_buf_set_text(0, r-1,c, r-1,c, t)
		l=r+nl
		Ac('normal! '..l..'G'..virC({l,d})..'|')
		r=l+r-R
		c=isVL and '$' or of+#t[#t]
		Ac('normal! v'..r..'G'..virC({r, vim.fn.col({r,c})})..'|')
	end
end
Akm('v', 'b', '<cmd>lua dup();vim.g.kmV_B=1<CR>', {noremap=true})
Akm('v', '<Leader>b','<cmd>lua dup(1);vim.g.kmV_B=1<CR>', {noremap=true})
vim.g.Lc,vim.g.Vlc=0,0 -- Letter case toggle
Ac([[
function! TtLc()
	let [R,C]=getpos("'<")[1:2]
	let [r,c]=getpos("'>")[1:2]
	let l=getline(R)
	normal! u
	if R!=r
		let s= substitute( l[C-1:], '\v<(\a)(\w*)','\U\1\L\2', 'g')
		call setline( R, l[:C-1].s)
		for i in range( R+1, r-1)
			let s= substitute( getline(i), '\v<(\a)(\w*)','\U\1\L\2', 'g')
			call setline( i,s)
		endfor
		let l=getline(r)
		let s= substitute( l[:c-1], '\v<(\a)(\w*)','\U\1\L\2', 'g')
		call setline( r, s.l[c-1:])
	else
		let s= substitute( l[C-1:c-1], '\v<(\a)(\w*)','\U\1\L\2', 'g')
		call setline( R, (C-1? l[:C-2]:'').s.l[c:])
	endif
endfunction
let [s:i,s:y,s:x]=[0,0,0]
function! LtrC()
if !g:Lc
	let s:S=[ 'gv~', 'gvgU', 'gvgu', 'call TtLc()', '' ]
	let [s:y,s:x]=getpos('.')[1:2]
	let s:i=0
	let g:Lc=1
	nnoremap u u:let g:Lc=0\|let g:Vlc=0\|nunmap u<CR>
endif
let [l,f]=getpos('.')[1:2]
if s:y!=l ||s:x!=f
	let s:y=l |let s:x=f |let s:i=0 |normal! gv
endif
let K='normal! '
if s:i
	if s:i==3 |let K='' |else |let K.='u' |endif|endif
exe K.s:S[s:i].(g:Vlc? (s:i==3? '|normal! ':'').'gv': '')
let s:i+=1 |let s:i %= 5
endfunction
nnoremap <expr><silent> gu getline('.')[col('.')-1]=~'\w'? 'viw:<C-u>call LtrC()<CR>' :''
vnoremap <silent> gu :<C-u>let g:Vlc=1\|call LtrC()<CR>
]])
-- Move visual char/block up
function slUP()
local VBlk, e,l, V_C,V_c, Vwd,d,iC,ic,nc,V =vim.fn.mode()=='\022',0
Ac('normal! \027')
local _, R,C = unpack(vim.fn.getpos("'<"))
local _, r,c = unpack(vim.fn.getpos("'>"))
V_C=virC({R,C})
V_c=virC({r,c})
if VBlk then
	if V_C>V_c then
		Vwd=V_C-V_c
		C= c+V_c-virC({R,c})
		V_C=virC({R,C})
		c=c+Vwd
		V_c=virC({r,c})
	else Vwd=V_c-V_C end
	s=string.rep(' ',A.nvim_get_option('tabstop'))
	for i=R,r do
		iC=C+V_C -virC({i,C}) iC=iC +V_C -virC({i,iC})
		nC=C+V_C -virC({i-1,C}) nC=nC +V_C -virC({i-1,nC})
		ic= c +V_c -virC({i,c})
		ic= ic +V_c -virC({i,ic})
		l=vim.fn.getline(i)
		l=string.sub( l,1,iC-1)..(string.gsub(string.sub( l,iC,ic),'[\09]',s))..string.sub( l,ic+1)
		vim.fn.setline(i,l)
		d=V_C-virC({i-1,'$'})
		e=vim.fn.col({i-1,'$'})-1
		if d>0 then A.nvim_buf_set_text(0, i-2,e, i-2,e, {string.rep(' ',d)}) end
		A.nvim_buf_set_text(0, i-1, iC-1, i-1, iC+Vwd, {})
		A.nvim_buf_set_text(0, i-2, nC-1, i-2, nC-1, {string.sub( l,iC,iC+Vwd)})
	end
	Ac('normal! '..(R-1)..'G'..V_C..'|\022'..(r-1)..'G'..V_c..'|')
else
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	e=c==vim.fn.col({r,'$'})
	A.nvim_buf_set_text(0, R-1, C-1, r-1,e and c-1 or c, {})
	if e then
		table.insert(s,'') Ac(R..','..(R+1)..'join') end
	if virC({R-1, '$'})<V_C then
		e=vim.fn.col({R-1,'$'})
	else
		e= C+V_C-virC({R-1,C}) e=e+V_C-virC({R-1,e}) end
	A.nvim_buf_set_text(0, R-2, e-1, R-2, e-1, s)
	Ac('normal! '..(R-1)..'G'..virC({R-1,e})..'|v'..(r-1)..'G'..virC({r-1,c})..'|')
end vim.g.kmV_B=1
end
Akm('n', 'I', ':m .-2<CR>', {noremap=true,silent=true})
Akm('v', 'I', [[mode()=='V'? ":<C-u>'<-1m '>|let g:kmV_B=1<CR>gv=gv": '<cmd>lua slUP()<CR>']], {noremap=true,expr=true,silent=true})
-- Move visual char/block down
function slDN()
local VBlk, e,l, V_C,V_c, Vwd,d,iC,ic,nc,V =vim.fn.mode()=='\022',0
Ac('normal! \027')
local _, R,C = unpack(vim.fn.getpos("'<"))
local _, r,c = unpack(vim.fn.getpos("'>"))
V_C=virC({R,C})
V_c=virC({r,c})
if VBlk then
	if V_C>V_c then
		Vwd=V_C-V_c
		C= c+V_c-virC({R,c})
		V_C=virC({R,C})
		c=c+Vwd
		V_c=virC({r,c})
	else Vwd=V_c-V_C end
	s=string.rep(' ',A.nvim_get_option('tabstop'))
	for i=r,R,-1 do
		iC=C +V_C -virC({i,C})	iC=iC +V_C -virC({i,iC})
		nC=C +V_C -virC({i+1,C}) nC=nC +V_C -virC({i+1,nC})
		ic= c +V_c -virC({i,c})
		ic= ic +V_c -virC({i,ic})
		l=vim.fn.getline(i)
		l=string.sub( l,1,iC-1)..(string.gsub(string.sub( l,iC,ic),'[\09]',s))..string.sub( l,ic+1)
		vim.fn.setline(i,l)
		d=V_C-virC({i+1,'$'})
		e=vim.fn.col({i+1,'$'})-1
		if d>0 then A.nvim_buf_set_text(0, i,e, i,e, {string.rep(' ',d)}) end
		A.nvim_buf_set_text(0, i-1, iC-1, i-1, iC+Vwd, {})
		A.nvim_buf_set_text(0, i, nC-1, i, nC-1, {string.sub( l,iC,iC+Vwd)})
	end
	Ac('normal! '..(R+1)..'G'..V_C..'|\022'..(r+1)..'G'..V_c..'|')
else
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	e=c==vim.fn.col({r,'$'})
	A.nvim_buf_set_text(0, R-1, C-1, r-1,e and c-1 or c, {})
	if e then
		table.insert(s,'') Ac(R..','..(R+1)..'join') end
	if virC({R+1, '$'})<V_C then
			e=vim.fn.col({R+1,'$'})
	else
		e= C+V_C-virC({R+1,C}) e=e+V_C-virC({R+1,e}) end
	A.nvim_buf_set_text(0, R, e-1, R, e-1, s)
	Ac('normal! '..(R+1)..'G'..virC({R+1,e})..'|v' ..(r+1)..'G'..virC({r+1,c})..'|')
end vim.g.kmV_B=1
end
Akm('n', 'K', ':m .+1<CR>', {noremap=true,silent=true})
Akm('v', 'K', [[mode()=='V'? ":<C-u>'>+1m '<-1|let g:kmV_B=1<CR>gv=gv": '<cmd>lua slDN()<CR>']], {noremap=true,expr=true,silent=true})
function slLF() -- Move visual char/block left
local VBlk, e,l, V_C,V_c, Vwd,d,iC,ic,ns,V =vim.fn.mode()=='\022'
Ac('normal! \027')
local _,R,C =unpack(vim.fn.getpos("'<"))
local _,r,c =unpack(vim.fn.getpos("'>"))
V_C=virC({R,C})
V_c=virC({r,c})
if VBlk then
	if V_C>V_c then
		Vwd=V_C-V_c
		C= c+V_c -virC({R,c})
		V_C=virC({R,C})
		c=c+Vwd
		V_c=virC({r,c})
	else Vwd=V_c-V_C end
	ns=A.nvim_get_option('tabstop') s=string.rep(' ',ns)
	if C<2 then
		C=vim.fn.col({R-1,'$'}) V=virC({R-1,'$'})
		for i=R,r do
			ic= c +V_c -virC({i,c})
			ic= ic +V_c -virC({i,ic})
			l=vim.fn.getline(i)
			l=(string.gsub(string.sub( l,1,ic),'[\09]',s))..string.sub( l,ic+1)
			vim.fn.setline( i, string.sub( l,Vwd+2))
			e=virC( { i-1,'$'})
			d=V-e
			vim.fn.setline(i-1, vim.fn.getline(i-1)..(d>0 and string.rep(' ',d) or ''))
			iC= C +V -virC({ i-1, C})
			iC= iC +V -virC({ i-1, iC})
			A.nvim_buf_set_text(0, i-2, iC-1, i-2, iC-1, {string.sub( l,1,1+Vwd)})
		end
		Ac('normal! '..(R-1)..'G'..V..'|\022'..(r-1)..'G'..(V+Vwd)..'|')
	else
		for i=R,r do
			iC= C +V_C -virC({i,C}) iC=iC +V_C -virC({i,iC})
			ic= c +V_c -virC({i,c}) ic=ic +V_c -virC({i,ic})
			l=vim.fn.getline(i)
			l=string.sub( l,1,iC-1)..(string.gsub(string.sub( l,iC,ic),'[\09]',s))..string.sub( l,ic+1)
			if string.sub( l,iC-1,iC-1)=='\09' then
				l=string.sub( l,1,iC-2)..s..string.sub(l,iC) iC=iC+ns-1
			end
			vim.fn.setline( i,l)
			A.nvim_buf_set_text(0, i-1, iC-1, i-1, iC+Vwd, {})
			A.nvim_buf_set_text(0, i-1, iC-2, i-1, iC-2, {string.sub( l,iC,iC+Vwd)})
		end
		Ac('normal! '..R..'G'..(V_C-1)..'|\022'..r..'G'..(V_c-1)..'|')
	end
else
	c=math.min(c,vim.fn.col({r,'$'})-1)
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	A.nvim_buf_set_text(0, R-1, C-1, r-1, c, {})
	if C<2 then
		R=R-1 ;C=vim.fn.col({R,'$'}) r=r-1
		c=R==r and '$' or c
	else C=C-1 ;c=R==r and c-1 or c end
	A.nvim_buf_set_text(0, R-1, C-1, R-1, C-1, s)
	Ac('normal! '..R..'G'..virC({R,C})..'|v'..r..'G'..virC({r,c})..'|')
end vim.g.kmV_B=1
end
Akm('v', 'J', '<cmd>lua slLF()<CR>', {noremap=true,silent=true})
function slRG() -- Move visual char/block right
local VBlk, e,l,s,b, V_C,V_c, Vwd,t,V =vim.fn.mode()=='\022'
Ac('normal! \027')
local _,R,C = unpack(vim.fn.getpos("'<"))
local _,r,c = unpack(vim.fn.getpos("'>"))
V_C=virC({R,C})
V_c=virC({r,c})
if VBlk then
	if V_C>V_c then
		Vwd=V_C-V_c
		C= c+V_c-virC({R,c})
		V_C=virC({R,C})
		c=c+Vwd
		V_c=virC({r,c})
	else Vwd=V_c-V_C end
	ns=A.nvim_get_option('tabstop') s=string.rep(' ',ns)
	e= virC({R,'$'})
	if V_c == e-1 then
		for i=r,R,-1 do
			iC= C +V_C -virC({i,C})
			iC= iC +V_C -virC({i,iC})
			l=vim.fn.getline(i)
			vim.fn.setline( i,string.sub( l,1,iC-1)..string.sub( l,iC+Vwd+1))
			A.nvim_buf_set_text(0, i, 0, i, 0, {(string.gsub(string.sub( l,iC,iC+Vwd),'[\09]',s))})
		end
		Ac('normal! '..(R+1)..'G1|\022'..(r+1)..'G'..(1+Vwd)..'|')
	else
		for i=R,r do
			iC= C +V_C- virC({i,C})
			iC=iC +V_C -virC({i,iC})
			ic= c +V_c- virC({i,c})
			ic=ic +V_c -virC({i,ic})
			l=vim.fn.getline(i)
			l=string.sub( l,1,iC-1)..(string.gsub(string.sub( l,iC,ic),'[\09]',s))..string.sub( l,ic+1)
			if string.sub( l,ic+1,ic+1)=='\09' then
				l=string.sub( l,1,ic)..s..string.sub(l,ic+2)
			elseif V_c == virC({i,'$'})-1 then
				l=l..string.rep(' ',e-virC({i,'$'}))
			end
			vim.fn.setline( i,l)
			A.nvim_buf_set_text(0, i-1, iC-1, i-1, iC+Vwd, {})
			A.nvim_buf_set_text(0, i-1, iC, i-1, iC, {string.sub( l,iC,iC+Vwd)})
		end
		Ac('normal! '..R..'G'..(V_C+1)..'|\022'..r..'G'..(V_c+1)..'|')
	end
else
	c=math.min(c,vim.fn.col({r,'$'})-1)
	s=A.nvim_buf_get_text(0, R-1, C-1, r-1, c, {})
	A.nvim_buf_set_text(0, R-1, C-1, r-1, c, {})
	if C==vim.fn.col({R,'$'}) then
		C=0; R=R+1 ;r=r+1
		c=R==r and #s[1] or c
	elseif R==r then c=c+1 end
	A.nvim_buf_set_text(0, R-1, C, R-1, C, s)
	Ac('normal! '..R..'G'..virC({R,C+1})..'|v'..r..'G'..virC({r,c})..'|')
end
vim.g.kmV_B=1
end
Akm('v', 'L', '<cmd>lua slRG()<CR>', {noremap=true,silent=true})
-- Comment
Akm('v', 'c', '', {noremap=true})

Akm('n', '<Leader>1', '^vg_', {noremap=true})
Akm('n', '<Leader>2', ':n noname<CR>', {})
Akm('n', '<Leader>8', ':set listchars+=space:·,trail:·|set list! list?<CR>',{})
Akm('n', '<Leader>9', ':set hlsearch! hlsearch?<CR>',{})
Akm('n', '<Leader>z', '<C-w>w', {noremap=true}) --Switch buffers
O.mouse='a' -- Mouse support toggle
vim.keymap.set({'n','i','c'}, '<F9>', '', {callback=function()
 if O.mouse=='a' then
	vim.wo.number=false O.mouse= ''; print('System/Terminal Mouse')
 else vim.wo.number=true; O.mouse= 'a'; print('Neovim Mouse') end
end})
vim.keymap.set({'n','v','c'}, '<F6>','',{callback=function() -- Add # lines of CLI
	O.cmdheight = O.cmdheight<7 and O.cmdheight+1 or 1
end})
Akm('n', '<F2>',':lua vim.wo.number=not vim.wo.number<CR>', {noremap=true}) --Show/hide line#
-- Save, Exit
vim.keymap.set({'n','v','c'}, '<M-m>', ':call Sv_Ex()<CR>', {noremap=true,silent=true})
Akm('i', '<M-m>', '<C-o>:call Sv_Ex()<CR>', {noremap=true,silent=true})
Ac([[
function! Sv_Ex()
	if &modified |w
	elseif winnr('$')>1 |bd
	elseif len(getbufinfo({'buflisted':1})) >1 |bd |let bid=bufnr('%')
	else |q |endif
endfunction
function! SpB(U)
let w=winnr()
if winlayout()[0]=='col'
	if win_screenpos(w)[0] < win_screenpos(w+1)[0]
		exe "normal! \<C-w>".(a:U? '-': '+')
	else |exe "normal! \<C-w>".(a:U? '+': '-')
	endif
elseif winlayout()[0]=='row'
	if w==1 |exe "normal! \<C-w>".(a:U? '<': '>')
	else |exe "normal! \<C-w>".(a:U? '>': '<')
endif
endif
endfunction
nnoremap <expr> <C-Up> winnr('$')>1? ":call SpB(1)<CR>" :"<C-b>"
nnoremap <expr> <C-Down> winnr('$')>1? ":call SpB(0)<CR>" :'<C-f>'
nnoremap <expr> <C-Left> winnr('$')>1? ":call SpB(1)<CR>" :'<C-Left>'
nnoremap <expr> <C-Right> winnr('$')>1? ":call SpB(0)<CR>" :'<C-Right>'
nnoremap <silent> <Leader>3 :exe '%s/\v {'.&tabstop.'}/\t/g'\|%s/\v\s+$//<CR>
]])
--^ doc trailing-space cleanup
Akm('n', '<Leader>c', "<C-w>w:bd|bufdo if bufnr('%')!=bufnr() |bd|endif<CR>", {noremap=true,silent=true})
Akm('n', '<End>', ':bp<CR>', {noremap=true,silent=true}) --END switch to the next/previous buffer

function bg256co()
local B = A.nvim_create_buf(nil, 1)	-- new, unlisted, scratch/temporary buffer
local opts = {
	style = "minimal",
	relative = "editor",
	width = 37, height = 41,
	row = 1, col = 10
}
-- Generate it's content
local k, lines = 0, {}
for bg = 1, 255 do
 for fg = 0, 73 do
	if fg ~= bg then
	 k=k+1 lines[k] = string.format("###===### FG: %03d BG: %03d ###===###", fg, bg)
	end
 end
end
A.nvim_buf_set_lines(B, 0, -1, nil, lines)
local c, win = 0, A.nvim_open_win(B, 1, opts)
A.nvim_win_set_option(win, 'winhl', 'Normal:FloatingWindowBG')
Ac("highlight FloatingWindowBG ctermbg=0")
-- Define highlight groups, apply it
for bg = 1, 255 do
		for fg = 0, 73 do
				if fg ~= bg then
						local hl = string.format("FG%dBG%d", fg, bg)
						Ac(string.format("highlight %s ctermfg=%d ctermbg=%d", hl, fg, bg))
						A.nvim_buf_add_highlight(B, -1, hl, c, 0, -1)
						c = c+1
				end
		end
end print('Total',c)
end
Akm('n', '<F12>', '<cmd>lua bg256co()<CR>', {})
