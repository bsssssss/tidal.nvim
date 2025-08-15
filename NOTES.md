# Project notes

## Pattern highlighting

We receive osc messages from tidal's `OSCContext` stream that look like this

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

Where the values in messages table are:

- pattern id
- delta time (in utc time ??)
- cycle position
- row start
- col start
- row end
- col end

Tidal has a the `deltaContext c r p` function that takes a column-start index
`c`, a row index `r` and a mini-notation string `p`. This function allows tidal
to know where the mini-notation pattern is in the editor.

So for example, in this expression

```haskell
do
p 1 $ s "bd sd" -- eventId: 0
p 2 $ s "sd hh" -- eventId: 1
```

we inject `deltaContext`

```haskell
do
p 1 $ s (deltaContext 9 1 "bd sd")
p 2 $ s (deltaContext 9 2 "sd hh")
```

So when we receive osc messages back, we have the correct position for each
playing patterns.

### Implementation

hnnnnnnn

### References

- [discussion initiated by Zalastax](https://codeberg.org/uzu/tidal/issues/1047)
- [pulsar plugin implementation](https://github.com/tidalcycles/pulsar-tidalcycles)

## Ghci interpreter

We should check if ghci is started. The challenge is that ghci stdout is chunked
seemingly randomly so we get things like 'ti' + 'dal>' !
