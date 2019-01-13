import usb.core
from usb.util import CTRL_IN
from pprint import pprint

dev = usb.core.find(idVendor=0x16C0, idProduct=0x0480)

if dev is None:
    raise ValueError('Device not found')


dev.set_configuration()

pprint(dev)

#ret = dev.ctrl_transfer(0x00, CTRL_IN, 0, 0, 9)
ret = dev.read(0x81, 8)

pprint(ret)
