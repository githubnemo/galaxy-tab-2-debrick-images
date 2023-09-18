Attempt to re-create the contents of the PARAM partition.

Based on `./GT-P5110_DBT_1/param.lfs`

## Tools

- [j4fs_extract](https://github.com/ius/j4fs_extract)

## Data extraction

    ../../tools/j4fs_extract/j4fs_extract.py param.lfs -p 2048 -b 131072
