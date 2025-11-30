# Installer Images Guide

Create these two images to match your DoctorsHero Core branding:

## 1. installer_banner.bmp
**Size:** 164 x 314 pixels
**Format:** BMP (24-bit)

### Design Specifications:
- **Background:** Gradient from #FE3001 (top) to darker shade (bottom)
- **Logo:** Place DoctorsHero logo at top (centered)
- **Text:** "DoctorsHero Core" in white, Product Sans font
- **Tagline:** "Professional Prescription Management" in white
- **Style:** Modern, medical, professional

### Quick Creation (Photoshop/Figma):
```
1. Create 164x314px canvas
2. Fill with gradient (#FE3001 to #C82801)
3. Add white logo (80x80px) at top center
4. Add "DoctorsHero Core" text (18pt, white, bold)
5. Add tagline (12pt, white, regular)
6. Save as BMP (24-bit)
```

## 2. installer_icon.bmp
**Size:** 55 x 58 pixels
**Format:** BMP (24-bit)

### Design Specifications:
- **Content:** DoctorsHero logo only
- **Background:** Transparent or white
- **Style:** Simple, recognizable at small size

### Quick Creation:
```
1. Create 55x58px canvas
2. Place logo (centered, 40x40px)
3. Keep it simple - just the icon
4. Save as BMP (24-bit)
```

## Color Palette

Use these exact colors from your app:

- **Primary Red:** #FE3001
- **Dark Red:** #C82801
- **Text Dark:** #1E293B
- **Text Gray:** #64748B
- **Background:** #F1F5F9

## Tools You Can Use

1. **Photoshop** - Professional
2. **Figma** - Free, web-based
3. **GIMP** - Free, open-source
4. **Canva** - Easy, templates available
5. **Paint.NET** - Simple, Windows-friendly

## Example Layout

### Banner (164x314):
```
┌────────────────┐
│                │
│   [LOGO 80x80] │ ← Top 40px
│                │
│ DoctorsHero    │ ← Center
│     Core       │
│                │
│  Professional  │
│  Prescription  │
│  Management    │
│                │
│                │
│   [Medical     │ ← Bottom area
│    Icon]       │
│                │
└────────────────┘
```

### Icon (55x58):
```
┌──────────┐
│          │
│  [LOGO]  │ ← Centered
│          │
└──────────┘
```

## Testing

After creating the images:

1. Place them in `windows/` directory
2. Open `installer.iss` in Inno Setup
3. Click **Tools** > **Preview**
4. Check how they look in the installer

## Tips

✅ **Do:**
- Use high contrast (white on red)
- Keep it simple and professional
- Match your app's color scheme
- Test at actual size

❌ **Don't:**
- Use too many colors
- Add too much text
- Make logo too small
- Use low-quality images

## Need Help?

If you need help creating these images:
1. Use Canva templates
2. Hire a designer on Fiverr ($5-20)
3. Use AI image generators
4. Ask your design team

## Placeholder Images

For testing, you can use solid color placeholders:

**Banner:** Red rectangle with white "DoctorsHero Core" text
**Icon:** Small red square with white "DH" letters

The installer will work without these images, but they make it look much more professional!
