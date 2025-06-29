# 🎯 FiveM F2F System

Bu script, FiveM sunucuları için geliştirilmiş bir **Face-to-Face (F2F) düello** sistemidir. Oyuncular arasında birebir PvP savaşları oluşturmak için tasarlanmıştır.

## 🔧 Özellikler

- `/f2f [ID]` komutu ile düello teklifi gönderme  
- 10 metre mesafe kontrolü (yakındaki oyunculara teklif)   
- **K (Kabul)** / **R (Reddet)** seçenekleri  
- Oyuncuları 50-100 metre arası mesafeye yerleştirme    
- `ox_inventory` üzerinden `weapon_browning` silahı verme  
- Otomatik düello bitişi (ölüm veya oyuncu çıkışı durumlarında)


## 📦 ox_inventory Uyumluluğu

Eğer `ox_inventory` kullanıyorsanız, oyuncuların düello sırasında silahsız bırakılmaması için `weapon.disarm` fonksiyonu altına şu kontrolü ekleyin:

```lua
if exports["neiz-f2f"]:InF2F() then return end
