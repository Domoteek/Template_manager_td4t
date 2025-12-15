from PIL import Image
import os

files = ['bar01.bmp', 'rd4.bmp']
for f in files:
    if os.path.exists(f):
        img = Image.open(f)
        print(f"{f}: {img.size}")
    else:
        print(f"{f}: not found")
