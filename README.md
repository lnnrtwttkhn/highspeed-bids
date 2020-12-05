# Highspeed BIDS

## Overview

This repository contains meta data of the DataLad dataset of the BIDS-converted MRI data used in Wittkuhn & Schuck, 2020, *Nature Communications*.

Please visit https://wittkuhn.mpib.berlin/highspeed/ for the project website and https://gin.g-node.org/lnnrtwttkhn/highspeed-bids to get the actual data.

## Usage

### Get data

```bash
$ datalad clone https://gin.g-node.org/lnnrtwttkhn/highspeed-bids
[INFO   ] Scanning for unlocked files (this may take some time) [INFO   ]
install(ok): highspeed-bids (dataset)
$ cd highspeed-bids
$ datalad get participants.tsv
get(ok): participants.tsv (file) [from origin...]
```

### Run code

Please install the required packages listed in [`requirements.txt`](requirements.txt):

```bash
pip install -r requirements.txt
```

## Contact

- [Lennart Wittkuhn](mailto:wittkuhn@mpib-berlin.mpg.de)
- [Nicolas W. Schuck](mailto:schuck@mpib-berlin.mpg.de)

## License

Please see the [LICENSE](LICENSE) file for details.
