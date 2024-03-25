if store.get_global_value('RUNMACRO'):
    store.set_global_value('RUNMACRO', False)
else:
    store.set_global_value('RUNMACRO', True)