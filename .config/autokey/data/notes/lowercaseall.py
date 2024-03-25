import time
import re

keyboard.send_keys("<ctrl>+<end>")
time.sleep(0.2)
keyboard.send_keys("<ctrl>+<shift>+<home>")
time.sleep(0.2)
keyboard.send_keys("<ctrl>+c")
time.sleep(0.2)

text = clipboard.get_clipboard()
time.sleep(0.2)
text = re.sub(r'[^\d\w\s]', '', text).strip().lower().replace(' ', '')
time.sleep(0.2)
clipboard.fill_clipboard(text)
time.sleep(0.3)
keyboard.send_keys("<delete>")