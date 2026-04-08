#!/usr/bin/env python3
"""
ZRPD_EDEV OCR Extract — PDF'ten metin cikartma (OCR-only).

Mimari: Python sadece OCR yapar, tum text parsing ABAP DOC_IKA'da.
Output: {"ocr_text": "...", "barcode": "...", "ocr_text_length": N}

Kullanim:
  python3 tools/ocr_extract.py <pdf_dosya_yolu>                    # stdout pretty
  python3 tools/ocr_extract.py <pdf_dosya_yolu> --json              # stdout JSON
  python3 tools/ocr_extract.py <pdf_dosya_yolu> <json_output_yolu>  # SAP modu

Gereksinimler:
  pip install pymupdf pytesseract pillow
  brew install tesseract tesseract-lang
  pip install pyzbar  (opsiyonel, barkod tanima icin)
"""

import sys
import os
import re
import json
import io
import argparse


def extract_text_from_pdf(pdf_path: str) -> str:
    """PDF'ten OCR ile metin cikar."""
    import fitz
    from PIL import Image
    import pytesseract

    doc = fitz.open(pdf_path)
    full_text = []

    for page_num in range(doc.page_count):
        page = doc[page_num]

        # Once native text dene
        text = page.get_text().strip()
        if text:
            full_text.append(text)
            continue

        # Native text yoksa OCR — DPI 200, ust %60 crop
        pix = page.get_pixmap(dpi=200)
        img = Image.open(io.BytesIO(pix.tobytes("png")))
        w, h = img.size
        img = img.crop((0, 0, w, int(h * 0.6)))
        text = pytesseract.image_to_string(img, lang='tur')
        full_text.append(text)

    doc.close()
    return "\n".join(full_text)


def extract_text_from_bytes(pdf_bytes: bytes) -> str:
    """PDF binary'den OCR ile metin cikar."""
    import fitz
    from PIL import Image
    import pytesseract

    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    full_text = []

    for page_num in range(doc.page_count):
        page = doc[page_num]
        text = page.get_text().strip()
        if text:
            full_text.append(text)
            continue

        # OCR — DPI 200, ust %60 crop
        pix = page.get_pixmap(dpi=200)
        img = Image.open(io.BytesIO(pix.tobytes("png")))
        w, h = img.size
        img = img.crop((0, 0, w, int(h * 0.6)))
        text = pytesseract.image_to_string(img, lang='tur')
        full_text.append(text)

    doc.close()
    return "\n".join(full_text)


def decode_barcode_from_image(pdf_path: str) -> str:
    """PDF'in ilk sayfasindan barkodu image-based decode et.

    pyzbar yuklu degilse veya barkod bulunamazsa bos string doner.
    """
    try:
        from pyzbar.pyzbar import decode as pyzbar_decode
        import fitz
        from PIL import Image

        doc = fitz.open(pdf_path)
        page = doc[0]
        pix = page.get_pixmap(dpi=200)
        img = Image.open(io.BytesIO(pix.tobytes("png")))

        # Barkod genellikle sayfanin ust 1/4'unda
        w, h = img.size
        img_top = img.crop((0, 0, w, int(h * 0.25)))

        barcodes = pyzbar_decode(img_top)
        doc.close()

        for bc in barcodes:
            data = bc.data.decode('utf-8')
            # NVI barkod formati: XXXX-XXXX-XXXX-XXXX
            if re.match(
                r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$', data
            ):
                return data
        return ''
    except ImportError:
        return ''
    except Exception:
        return ''


def main():
    parser = argparse.ArgumentParser(description='EDEV PDF OCR Extract')
    parser.add_argument('pdf_file', help='PDF dosya yolu')
    parser.add_argument(
        'json_output', nargs='?', default=None,
        help='JSON cikti dosya yolu (SAP modu)'
    )
    parser.add_argument(
        '--json', action='store_true', help='JSON stdout cikti'
    )
    args = parser.parse_args()

    if not os.path.exists(args.pdf_file):
        print(f"Dosya bulunamadi: {args.pdf_file}", file=sys.stderr)
        sys.exit(1)

    # OCR
    text = extract_text_from_pdf(args.pdf_file)

    if not text.strip():
        print("HATA: Metin cikartilamadi!", file=sys.stderr)
        sys.exit(1)

    # Barcode — pyzbar ile image-based decode
    barcode = decode_barcode_from_image(args.pdf_file)

    result = {
        "ocr_text": text,
        "barcode": barcode,
        "ocr_text_length": len(text),
    }

    if args.json_output:
        # SAP modu: JSON dosyaya yaz + OCR_DONE stdout'a
        with open(args.json_output, 'w', encoding='utf-8') as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print("OCR_DONE")
    elif args.json:
        # CLI JSON modu
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        # Pretty-print modu
        print(f"PDF: {args.pdf_file}")
        print(f"OCR Metin ({len(text)} karakter):")
        print("-" * 50)
        print(text[:500])
        if len(text) > 500:
            print(f"... ({len(text) - 500} karakter daha)")
        print("-" * 50)
        if barcode:
            print(f"Barkod: {barcode}")
        else:
            print("Barkod: (bulunamadi)")


if __name__ == '__main__':
    main()
