import time

timestamp = time.strftime('%Y%m%d%H%M%S', time.localtime(time.time()))
keyboard.send_keys("timestamp:: ")
keyboard.send_keys(timestamp)