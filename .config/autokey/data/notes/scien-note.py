import time

keyboard.send_keys("<ctrl>+<end>")
time.sleep(0.2)
keyboard.send_keys("<ctrl>+<shift>+<home>")
time.sleep(0.2)
keyboard.send_keys("<ctrl>+c")
time.sleep(0.2)
text = clipboard.get_clipboard()
text = text.replace(':: ', ': ')
text = text.replace('  ', ' ')
text = text.split('\n')
for i, line in enumerate(text):
    line = line.strip(' -')
    text[i] = "- "+line
text = '\n'.join(text)
clipboard.fill_clipboard(text)
time.sleep(0.3)
keyboard.send_keys("<delete>")
time.sleep(0.3)
keyboard.send_keys("<ctrl>+v")