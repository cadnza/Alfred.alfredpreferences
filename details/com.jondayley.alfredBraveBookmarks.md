# About

Opens bookmarks from the Brave Browser. It's built to mimic the functionality of the Brave Bookmarks feature, so expect about the same interface with a few concessions.

## Indexing

When using Brave Bookmarks, it's good to keep in mind that it works *from an index*. As it turns out, querying Brave's bookmarks is a rather slow process, especially where we want paths to each bookmark. So when you use the thing for the first time, it will generate an index. This takes anywhere from a couple of seconds to a couple of minutes, depending on your hardware and how many Brave bookmarks you have. **You can leave Alfred while the index is being built.** The process takes place in the background (through `screen` if you're curious), so it won't notice if you come and go while it's building.

When you call Brave Bookmarks (*i.e.* whenever you type `bk` into Alfred), it checks the age of the index. If the index is more than a minute old *and the index isn't already being rebuilt,* it rebuilds the index. This takes just as long as it did the first time, but it happens completely in the background, so you won't notice a thing. And note that while the reindexing process does take time, it's very soft on your processor; you shouldn't notice any kind of performance hit from reindexing.

If you'd like, you can change the default reindexing interval by creating a Workflow Environment Variable called `dbMaxAgeMinutes` and assigning it an integer greater than 0. Instead of rebuilding the index if it's more than a minute old, Brave Bookmarks will rebuild it if it's more than `dbMaxAgeMinutes` minutes old.

## Profiles

By default, Brave Bookmarks only shows bookmarks from the last used Brave profile, so expect bookmarks from the last Brave profile in your user account to display an active browser window. That said, there appears to be a bit of lag on Brave's side between switching profiles and recording the profile switch, so you may have to be patient.

If you'd rather display all bookmarks from all profiles, create a Workflow Environment Variable called `showAllProfiles` and assign it `1`.

## `jq`

`jq` is essential to Brave Bookmarks for parsing Brave's JSON, and unfortunately, it's not included in macOS. So if `which zsh` isn't `/bin/zsh` and you *don't* have `jq` installed through Homebrew, you *may* have a bit of trouble getting Brave Bookmarks to find your `jq` executable. The main issue here is a discrepancy between your opinion on what `$PATH` should look like and Alfred's. I've done my best to control for that and make finding `jq` as seamless as possible--no one likes fighting with dependencies--but there's only so much that can be done. If Brave Bookmarks keeps telling you you're missing `jq` even though you're sure you have it installed, let me know and we'll see what we can do.

Anyway, happy bookmarking!

# Dependencies

(Don't worry; the workflow will let you know if you're missing dependencies.)

- Brave Browser
- jq

# Versions

## v1.0.0

- First release
