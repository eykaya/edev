# Geliştirme Ortamı Kurulum Rehberi

Bu rehber, `eykaya/edev` reposunu sıfırdan kurmak isteyen geliştiriciler için hazırlanmıştır.

## Ön Koşullar

- Node.js 18+
- Git
- VS Code
- SAP sisteme erişim (URL, kullanıcı, şifre)
- GitHub Personal Access Token (repo sahibinden alınır)

---

## 1. Repoyu Klonla

```bash
git clone https://github.com/eykaya/edev.git
cd edev
```

Git kimliğini ayarla:

```bash
git config user.name "Adın Soyadın"
git config user.email "email@rapidsol.com.tr"
```

GitHub token'ı kaydet (bir kere yapılır):

```bash
git config --global credential.helper store
echo "https://<github-kullanici>:<TOKEN>@github.com" > ~/.git-credentials
```

---

## 2. Node Bağımlılıklarını Kur

```bash
npm install
```

Kurulumu doğrula:

```bash
npm run lint
```

> Lint hataları görülmesi normaldir — mevcut koddan kalma. Yeni geliştirmelerde temiz tutulur.

---

## 3. SAP Bağlantı Bilgilerini Ayarla

```bash
cp .env.example .env
```

`.env` dosyasını aç ve doldur:

```env
SAP_URL=http://<sap-ip>:8000/
SAP_CLIENT=100
SAP_USER=<kullanici>
SAP_PASSWORD=<sifre>
SAP_LANGUAGE=TR
```

---

## 4. Dassian ADT MCP Sunucusunu Kur

```bash
cd tools/dassian-adt
git clone https://github.com/DassianInc/dassian-adt .
npm install
npm run build
cd ../..
```

---

## 5. Claude Code MCP Konfigürasyonu

`~/.claude.json` dosyasını aç (yoksa oluştur) ve `mcpServers` bölümünü ekle/güncelle:

```json
{
  "mcpServers": {
    "sap-adt": {
      "command": "node",
      "args": [
        "C:/VsCodeWorkspace/edev/tools/dassian-adt/dist/index.js"
      ],
      "env": {
        "SAP_URL": "http://<sap-ip>:8000/",
        "SAP_USER": "<kullanici>",
        "SAP_PASSWORD": "<sifre>",
        "SAP_CLIENT": "100",
        "SAP_LANGUAGE": "TR"
      }
    }
  }
}
```

> **Not:** `args` içindeki path'i kendi proje dizinine göre ayarla.

---

## 6. Claude Code'u Yeniden Başlat

VS Code'u tamamen kapat ve tekrar aç. Sistem-reminder'da `mcp__sap-adt__*` araçlarının listelendiğini görmelisin.

---

## 7. Bağlantıyı Test Et

Claude Code'da yeni bir konuşma aç ve şunu yaz:

> "SAP sistemine healthcheck yap"

Başarılı yanıt:

```json
{
  "status": "success",
  "healthy": true
}
```

---

## Önemli Notlar

| Dosya | Açıklama |
|---|---|
| `.env` | SAP bağlantı bilgileri — git'e commit edilmez |
| `~/.claude.json` | Claude Code global config — MCP sunucusu buradan okunur |
| `~/.claude/settings.json` | Claude Code izin ayarları — MCP config **buradan okunmaz** |
| `tools/dassian-adt/` | Dassian ADT kaynak kodu — git'e commit edilmez, her kurulumda klonlanır |

## Yaygın Hatalar

**`mcp-abap-adt` araçları görünüyor, `sap-adt` yok:**
→ `~/.claude.json` dosyasındaki `mcpServers` bölümünü kontrol et. `~/.claude/settings.json` değil, `~/.claude.json` okunur.

**`SAP_URL is required` hatası:**
→ `~/.claude.json` içindeki env değişkenlerini kontrol et.

**`dist/index.js` bulunamıyor:**
→ `tools/dassian-adt` dizininde `npm run build` komutunu çalıştır.
