# Notes

## `x-man-page://`

The `x-man-page://` URL scheme that the native man page search uses only searches paths in `/etc/man.conf`, so be sure your man pages can be found by appending _e.g._ the following:

```
MANPATH /Library/TeX/texbin/man
```

If you don't know where a command's man page is stored, run `man -w {command}`, _e.g._ `man -w brew`, which returns the following:

```
/opt/homebrew/share/man/man1/brew.1
```

`/etc/man.conf` only needs the path up to `/man`, so to make `brew`'s man page visible, append the following:

```
MANPATH /opt/homebrew/share/man
```

Also note that **macOS upgrades tend to wipe `/etc/man.conf`**, so you'll either have to automate this or do it every time.
