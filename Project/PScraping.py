from multiprocessing.pool import Pool
import random

import requests

def getPage(url, pg, proxies=None):
    return requests.get(
        url + f"?page={pg}",
        {"http": random.choice(proxies)} if isinstance(proxies, list) else None
    ).content

def getLastPageNum(url, pageExists):
    page_last = None
    page_check = 1
    while pageExists(getPage(url, page_check)):
        page_last = page_check
        page_check = page_check * 2
    if page_last is None:
        raise ValueError(f"Page 1 does not exist! URL {url} is not pageable or invalid")
        
    while True: # do-while loop
        page_diff = page_check - page_last
        if page_diff == 1: # END do-while
            return page_last
        if pageExists(getPage(url, page_check)):
            page_last = page_check
            page_check = page_check + (page_diff // 2)
        else:
            page_check = page_check - (page_diff // 2)

def parallelPage(url, scrapeFn, pageExistsFn, nthreads=4, proxies=None, combine=True):
    npages = getLastPageNum(url, pageExistsFn)
    with Pool(nthreads) as p:
        html_pages = p.starmap(getPage, [(url, i+1, proxies) for i in range(npages)])
        data = p.map(scrapeFn, html_pages)
    if combine:
        combined = []
        for d in data:
            combined.extend(d)
        return combined
    else:
        return data

def getProxies():
    proxies = requests.get("https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/countries/US/data.txt").content.decode("UTF-8").split("\n")
    http_proxies = list(filter(lambda proxy: proxy[:4] == "http", proxies))
    return http_proxies
