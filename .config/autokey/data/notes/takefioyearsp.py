import time
import re

text = clipboard.get_clipboard()
time.sleep(0.2)
text = text.split(',')
name = ''.join(text[:2])
name = re.sub(r'[^\d\w\s]', '', name).strip().lower().replace(' ', '')
year = re.search(r'\(([0-9]+)\)', text[-1]).group(1)
time.sleep(0.2)
clipboard.fill_clipboard(name+year)