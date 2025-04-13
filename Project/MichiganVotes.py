import requests
from lxml import html


clean = lambda string: string.replace("\r\n", "").replace("\t", "")
clean_split = lambda string: string.strip("\t").strip("\r\n").replace("\t", "").split("\r\n") # preserve interior \r\n and split on them

def getLegislators(html_string):
    # Get all legislator data
    legislators_html = html.document_fromstring(html_string)
    legislators_els = legislators_html.xpath("//ul[@class='official-list']//a")

    legislators = []
    for legislator in legislators_els:
        name, info = clean_split(legislator.text_content())
        legislators.append({
            "name": name,
            "party": info[1],
            "district": info[3:-1],
            "href": legislator.get("href")
        })
    return legislators

# For all pages 1 - n
def getVotes(html_string):
    votes_html = html.document_fromstring(html_string)
    votes_els = votes_html.xpath("//div[@class='result']")

    votes = []
    for vote in votes_els:
        bill_el = vote.xpath(".//h3/a")[0]
        vote_els = [el.xpath("./li") for el in vote.xpath("./ul")]

        votes.append({
            "bill": {
                "name": bill_el.text_content(),
                "href": bill_el.get("href"),
                "description": vote.xpath(".//p")[0].text_content()
            },
            "votes": [{
                "vote": clean(vote_el.text_content()),
                "passed": clean_split(vote_info_el.xpath("./span[contains(@class, 'action')]")[0].text_content())[0] == "Passed",
                "date": clean(vote_info_el.xpath("./span[@class='date']")[0].text_content())[3:]
            } for vote_el, vote_info_el in vote_els]
        })
    return votes

def pageExists(html_string):
    page_html = html.document_fromstring(html_string)
    return len(page_html.xpath("//div[@class='site-section']/h1[text()='Page Not Found']")) == 0
