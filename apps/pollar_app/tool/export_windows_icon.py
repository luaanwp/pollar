"""Run after render_brand_assets.cjs to export the Windows multi-size icon."""
from pathlib import Path
from PIL import Image

app = Path(__file__).resolve().parents[1]
with Image.open(app / "assets/brand/pollar-app-icon.png") as icon:
    icon.save(app / "windows/runner/resources/app_icon.ico",
              sizes=[(s, s) for s in [16, 24, 32, 48, 64, 128, 256]])
