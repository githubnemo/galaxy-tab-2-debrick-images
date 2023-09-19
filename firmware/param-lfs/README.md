Attempt to re-create the contents of the PARAM partition.

Based on `../GT-P5110_DBT_1/param.lfs`

## Usage

If all prerequisites are installed, simply run

	./create_param.sh

to create a new `param.j4fs` file.

## Prerequisites

- `../../tools/j4fs` based on [j4fs_extract](https://github.com/ius/j4fs_extract)
- ImageMagick for fake image createion to avoid licensing issues

## Data extraction

    ../../tools/j4fs/j4fs.py extract param.lfs -p 2048 -b 131072

## Data inspection

	../../tools/j4fs/j4fs.py dump param.lfs -p 2048 -b 131072
