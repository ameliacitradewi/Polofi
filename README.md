# Polofi

Data musik dibaca dari `polofi/Resources/music.csv`. Satu baris adalah satu lagu
di satu playlist. Semua layar menggunakan katalog yang sama.

## Menambah lagu atau playlist

1. Masukkan file audio ke `polofi/Resources/Songs/` (bukan ke `Assets.xcassets`). Pastikan
   file menjadi anggota target `polofi` di Xcode. Folder proyek ini disinkronkan
   otomatis oleh Xcode.
2. Tambahkan baris ke `polofi/Resources/music.csv`, contohnya:

   ```csv
   Calm,Cover1,Rainy Evening,Artist-Rainy Evening.mp3,Artist,AlbumArt
   ```

3. Gunakan nama playlist yang sudah ada untuk menambah lagunya, atau nama baru
   untuk membuat playlist baru. Grid tetap dua kolom; baris dan jumlah lagu
   menyesuaikan isi CSV. Urutan playlist mengikuti kemunculan pertama di CSV,
   sedangkan urutan lagu mengikuti urutan barisnya.
4. Build dan jalankan kembali aplikasi. CSV dan audio disertakan di app bundle;
   perubahan tidak langsung masuk ke aplikasi yang sudah terpasang tanpa build
   atau pembaruan aplikasi.

Kolom CSV (pertahankan header dan urutannya):

| Kolom | Isi |
| --- | --- |
| `playlist` | Nama playlist, wajib dan peka huruf besar/kecil. |
| `coverArt` | Nama gambar di Assets, tanpa ekstensi. Kosong = `Cover1`. Gunakan nilai yang sama untuk setiap lagu dalam playlist yang sama. |
| `title` | Judul lagu, wajib. |
| `filename` | Nama file audio lengkap dengan ekstensi, harus cocok persis dengan file dalam bundle. |
| `artist` | Nama artis. Kosong = `Unknown Artist`. |
| `albumArt` | Nama gambar di Assets, tanpa ekstensi. Kosong = `AlbumArt`. |

Simpan sebagai CSV UTF-8 dengan pemisah koma atau titik koma (`;`). Pemisah dideteksi dari header. Teks berisi karakter pemisah harus diapit tanda
kutip, misalnya `"Rain, Again"`. Tanda kutip dalam teks ditulis dua kali:
`"A ""Quiet"" Night"`. Baris kosong diabaikan. Lagu yang sama dapat masuk ke
playlist berbeda, tetapi tidak boleh diulang dalam playlist yang sama.

Menambah file audio saja belum menentukan judul, artis, atau playlistnya; baris
CSV tetap diperlukan. Suara timer `ding.mp3` tidak masuk katalog musik.
Jika CSV tidak valid, katalog tidak dimuat dan detail kesalahan ditampilkan di
console Xcode. Audio yang tidak ditemukan dilewati; playlist dengan lagu lain
yang tersedia tetap muncul. Playlist tanpa audio yang tersedia disembunyikan.
Gambar sampul dapat berupa Image Set atau Data Set yang dapat dibaca UIKit.

## Riwayat pemutaran

Recently Played menyimpan maksimal enam lagu unik yang berhasil mulai diputar,
baik lewat timer maupun music player. Lagu terbaru muncul paling atas; pemutaran
ulang memindahkan lagu ke atas. Riwayat disimpan di perangkat menggunakan nama
file audio sehingga tetap tersedia setelah aplikasi dibuka kembali. Audio timer
tidak dihitung. Mengetuk kartu playlist memutar lagu pertamanya; mengetuk lagu
di Recently Played memutar lagu tersebut.

## Verifikasi

Jalankan dari root proyek:

```sh
swiftc polofi/Model/Song.swift polofi/Model/Playlist.swift polofi/Model/MusicLibrary.swift Tests/MusicLibraryTests.swift -o /tmp/polofi-library-tests
/tmp/polofi-library-tests
```

Opsional: berikan path hasil build `polofi.app` sebagai argumen untuk memeriksa
bahwa CSV dan semua audio dapat dibaca dari app bundle.

Verifikasi urutan, batas enam lagu, deduplikasi, dan penyimpanan riwayat:

```sh
swiftc polofi/Model/Song.swift polofi/Model/Playlist.swift polofi/Model/PlaybackHistory.swift Tests/PlaybackHistoryTests.swift -o /tmp/polofi-history-tests
/tmp/polofi-history-tests
```
