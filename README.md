# TablePaste for OS X

TablePaste lets you copy tab delimited data to the clipboard and paste it as a styled HTML table.

---

WHY?  I use [DBeaver](dbeaver.jkiss.org) to bounce queries off various types of databases.  DBeaver's query results grid has an option to select and copy the results as tab delimited data with column headers.  I often need to paste data into emails for clients and co-workers to review, but for years my only option was to use Excel as a copy/paste-copy/paste go-between.  That mostly worked but required an extra step, and I didn't always end up with a cleanly formatted table without even more effort... thus TablePaste.

When the TablePaste `SHIFT`+`ALT`+`CMD`+`T` hotkey is pressed, it takes tab delimited data from the clipboard, replaces it with a styled HTML table, then performs the paste operation.

At some point I'd like to throw in a few more features, but it has worked as-is for so long I've just never got around to it.  It's an old slapped together utility, so don't expect academically architected code purity.

---

## Installation

Place `TablePaste.app` in the `/Applications` folder and double click to run it.  A grid icon will be added to the top menu bar.  Click the icon to close the app.

---

## Credits

TablePaste uses [JFHotkeyManager](https://github.com/jaz303/JFHotkeyManager) to handle registering the global hotkey.