" ============================================================================
" File:        tracker.vim
" Description: Tracker plugin for vim.
" Maintainer:  Edgar Fisher <fisher.edgar@gmail.com>
" License:     BSD, see LICENSE.txt for more details.
" Website:     http://tracker.edgarfisher.com
" ============================================================================

let s:VERSION = '0.1.0'



if v:version < 700
  echoerr "Tracker: Vim 7 required"
  finish
endif

" Only load plugin once
if exists("g:tracker_loaded")
  finish
endif
let g:tracker_loaded = 1


let s:plugin_root = expand("<sfile>:p:h") . '/..'
let s:cli_dir = s:plugin_root . '/tracker_cli'

if has('win32') || has('win64')
  let s:cli = fnameescape(s:cli_dir . '/win32/tracker.bat')
elseif has('mac')
  let s:cli = fnameescape(s:cli_dir . '/mac/tracker')
else
  let s:cli = fnameescape(s:cli_dir . '/linux-x86_64/tracker')
endif

let s:config_file = expand("$HOME/tracker.conf")
let s:config_file_already_setup = 0
let s:local_cache_expire = 10
let s:last_heartbeat = [0, 0, '']


" Default heartbeat frequency in minutes
if !exists("g:tracker_heartbeat_delay")
  let g:tracker_heartbeat_delay = 2
endif


" Functions
function! s:SetupConfFile()
  if !s:config_file_already_setup

    " Create config file if does not exist
    if !filereadable(s:config_file)
      let key = input("[Tracker] Enter your tracker api key: ")
      if key != ''
        call writefile([printf("api_key=%s", key)], s:config_file)
        echo "[Tracker] Setup complete!"
      endif

      " Make sure config file has api_key
    else
      let found_api_key = 0
      let lines = readfile(s:config_file)
      for line in lines
        let group = split(line, '=')
        if len(group) == 2 && s:Strip(group[0]) == 'api_key' && s:Strip(group[1]) != ''
          let found_api_key = 1
        endif
      endfor
      if !found_api_key
        let key = input("[Tracker] Enter your tracker api key: ")
        let lines = lines + [join(['api_key', key], '=')]
        call writefile(lines, s:config_file)
        echo "[Tracker] Setup complete!"
      endif
    endif

    let s:config_file_already_setup = 1
  endif
endfunction

function! s:Strip(str)
  return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! s:GetCurrentFile()
  return expand("%:p")
endfunction

function! s:EscapeArg(arg)
  return substitute(shellescape(a:arg), '!', '\\!', '')
endfunction

function! s:JoinArgs(args)
  let safeArgs = []
  for arg in a:args
    let safeArgs = safeArgs + [s:EscapeArg(arg)]
  endfor
  return join(safeArgs, ' ')
endfunction

function! s:SendHeartbeat(file, time, is_write, last)
  let file = a:file
  if file == ''
    let file = a:last[2]
  endif

  if file != ''
    let cmd = [s:cli]

    let cmd = cmd + ['--file', file]
    let cmd = cmd + ['--plugin', printf('vim v%d vim-tracker v%s', v:version, s:VERSION)]

    if a:is_write
      let cmd = cmd + ['--write']
    endif

    if has('win32') || has('win64')
      exec 'silent !start /min cmd /c "' . s:JoinArgs(cmd) . '"'
    else
      exec 'silent ! ' . s:JoinArgs(cmd) . ' &'
    endif

    call s:SetLastHeartbeat(a:time, a:time, file)
  endif
endfunction

function! s:SetLastHeartbeatLocally(time, last_update, file)
  let s:last_heartbeat = [a:time, a:last_update, a:file]
endfunction

function! s:SetLastHeartbeat(time, last_update, file)
  call s:SetLastHeartbeatLocally(a:time, a:last_update, a:file)
endfunction

function! s:EnoughTimePassed(now, last)
  let prev = a:last[1]
  if a:now - prev > g:tracker_heartbeat_delay * 60
    return 1
  endif
  return 0
endfunction

" Events
function! s:handleActivity(is_write)
  call s:SetupConfFile()
  let file = s:GetCurrentFile()
  let now = localtime()
  let last = s:last_heartbeat
  if !empty(file) && file !~ "-MiniBufExplorer-" && file !~ "--NO NAME--" && file !~ "^term:"
    if a:is_write || s:EnoughTimePassed(now, last) || file != last[2]
      call s:SendHeartbeat(file, now, a:is_write, last)
    else
      if now - s:last_heartbeat[0] > s:local_cache_expire
        call s:SetLastHeartbeatLocally(now, last[1], last[2])
      endif
    endif
  endif
endfunction

augroup Tracker
  autocmd!
  autocmd BufEnter * call s:handleActivity(0)
  autocmd VimEnter * call s:handleActivity(0)
  autocmd BufWritePost * call s:handleActivity(1)
  autocmd CursorMoved,CursorMovedI * call s:handleActivity(0)
augroup END
