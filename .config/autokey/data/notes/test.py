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
    store.set_global_value("logseq_filename", new_filename[1])
    keyboard.wait_for_keypress("<right>", timeOut=10.0)

    keyboard.send_keys("<ctrl>+a")
    time.sleep(0.2)

