# noqsi-lepton-addons
A collection of add-on scripts for Lepton EDA
### Pincount Tables
Pincount table files are named **pincount.tsv**. The pincount code searches for them in the system data directories, the user data directories, and finally in the working directory. 

Blank lines and lines beginning with **#** are ignored. All other lines consist of two fields separated by a TAB character.

The first field is the *prefix*. The second field is the *pincount*. If the prefix matches the start of the footprint name, the component is assumed to have the given pincount. If there is more than one match, longer prefix matches override shorter ones, and prefixes seen later in the scan of **pincount.tsv** files overide earlier ones of the same length. Thus, the **pincount.tsv** file in the working directory has the greatest authority.

A pincount of **\*** indicates that the actual pincount is the numeric suffix of the footprint name.

####Example pincount.tsv File
Here, `→` represents the TAB character.

```
SOT→3
SOT89→4
DIP→*
```
This means that **SOT** footprints like **SOT23** generally have 3 pins, but **SOT89** is an exception with 4. **DIP14** has 14 pins.

## Modules
### (noqsi tsv)
This module exports a single function. `(tsv-data name)` appends the suffix ".tsv" to the string `name` and searches for files that match. It first searches `sys-data-dirs`, followed by `user-data-dir` and the working directory. It returns a list of parsed lines. Each parsed line is a list of character strings representing the TAB character delimited fields in the line.

Blank lines and lines starting with **#** are ignored. The lines appear in the output list in the order in which they are read, so if there's a file that matches the name in the working directory, its last line is represented by the last element in the output list.