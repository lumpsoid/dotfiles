import time
import re

keyboard.send_keys("<ctrl>+<end>")
time.sleep(0.2)
keyboard.send_keys("<ctrl>+<shift>+<home>")
time.sleep(0.2)
keyboard.send_keys("<ctrl>+c")
time.sleep(0.2)
text = clipboard.get_clipboard()
text = text.replace('\n', ' ').strip()
text = re.sub(r'\s{2,}', ' ', text)
clipboard.fill_clipboard(text)
time.sleep(0.3)
keyboard.send_keys("<ctrl>+v")