import barcode
from barcode.writer import ImageWriter
from PIL import Image, ImageDraw, ImageFont
import os

def get_font_for_width(draw, text, max_width, start_size=60, font_path="arial.ttf"):
    size = start_size
    while size > 10: # Minimum readable size
        try:
            font = ImageFont.truetype(font_path, size)
        except IOError:
            font = ImageFont.load_default()
            return font # Default font is not scalable via size arg easily in old PIL, so return it
        
        bbox = draw.textbbox((0, 0), text, font=font)
        width = bbox[2] - bbox[0]
        if width <= max_width:
            return font
        size -= 2
    return ImageFont.load_default()

def generate_ean13(filename, bottom_text=None, top_text=None, old_price=None, new_price=None):
    # EAN13 code (using a standard test code)
    code = '123456789012' 
    ean = barcode.get('ean13', code, writer=ImageWriter())
    
    # Save as PNG first (python-barcode default)
    filename_png = filename.replace('.bmp', '')
    ean.save(filename_png)
    
    # Open valid PNG
    img_path = f"{filename_png}.png"
    if not os.path.exists(img_path):
         print(f"Error: {img_path} not found")
         return

    img = Image.open(img_path)
    w, h = img.size
    
    draw_check = ImageDraw.Draw(img)
    
    # Determine fonts that fit
    top_font = None
    if top_text:
        top_font = get_font_for_width(draw_check, top_text, w - 20, start_size=60)
        
    bottom_font = None
    full_bottom_text = bottom_text
    
    if old_price and new_price:
        full_bottom_text = f"PRIX: {old_price} / {new_price}"
        
    if full_bottom_text:
        bottom_font = get_font_for_width(draw_check, full_bottom_text, w - 20, start_size=60)

    # Calculate dimensions
    extra_h_top = 0
    extra_h_bottom = 0
    
    if top_text and top_font:
        dummy_draw = ImageDraw.Draw(img)
        t_bbox = dummy_draw.textbbox((0, 0), top_text, font=top_font)
        t_h = t_bbox[3] - t_bbox[1]
        extra_h_top = t_h + 20 # Reduced Padding
        
    if full_bottom_text and bottom_font:
        dummy_draw = ImageDraw.Draw(img)
        b_bbox = dummy_draw.textbbox((0, 0), full_bottom_text, font=bottom_font)
        b_h = b_bbox[3] - b_bbox[1]
        extra_h_bottom = b_h + 20 # Reduced Padding
        
    new_h = h + extra_h_top + extra_h_bottom
    new_img = Image.new("RGB", (w, new_h), "white")
    
    # Paste original barcode
    new_img.paste(img, (0, extra_h_top))
    
    draw = ImageDraw.Draw(new_img)
    
    # Draw Top Text
    if top_text and top_font:
        t_bbox = draw.textbbox((0, 0), top_text, font=top_font)
        t_w = t_bbox[2] - t_bbox[0]
        x = (w - t_w) / 2
        y = (extra_h_top - (t_bbox[3] - t_bbox[1])) / 2
        draw.text((x, y), top_text, fill="black", font=top_font)
        
    # Draw Bottom Text (Standard)
    if bottom_text and not (old_price and new_price) and bottom_font:
        b_bbox = draw.textbbox((0, 0), bottom_text, font=bottom_font)
        b_w = b_bbox[2] - b_bbox[0]
        x = (w - b_w) / 2
        y = (h + extra_h_top) + (extra_h_bottom - (b_bbox[3] - b_bbox[1])) / 2
        draw.text((x, y), bottom_text, fill="black", font=bottom_font)

    # Draw Bottom Text (Old/New Price)
    if old_price and new_price and bottom_font:
        # Re-calc standard text placement for vertical centering
        f_bbox = draw.textbbox((0, 0), full_bottom_text, font=bottom_font)
        f_w = f_bbox[2] - f_bbox[0]
        f_h = f_bbox[3] - f_bbox[1]
        
        start_x = (w - f_w) / 2
        y = (h + extra_h_top) + (extra_h_bottom - f_h) / 2
        
        current_x = start_x
        
        part1 = "PRIX: "
        part2 = f"{old_price} "
        part3 = "/ "
        part4 = f"{new_price}"
        
        # Draw parts
        draw.text((current_x, y), part1, fill="black", font=bottom_font)
        current_x += draw.textlength(part1, font=bottom_font)
        
        # Old Price
        draw.text((current_x, y), part2, fill="black", font=bottom_font)
        p2_w = draw.textlength(part2, font=bottom_font)
        
        # Strikethrough
        line_y = y + f_h * 0.6
        draw.line([(current_x, line_y), (current_x + p2_w - 5, line_y)], fill="black", width=max(2, int(bottom_font.size/10))) 
        
        current_x += p2_w
        
        draw.text((current_x, y), part3, fill="black", font=bottom_font)
        current_x += draw.textlength(part3, font=bottom_font)
        
        draw.text((current_x, y), part4, fill="black", font=bottom_font)

    # Convert to BMP and save
    new_img.save(filename)
    print(f"Generated {filename}")

if __name__ == "__main__":
    generate_ean13("rd4.bmp", top_text="LIBELLE PRODUIT", old_price="15.00 €", new_price="12.90 €")
