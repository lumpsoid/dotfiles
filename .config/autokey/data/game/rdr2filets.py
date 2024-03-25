import time

cansel, keys_chain = dialog.input_dialog(
    title="Chain keys to press", 
    message=f"Enter a key chain. {store.get_global_value('RUNMACRO')}", 
    default=""
)

if cansel:
    dialog.info_dialog(title="Information", message="you press Cansel")
    pass
else:
    keys_chain = keys_chain.strip().split()
    keyboard.wait_for_keypress("<right>", timeOut=20.0)
    while store.get_global_value('RUNMACRO'):
        for key in keys_chain: 
            keyboard.send_keys("w")
            time.sleep(0.4)
            keyboard.send_keys(key)
            time.sleep(0.4)