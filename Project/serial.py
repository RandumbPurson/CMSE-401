import argparse
import json

import requests
from fake_useragent import UserAgent

from MichiganVotes import getLegislators, getVotes, pageExists
from PScraping import getLastPageNum

parser = argparse.ArgumentParser()
parser.add_argument(
    "-m", default=-1, type=int, help="The number of legislators to collect data for"
)
args = parser.parse_args()

base_url = "https://www.michiganvotes.org"

legislators_url = base_url + "/legislators/2025"
legislators_html = requests.get(legislators_url).content
legislators = getLegislators(legislators_html)[:args.m]
nleg = len(legislators)

for i, legislator in enumerate(legislators):
    vote_url = base_url + legislator["href"] + "/votes"
    nvote_pages = getLastPageNum(vote_url, pageExists)
    votes = []
    for i in range(nvote_pages):
        votes_html = requests.get(vote_url + f"?page={i + 1}", headers={"useragent": UserAgent().random}).content
        votes.extend(getVotes(votes_html))
    legislator["votes"] = votes

with open("legislators.json", "w") as f:
    json.dump(legislators, f)
