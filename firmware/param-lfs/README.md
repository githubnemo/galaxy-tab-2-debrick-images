Attempt to re-create the contents of the PARAM partition.

Based on `../GT-P5110_DBT_1/param.lfs`

## Tools

- `../../tools/j4fs` based on [j4fs_extract](https://github.com/ius/j4fs_extract)
- ImageMagick for fake image createion to avoid licensing issues

## Data extraction

    ../../tools/j4fs/j4fs.py extract param.lfs -p 2048 -b 131072
