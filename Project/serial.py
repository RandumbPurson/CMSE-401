import requests

from MichiganVotes import getLegislators, getVotes, pageExists
from PScraping import getLastPageNum

base_url = "https://www.michiganvotes.org"

legislators_url = base_url + "/legislators/2025"
legislators_html = requests.get(legislators_url).content
legislators = getLegislators(legislators_html)
nleg = len(legislators)

for i, legislator in enumerate(legislators):
    vote_url = base_url + legislator["href"] + "/votes"
    nvote_pages = getLastPageNum(vote_url, pageExists)
    votes = []
    for i in range(nvote_pages):
        votes_html = requests.get(base_url + f"?page={i + 1}").content
        votes.extend(getVotes(votes_html))
    legislator["votes"] = votes
