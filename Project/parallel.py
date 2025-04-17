import argparse
import json

import requests

from MichiganVotes import getLegislators, getVotes, pageExists
from PScraping import parallelPage, getProxies

parser = argparse.ArgumentParser()
parser.add_argument(
    "-n", "--nthreads",
    default=4,
    type=int,
    dest="nthreads",
    help="The number of threads to use for parallel components"
)
parser.add_argument(
    "-m", default=-1, type=int, help="The number of legislators to collect data for"
)
args = parser.parse_args()

base_url = "https://www.michiganvotes.org"

legislators_url = base_url + "/legislators/2025"
legislators_html = requests.get(legislators_url).content
legislators = getLegislators(legislators_html)
nleg = len(legislators)

for i, legislator in enumerate(legislators[:args.m]):
    vote_url = base_url + legislator["href"] + "/votes"
    legislator["votes"] = parallelPage(vote_url, getVotes, pageExists, nthreads=args.nthreads, proxies=getProxies)

with open("legislators.json", "w") as f:
    json.dump(legislators, f)
