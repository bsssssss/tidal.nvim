# Project notes

## Pattern highlighting

We receive osc messages from tidal that look like this:

```lua
{
  message = { "1", 869566, 0, 1, 1, 3, 1,
    address = "/editor/highlights",
    types = "sffiiii"
  },
  remote_info = {
    family = "inet",
    ip = "127.0.0.1",
    port = 63891
  },
  timestamp = 1755032239961
}
```

Where the first values in messages table are:

- pattern id
- delta time (in utc time ??)
- cycle position
- row start
- col start
- row end
- col end

### Pulsar tidal package

**The Complete Pattern Parsing System**

1. Block-level parsing (editors.js) treats the entire do block as one unit for
   evaluation

2. But pattern highlighting (event-highlighter.js) works differently:

- deltaContext injection: When a block is sent to Haskell, each quoted pattern
  gets wrapped with deltaContext
- Individual pattern tracking: Each quoted string becomes: (deltaContext
  ${offset} ${eventId} "${content}")
- eventId assignment: Every pattern gets a unique eventId for OSC highlighting
  messages

So for example:

```haskell
do
p 1 $ s "bd sd" -- eventId: 0
p 2 $ s "sd hh" -- eventId: 1
```

The system sends to Haskell:

```haskell
do
p 1 $ s (deltaContext 9 0 "bd sd")
p 2 $ s (deltaContext 9 1 "sd hh")
```

Then when TidalCycles plays events, it sends OSC messages back with the eventId,
allowing the editor to highlight the specific pattern that's currently playing.

### Lua implementation

-- 1. Block-level parsing (for evaluation)

```lua
function parseBlocks(text)
  return splitByEmptyLines(text)
end
```

-- 2. Pattern-level parsing (for highlighting)

```lua
function injectPatternIds(block)
  local eventId = 0
  local result = block:gsub(
    '"([^"]\*)"',
    function(content)
      local replacement = string.format('(deltaContext %d %d "%s")', pos, eventId, content)
      eventId = eventId + 1
      return replacement
    end
  )
  return result
end
```

### References

- [discussion initiated by Zalastax](https://codeberg.org/uzu/tidal/issues/1047)
- [pulsar plugin implementation](https://github.com/tidalcycles/pulsar-tidalcycles)

## Ghci interpreter

We should check if ghci is started. The challenge is that ghci stdout is chunked
seemingly randomly so we get things like 'ti' + 'dal>' !
