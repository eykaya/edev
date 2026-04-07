#!/usr/bin/env python3
"""
ZRPD_EDEV OCR Extract — PDF'ten metin cikartma ve parse etme.

Kullanim:
  python3 tools/ocr_extract.py <pdf_dosya_yolu>
  python3 tools/ocr_extract.py --from-sap          # T_DOC'tan son PDF'i al

Gereksinimler:
  pip install pymupdf pytesseract pillow
  brew install tesseract tesseract-lang
"""

import sys
import os
import re
import json
import io
import base64
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

        # Native text yoksa OCR
        pix = page.get_pixmap(dpi=300)
        img = Image.open(io.BytesIO(pix.tobytes("png")))
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

        pix = page.get_pixmap(dpi=300)
        img = Image.open(io.BytesIO(pix.tobytes("png")))
        text = pytesseract.image_to_string(img, lang='tur')
        full_text.append(text)

    doc.close()
    return "\n".join(full_text)


def parse_ikametgah(text: str) -> dict:
    """OCR metninden ikametgah belgesi alanlarini cikar."""
    result = {}

    # TCKN — 'Kimlik No' label sonrasi veya ilk 11-haneli sayi
    tckn = None
    m = re.search(r'Kimlik\s*No\s*[:\s]+(\d{11})', text, re.IGNORECASE)
    if m:
        tckn = m.group(1)
    else:
        m = re.search(r'[1-9]\d{10}', text)
        if m:
            tckn = m.group(0)
    result['tckn'] = tckn or ''

    # TCKN checksum
    if tckn and len(tckn) == 11:
        d = [int(c) for c in tckn]
        odd = d[0] + d[2] + d[4] + d[6] + d[8]
        even = d[1] + d[3] + d[5] + d[7]
        d10 = (odd * 7 - even) % 10
        d11 = (sum(d[:9]) + d10) % 10
        result['tckn_valid'] = (d10 == d[9] and d11 == d[10])
    else:
        result['tckn_valid'] = False

    # Barkod — XXXX-XXXX-XXXX-XXXX
    m = re.search(r'[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}', text)
    result['barcode'] = m.group(0) if m else ''

    # Adi
    m = re.search(r'\bAd[ıi]\s*[:\s]+(\S+)', text, re.IGNORECASE)
    result['adi'] = m.group(1).strip() if m else ''

    # Soyadi
    m = re.search(r'Soyad[ıi]\s*[:\s]+(\S+)', text, re.IGNORECASE)
    result['soyadi'] = m.group(1).strip() if m else ''

    result['full_name'] = f"{result['adi']} {result['soyadi']}".strip()

    # Adres — MAH. ... / SEHIR formatinda satir(lar) bul
    # OCR ciktisinda adres birden fazla satira bolunebilir:
    #   "YAVUZTURK MAH. PAZAR SK. NO: 23 IC"
    #   "Adresi"
    #   "KAPI NO: 3 USKUDAR / ISTANBUL"
    address_parts = []
    lines = text.split('\n')
    mah_idx = -1
    slash_idx = -1

    for i, line in enumerate(lines):
        up = line.upper().strip()
        if 'MAH' in up and mah_idx < 0:
            mah_idx = i
        if mah_idx >= 0 and '/' in up and slash_idx < 0:
            slash_idx = i

    if mah_idx >= 0 and slash_idx >= 0:
        for i in range(mah_idx, slash_idx + 1):
            part = lines[i].strip()
            # "Adresi", "Yeri" gibi gereksiz satirlari atla
            if part and len(part) > 6 and part.upper() not in ('ADRESI', 'ADRES'):
                address_parts.append(part)
        address_line = ' '.join(address_parts)
    elif mah_idx >= 0:
        address_line = lines[mah_idx].strip()
    else:
        address_line = ''

    # Adres No prefix temizle: "Yerlesim Yeri 2467013534 |" gibi
    address_line = re.sub(r'^.*?\|\s*', '', address_line)

    result['full_address'] = address_line

    # Adres parcalama
    if '/' in address_line:
        before_slash, after_slash = address_line.rsplit('/', 1)
        result['city'] = after_slash.strip()

        words = before_slash.strip().split()
        result['district'] = words[-1] if words else ''

        mah_pos = address_line.upper().find('MAH')
        if mah_pos >= 0:
            result['neighborhood'] = address_line[:mah_pos].strip()
            # Sayisal prefix temizle (2467013534 gibi adres no)
            result['neighborhood'] = re.sub(r'^\d+\s*\|?\s*', '', result['neighborhood']).strip()

            dot_pos = address_line.find('.', mah_pos)
            street_start = dot_pos + 1 if dot_pos >= 0 else mah_pos + 3
            street_end = before_slash.rfind(result['district']) if result['district'] else len(before_slash)
            result['street_address'] = address_line[street_start:street_end].strip()
        else:
            result['neighborhood'] = ''
            result['street_address'] = before_slash.strip()
    else:
        result['city'] = ''
        result['district'] = ''
        result['neighborhood'] = ''
        result['street_address'] = address_line

    # Tarih — DD.MM.YYYY
    dates = re.findall(r'\d{2}\.\d{2}\.\d{4}', text)
    result['issue_date'] = dates[0] if dates else ''
    result['valid_until'] = dates[1] if len(dates) > 1 else ''

    result['country'] = 'TR'

    return result


def main():
    parser = argparse.ArgumentParser(description='EDEV PDF OCR Extract')
    parser.add_argument('pdf_file', nargs='?', help='PDF dosya yolu')
    parser.add_argument('--json', action='store_true', help='JSON cikti')
    args = parser.parse_args()

    if not args.pdf_file:
        print("Kullanim: python3 tools/ocr_extract.py <pdf_dosya.pdf>")
        sys.exit(1)

    if not os.path.exists(args.pdf_file):
        print(f"Dosya bulunamadi: {args.pdf_file}")
        sys.exit(1)

    print(f"PDF: {args.pdf_file}")
    print("OCR yapiliyor...")

    text = extract_text_from_pdf(args.pdf_file)

    if not text.strip():
        print("HATA: Metin cikartilamadi!")
        sys.exit(1)

    print(f"Metin uzunlugu: {len(text)} karakter")
    print()

    result = parse_ikametgah(text)

    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print("=" * 50)
        print(f"TCKN      : {result['tckn']} {'(GECERLI)' if result['tckn_valid'] else '(HATALI)'}")
        print(f"Barkod    : {result['barcode']}")
        print(f"Ad Soyad  : {result['full_name']}")
        print(f"Mahalle   : {result['neighborhood']}")
        print(f"Sokak     : {result['street_address']}")
        print(f"Ilce      : {result['district']}")
        print(f"Il        : {result['city']}")
        print(f"Belge Tar : {result['issue_date']}")
        print(f"Gecerlilik: {result['valid_until']}")
        print(f"Ulke      : {result['country']}")
        print("=" * 50)
        print()
        print("--- OCR RAW TEXT ---")
        print(text[:500])


if __name__ == '__main__':
    main()
