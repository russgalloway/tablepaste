# TablePaste for OS X

---

© 2011 Russ Galloway

Released under the MIT License.

TablePaste lets you copy comma delimited data to the clipboard and paste it as a styled HTML table.

WHY?  I use DbVisualizer to query various database flavors daily.  DbVisualizer's query results grid has the option to select and copy the results as tab delimited data with column headers.   I would often want to paste that data in an email, but the only way I was aware of to get that tab delimited data in a formatted table was to paste it to Excel, copy it again then paste it in the email.  At the time I could only run Excel by running it in my Windows virtual machine, so it was very inconvenient.

When the TablePaste paste hotkey is pressed, it takes tab delimited data from the clipboard, replaces it with a styled HTML table, then performs the paste operation.

---

## Installation and Running TablePaste

Place `TablePaste.app` in the `/Applications` folder and double click to run it.

Copy tab delimited data, such as:

FistName  LastName  Age
FName1  LName1  20
FName2  LName2  30
FName3  LName3  40

Press SHIFT+ALT+CMD+T to paste it as a styled HTML table, which looks like:

...