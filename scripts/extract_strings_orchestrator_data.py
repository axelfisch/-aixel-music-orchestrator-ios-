#!/usr/bin/env python3
import re
import json
import sys
from pathlib import Path
import requests
import json5  # JSON5 can parse JS-like objects (unquoted keys, etc.)

JS_URL = "https://stellar-travesseiro-4619b2.netlify.app/assets/index-BRuWnI_Q.js"
OUT_DIR = Path("/workspace/AiXelMusicOrchestrator/Resources")

# Conservative JS object extraction using regex and brace matching
PATTERNS = {
    "Um": re.compile(r"\bUm\s*=\s*\{"),
    "Ln": re.compile(r"\bLn\s*=\s*\{"),
    "jm": re.compile(r"\bjm\s*=\s*\{"),
}


def download_js(url: str) -> str:
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    return resp.text


def extract_object(js: str, name: str) -> str:
    m = PATTERNS[name].search(js)
    if not m:
        raise ValueError(f"{name} not found")
    # move to first '{'
    brace_pos = js.find('{', m.start())
    if brace_pos == -1:
        raise ValueError(f"Opening brace not found for {name}")
    start = brace_pos
    depth = 0
    i = start
    in_str = False
    esc = False
    quote_char = ''
    while i < len(js):
        ch = js[i]
        if in_str:
            if not esc and ch == quote_char:
                in_str = False
                quote_char = ''
            esc = (ch == '\\' and not esc)
        else:
            if ch in ('"', "'"):
                in_str = True
                quote_char = ch
            elif ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    # include closing brace
                    return js[start:i+1]
        i += 1
    raise ValueError(f"Unterminated object for {name}")


def parse_js_object(js_obj_src: str) -> dict:
    # Use JSON5 to parse JS-like object
    return json5.loads(js_obj_src)


def main():
    js = download_js(JS_URL)
    results = {}
    for name in ("Um", "Ln", "jm"):
        src = extract_object(js, name)
        obj = parse_js_object(src)
        results[name] = obj

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "strings_chords.json").write_text(json.dumps(results["Um"], ensure_ascii=False, indent=2))
    (OUT_DIR / "strings_styles.json").write_text(json.dumps(results["Ln"], ensure_ascii=False, indent=2))
    (OUT_DIR / "strings_instruments.json").write_text(json.dumps(results["jm"], ensure_ascii=False, indent=2))

    print("Wrote:")
    for fn in ["strings_chords.json", "strings_styles.json", "strings_instruments.json"]:
        p = OUT_DIR / fn
        print(f"- {p} ({p.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
