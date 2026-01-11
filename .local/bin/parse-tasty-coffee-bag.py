#!/usr/bin/env python3

import argparse
import sys
import urllib.request
from html.parser import HTMLParser
from typing import Dict, Optional

import yaml


class CoffeeData:
    def __init__(self):
        self.title: str = ""
        self.id: str = ""
        self.attributes: Dict[str, str] = {}

    def to_dict(self) -> dict:
        return {
            "coffee_name": self.title,
            self.attributes.pop(
                "Цифровой идентификатор упаковки кофе", "package_id"
            ): self.id,
            "roasting_details": {k: v for k, v in self.attributes.items()},
        }


class TastyCoffeeHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.data = CoffeeData()
        self.current_tag: Optional[str] = None
        self.capture_next: bool = False
        self.temp_label: Optional[str] = None

        # Flags for specific sections
        self.in_title = False
        self.in_id = False
        self.in_info_element = False

    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        html_cls: str = attrs_dict.get("class") or ""

        if tag == "h1" and "roasting-description__title" in html_cls:
            self.in_title = True
        elif tag == "span" and "roasting-description__id-number" in html_cls:
            self.in_id = True
        elif tag == "div" and "roasting-info-element__content" in html_cls:
            self.in_info_element = True

    def handle_data(self, data):
        clean_data = data.strip()
        if not clean_data:
            return

        if self.in_title:
            self.data.title = clean_data
        elif self.in_id:
            self.data.id = clean_data
        elif self.in_info_element:
            if not self.temp_label:
                self.temp_label = clean_data
            else:
                self.data.attributes[self.temp_label] = clean_data
                self.temp_label = None

    def handle_endtag(self, tag):
        if tag == "h1":
            self.in_title = False
        if tag == "span":
            self.in_id = False
        if tag == "div":
            self.in_info_element = False


class ScraperService:
    def __init__(self, url: str):
        self.url = url

    def fetch_html(self) -> str:
        req = urllib.request.Request(self.url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as response:
            return response.read().decode("utf-8")

    def parse(self, html: str) -> CoffeeData:
        parser = TastyCoffeeHTMLParser()
        parser.feed(html)
        return parser.data


class CLI:
    def __init__(self):
        self.parser = argparse.ArgumentParser(
            description="Parse Tasty Coffee roasting data to YAML"
        )
        self.parser.add_argument("url", help="URL of the report page")
        self.parser.add_argument(
            "-o",
            "--output",
            help="Output YAML file path",
        )

    def run(self):
        args = self.parser.parse_args()

        try:
            scraper = ScraperService(args.url)
            html = scraper.fetch_html()

            coffee_data = scraper.parse(html)

            if args.output is None or args.output == "":
                yaml.dump(
                    coffee_data.to_dict(),
                    sys.stdout,
                    allow_unicode=True,
                    sort_keys=False,
                )
            else:
                with open(args.output, "w", encoding="utf-8") as f:
                    yaml.dump(
                        coffee_data.to_dict(), f, allow_unicode=True, sort_keys=False
                    )

        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    app = CLI()
    app.run()
