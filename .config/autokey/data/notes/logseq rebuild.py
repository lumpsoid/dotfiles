import time

new_filename = store.get_global_value("logseq_filename")
if not new_filename:
    new_filename = ""
new_filename = dialog.input_dialog(
    title="Enter a value", 
    message="Enter a new file name", 
    default=""
)
if new_filename[0] == 1:
    dialog.info_dialog(title="Information", message="you press Cansel")
    pass
else:
    new_filename = new_filename[1].strip().lower()
    store.set_global_value("logseq_filename", new_filename)
    keyboard.wait_for_keypress("<right>", timeOut=10.0)

    keyboard.send_keys("<ctrl>+a")
    time.sleep(0.2)
    keyboard.send_keys("<ctrl>+c")
    time.sleep(0.2)
    note_id = clipboard.get_clipboard()
    time.sleep(0.4)
    keyboard.send_keys("<escape>")
    time.sleep(0.2)
    clipboard.fill_clipboard(new_filename)
    keyboard.send_keys("<ctrl>+n")
    time.sleep(0.2)
    keyboard.send_keys("<enter>")
    time.sleep(0.2)
    keyboard.send_keys("<ctrl>+<home>")
    time.sleep(0.2)
    keyboard.send_keys("<enter>")
    time.sleep(0.2)

    keyboard.send_keys("timestamp:: ")
    time.sleep(0.2)
    keyboard.send_keys(note_id)
    time.sleep(0.2)
    keyboard.send_keys("<enter>")
    time.sleep(0.3)
    keyboard.send_keys("title:: ")
    time.sleep(0.3)
    keyboard.send_keys("<ctrl>+v")
    time.sleep(0.4)
    keyboard.send_keys("<escape>")