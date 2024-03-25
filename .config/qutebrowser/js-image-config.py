url_dict = {
    "js": [
        'https://vault.bitwarden.com/*',
        'qute://*/*',
        'https://www.deepl.com/*',
    ],
    "image": ['xample.url'],
    "both": [
        'replit.com/*',
        'https://*.repl.co',
        'https://canary.discord.com/*',
        'https://github.com/*',
        'https://piped.kavin.rocks/*',
        'https://chat.openai.com/*',
        'https://web.telegram.org/*',
        'https://*.notion.site/*',
        'https://www.notion.so/*',
        'https://www.figma.com/*',
        'https://bulbapedia.bulbagarden.net/*',
        'https://laoshi.atlassian.net/*',
        'https://analytics.amplitude.com/*',
    ]
}

for url in url_dict.get("js"):
    config.set('content.javascript.enabled', True, url)

for url in url_dict.get("image"):
    config.set('content.images', True, url)

for url in url_dict.get("both"):
    config.set('content.javascript.enabled', True, url)
    config.set('content.images', True, url)
