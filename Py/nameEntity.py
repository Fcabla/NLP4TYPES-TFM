import requests
import json

TEST_TEXT = "In Greek mythology, Queen Endeïs /ɛnˈdiːᵻs/ was the wife of King Aeacus and mother of Telamon and King Peleus. (As Peleus was the father of Achilles, Endeïs was Achilles's grandmother.) The name is a dialect variant of Engaios (Ἐγγαίος, \in"

def get_dbspotlight_ne(raw_text):
    # MORE PARAMETTERS???
    headers = {'content-type': 'application/text'}
    payload = {'text': raw_text}
    r = requests.get("https://api.dbpedia-spotlight.org/en/annotate", params=payload, headers=headers)
    print(r)
    if r.status_code == 200:
        print(r.json)

if __name__ == "__main__":
    get_dbspotlight_ne(TEST_TEXT)