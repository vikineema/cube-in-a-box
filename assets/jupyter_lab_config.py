# Configuration file for lab.
import os
import psutil

c = get_config()  #noqa
total_memory = psutil.virtual_memory().total

c.ServerApp.IdentityProvider.token = os.environ["CIABPASSWORD"]

if 'MEM_LIMIT' not in os.environ:
    os.environ['MEM_LIMIT'] = str(total_memory)

c.ServerApp.ResourceUseDisplay.mem_limit=int(os.environ['MEM_LIMIT'])

c.ServerApp.ResourceUseDisplay.show_host_usage=True

c.ServerApp.ResourceUseDisplay.track_cpu_percent=True

c.ServerApp.ResourceUseDisplay.track_disk_usage=True
