## lxml + requests

I used lxml and requests, both highly flexible python packages used for scraping.

- `requests` is a package that allows the user to easily make HTTP requests. It is incredibly popular for everything from testing websites to webscraping.


- `lxml` is a fast XML toolkit built on the C libraries `libxml2` and `libxslt`. It is extremely flexible, and is often used for scraping static websites due to its speed. In particular I utilize the `lxml.html` module, as it provides additional features for parsing malformed XML (which modern HTML often is) and HTML fragments.

## Installation

This project uses Anaconda for managing dependencies.

To install the appropriate packages on HPCC, please run the following commands

```bash
module purge
module load Miniforge3
conda env create -p ./env -f environment.yml
```

## Example Code

I created my own example code which uses lxml and requests to scrape voting data for Michigan Legislators from [Michigan Votes](https://www.michiganvotes.org/). To run it, first activate the conda environment, then run the submission script or python file as shown below

```bash
conda activate ./env
sbatch serial.sb; # OR python serial.py
```

## References
- Data scraped from https://www.michiganvotes.org/
