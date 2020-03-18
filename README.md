# noqsi-lepton-addons
A collection of add-on scripts for Lepton EDA.
## Netlist Back Ends
### check-duplicates
Usage: `lepton-netlist -g check-duplicates ...`

Checks schematics for separate connections with duplicated (refdes pinnumber) pairs. These usually result from unintentional refdes or slot duplication.

It logs any duplicates to the standard error output. It exits with a code of zero if it finds no duplicates, or one if duplicates were found.
### check-pincount
Usage: `lepton-netlist -g check-pincount ...`

Checks that the number of connections to each package matches the expected number. Mismatches usually indicate missing connections, slot assignment errors, or missing symbols for portions of composite components.

When checking a package, it first checks for a numeric `pins-used` attribute. If that's not present, it checks for a `pins` attribute. Finally, if neither of the attributes is present, it tries to match the footprint to an entry in the available pincount tables. It is an error if none of these yields an expected number.

It compares the expected connection count with the actual count. Any mismatch is an error. It logs errors to the standard error output. It exits with a code of zero if it finds no errors, or one if errors were found. 
## File Formats
### Pincount Tables
Pincount table files are named **pincounts.tsv**. The pincount code searches for them in the system data directories, the user data directories, and finally in the working directory. 

Blank lines and lines beginning with **#** are ignored. All other lines consist of two fields separated by a TAB character.

The first field is the *prefix*. The second field is the *pincount*. If the prefix matches the start of the footprint name, the component is assumed to have the given pincount. If there is more than one match, longer prefix matches override shorter ones, and prefixes seen later in the scan of **pincounts.tsv** files overide earlier ones of the same length. Thus, the **pincounts.tsv** file in the working directory has the greatest authority.

A pincount of **\*** indicates that the actual pincount is the numeric suffix of the footprint name.

####Example pincounts.tsv File
Here, `→` represents the TAB character.

```
SOT→3
SOT89→4
DIP→*
```
This means that **SOT** footprints like **SOT23** generally have 3 pins, but **SOT89** is an exception with 4. **DIP14** has 14 pins.

## Modules
### (noqsi pincount)
This module exports four functions. 

`(get-package-pincount p)`, given package refdes `p`, yields an integer count of the number of pins on the package. If the package has an attached `pins=` attribute with a numeric value, that value is returned. Otherwise, the function attempts to match the fooprint attached to the package to a prefix in the **pincounts.tsv** files (see above) to obtain a count. If that also fails, it counts net connections to the package.

`(pins-from-footprint f)` attempts to match the fooprint `f` to a prefix in the **pincounts.tsv** files. It returns the pincount on success, `#f` on failure.

`(enter-pincount-for-footprint entry)` allows for additional footprint prefixes beyond those in the **pincounts.tsv** files. Prefixes added this way will have precedence over prefixes of the same length or shorter from the files. `entry` should be a two element list of the form `(prefix count)` where both elements are character strings. `count` may `*`, or it may represent a positive decimal integer.

`(get-numeric-attribute refdes name)` yields the numeric value of attribute `name` attached to package `refdes`. If the attribute doesn't exist, it yields `#f`. If the attribute isn't numeric, it yields `%f` and displays a warning on the standard error output.
### (noqsi tsv)
This module exports a single function. `(tsv-data name)` appends the suffix ".tsv" to the string `name` and searches for files that match. It first searches `sys-data-dirs`, followed by `user-data-dir` and the working directory. It returns a list of parsed lines. Each parsed line is a list of character strings representing the TAB character delimited fields in the line.

Blank lines and lines starting with **#** are ignored. The lines appear in the output list in the order in which they are read, so if there's a file that matches the name in the working directory, its last line is represented by the last element in the output list.