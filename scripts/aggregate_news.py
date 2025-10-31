#!/usr/bin/env python3
import json, re, os, html, requests, feedparser
from datetime import datetime, timezone
from urllib.parse import urlparse

FEEDS = [
    "https://www.quantamagazine.org/feed/",
    "https://www.ams.org/journals/notices/notices.rss",
    "https://www.scottaaronson.com/blog/?feed=rss2",
    # adicione mais fontes aqui (RSS de arXiv categorias, Nature news, etc.)
]
MAX_PER_FEED = 5
MAX_ITEMS_TOTAL = 25
SUMMARY_SENTENCES = 4
TIMEOUT = 12
OUT_PATH = "news/news.json"

def strip_html(s: str) -> str:
    if not s: return ""
    s = re.sub(r"(?is)<script.*?</script>", " ", s)
    s = re.sub(r"(?is)<style.*?</style>", " ", s)
    s = re.sub(r"(?i)<br\s*/?>", ". ", s)
    s = re.sub(r"(?is)<[^>]+>", " ", s)
    s = html.unescape(s)
    return re.sub(r"\s+", " ", s).strip()

def http_get(url: str):
    return requests.get(url, headers={"User-Agent":"GH-Pages-NewsBot/1.0"}, timeout=TIMEOUT)

def fetch_article_text(url: str) -> str:
    try:
        r = http_get(url)
        if r.status_code >= 400: return ""
        t = r.text
        m = re.search(r"(?is)<article[^>]*>(.*?)</article>", t)
        body = m.group(1) if m else (re.search(r"(?is)<body[^>]*>(.*?)</body>", t) or [None, t])[1]
        text = strip_html(body)
        return text[:10000]
    except Exception:
        return ""

STOP = set("the a an to of and or in on for with is are at as by from that this it be was were de da do em para com que um uma os as no na".split())
def sents(text: str): 
    xs = re.findall(r"[^.!?]+[.!?]+", text)
    return [x.strip() for x in xs] or [text.strip()]
def summarize(text: str, k: int) -> str:
    text = re.sub(r"\s+", " ", text).strip()
    if not text: return ""
    S = sents(text)
    if len(S) <= k: return " ".join(S)
    def toks(s): return [t for t in re.sub(r"[^0-9A-Za-zÀ-ÖØ-öø-ÿ\- ]"," ",s.lower()).split() if t and t not in STOP]
    freq, Tok = {}, [toks(s) for s in S]
    for ts in Tok:
        for t in ts: freq[t] = freq.get(t,0)+1
    scores = [sum(freq.get(t,0) for t in ts) for ts in Tok]
    idx = sorted(sorted(range(len(scores)), key=lambda i: -scores[i])[:k])
    return " ".join(S[i] for i in idx)

def translate_pt(text: str) -> str:
    if not text: return ""
    try:
        import argostranslate.package, argostranslate.translate
        installed = argostranslate.translate.get_installed_languages()
        have = {l.code for l in installed}
        if not ({"en","pt"} <= have):
            pkgs = argostranslate.package.get_available_packages()
            pkg = next(p for p in pkgs if p.from_code=="en" and p.to_code=="pt")
            path = argostranslate.package.download_package(pkg.download_url)
            argostranslate.package.install_from_path(path)
        return argostranslate.translate.translate(text, "en", "pt")
    except Exception:
        return text

def norm_date(s: str) -> str:
    try:
        d = feedparser._parse_date(s)
        if not d: raise ValueError
        from datetime import datetime, timezone
        return datetime(*d[:6], tzinfo=timezone.utc).isoformat()
    except Exception:
        return datetime.now(timezone.utc).isoformat()

def host(u: str) -> str:
    try: return urlparse(u).hostname or ""
    except Exception: return ""

def main():
    items = []
    for feed in FEEDS:
        f = feedparser.parse(feed)
        for e in f.entries[:MAX_PER_FEED]:
            title = e.get("title","").strip()
            link  = e.get("link","").strip()
            desc  = strip_html(e.get("summary","") or e.get("description",""))
            pub   = e.get("published") or e.get("updated") or ""
            full  = fetch_article_text(link) if link else ""
            base  = full if full and len(full)>500 else desc
            brief_en = summarize(base, SUMMARY_SENTENCES) or "No summary available."
            brief_pt = translate_pt(brief_en)
            items.append({
                "title": title or "(untitled)",
                "url": link, "host": host(link), "source": feed,
                "published_at": norm_date(pub),
                "brief_en": brief_en[:1500], "brief_pt": brief_pt[:1500]
            })
    seen, out = set(), []
    for it in sorted(items, key=lambda x: x["published_at"], reverse=True):
        if it["url"] and it["url"] not in seen:
            seen.add(it["url"]); out.append(it)
    out = out[:MAX_ITEMS_TOTAL]
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    from datetime import datetime, timezone
    data = {"updated_at": datetime.now(timezone.utc).isoformat(), "items": out}
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    main()
