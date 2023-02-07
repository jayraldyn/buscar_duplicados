# buscar_duplicados
Super fast search to detect duplicate files with bash

## Requirements

The script will use **mktemp**, **md5sum**, **find**, **uniq** and **sort**. Make sure they are installed in your system.

## Usage

You'll simply have to run by typing:

```
<PATH>/buscar-duplicados <DIR TO SEARCH DUPLICATES>
```

Keep in mind that the script will ignore files less than 50k (I use it to detect photo duplicates)
