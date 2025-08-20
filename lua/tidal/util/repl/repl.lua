local Buffer = require("tidal.util.buffer")

---@class Repl
---@field buf Buffer
---@field proc? integer
---@field opts ReplOpts
local Repl = {}
Repl.__index = Repl

---@class ReplOpts
---@field cmd string
---@field args? table<string> additional arguments to for GHCi
---@field name? string repl buffer name
---@field on_exit fun(code: number, signal: number)?

--- Create a new REPL
--- @generic T - generic type for type inference on child 'classes'
--- @param self T
--- @param opts? ReplOpts
--- @return T for method chaining
function Repl:new(opts)
  opts = opts or {}
  local obj = {}
  setmetatable(obj, self)
  obj.buf = Buffer.new({
    name = opts.name,
    scratch = true,
    listed = false,
  })
  obj.opts = opts

  return obj
end

local uv, api, fn = vim.loop, vim.api, vim.fn
local M, proc, stdin = {}, nil, nil

local function attach(pipe, label, buf)
  local buf_acc = ""
  pipe:read_start(function(err, data)
    if err then
      vim.schedule(function()
        vim.notify(("[tidal-fast] %s error: %s"):format(label, err), vim.log.levels.ERROR)
      end)
      return
    end
    if not data then
      return
    end

    vim.schedule(function()
      buf_acc = buf_acc .. data
      local lines = vim.split(buf_acc, "\n", { plain = true })
      local complete, remainder = {}, ""

      if buf_acc:sub(-1) == "\n" then
        complete, buf_acc = lines, ""
      else
        remainder = table.remove(lines)
        complete, buf_acc = lines, remainder
      end

      for _, line in ipairs(complete) do
        buf:append(line .. "\n")
      end
    end)
  end)
end

--- Start the REPL
--- @param opts table|nil Window options
---  - split: string|nil - Split type ('', 'v', 'h')
---  - win: number|nil - Window to use (default: current window)
--- @generic T
--- @return T for method chaining
function Repl:start(opts)
  if proc and proc:is_active() then
    return vim.notify("[tidal-fast] already running", vim.log.levels.INFO)
  end

  stdin = uv.new_pipe(false)
  local stdout, stderr = uv.new_pipe(false), uv.new_pipe(false)

  proc = uv.spawn(self.opts.cmd, { args = self.opts.args, stdio = { stdin, stdout, stderr } }, function(code, signal)
    for _, p in ipairs({ stdin, stdout, stderr }) do
      if p and not p:is_closing() then
        p:close()
      end
    end
    proc = nil
    vim.schedule(function()
      vim.notify(("[tidal-fast] ghci exited (code=%d, signal=%d)"):format(code, signal), vim.log.levels.WARN)
    end)
  end)

  if not proc then
    return vim.notify("[tidal-fast] failed to spawn ghci", vim.log.levels.ERROR)
  end

  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(buf, "tidal-fast://ghci")

  self.buf:show(opts or {})

  self.buf:set_option("filetype", "haskell")

  attach(stdout, "stdout", self.buf)
  attach(stderr, "stderr", self.buf)

  vim.notify("[tidal-fast] ghci started (pipe mode): " .. self.opts.cmd, vim.log.levels.INFO)

  -- if self.proc == nil then
  --   self.buf:show(opts or {})
  --   self.proc = vim.fn.jobstart(vim.list_extend({ self.opts.cmd }, self.opts.args or {}), {
  --     term = true,
  --     on_exit = function(code, signal)
  --       self.buf:delete()
  --       if self.opts.on_exit then
  --         self.opts.on_exit(code, signal)
  --       end
  --     end,
  --   })
  -- end
  return self
end

--- Send text to REPL
--- @generic T
--- @return T for method chaining
function Repl:send(text)
  if stdin and not stdin:is_closing() then
    stdin:write(text)
  end

  if self.proc == nil then
    -- not running - error?
    return self
  end

  --vim.api.nvim_chan_send(self.proc, text)
  --self.buf:scroll_to_bottom()
  return self
end

--- Send line of text to REPL
---@param text string
--- @generic T
--- @return T for method chaining
function Repl:send_line(text)
  return self:send(text .. "\n")
end

--- Send multi-line text to REPL
--- @param lines string[]
--- @generic T
--- @return T for method chaining
function Repl:send_multiline(lines)
  return self:send_line(table.concat(lines, "\n"))
end

--- Close the REPL
--- @return self for method chaining
function Repl:exit()
  if self.proc then
    -- Removes buffers and closes windows
    vim.fn.jobstop(self.proc)
  end
  return self
end

return Repl
