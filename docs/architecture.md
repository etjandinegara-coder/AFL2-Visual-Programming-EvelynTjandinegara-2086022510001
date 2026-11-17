# Arsitektur Aplikasi Rental Mobil

1. Ringkasan

Aplikasi rental mobil ini memakai pola MVVM (Model View ViewModel) dengan pemisahan lapisan. Data sewa disimpan secara lokal menggunakan 'shared_preferences', sehingga status sewa tetap ada setelah aplikasi ditutup dan dibuka kembali.

2. Struktur Lapisan

```
lib/
├── main.dart                         # perakitan (composition root)
├── domain/
│   ├── models/car.dart               # bentuk data Car
│   └── repositories/car_repository.dart   # kontrak (abstract class)
├── data/
│   └── repositories/car_repository_implementation.dart  # implementasi kontrak
├── viewmodels/
│   ├── car_state.dart                # kondisi layar (sealed class)
│   └── car_view_model.dart           # seluruh logika sewa, kembali, denda
└── views/
    └── car_view.dart                 # tampilan saja
```

3. Pola: MVVM

- Model ('Car', 'CarRepository'): data dan akses data.
- ViewModel ('CarViewModel'): satu-satunya tempat logika. Menyimpan satu 'CarState' dan memberi tahu View lewat 'notifyListeners()'.
- View ('CarView'): membaca 'state' dan memilih widget yang sesuai. Tidak menyimpan state bisnis.
- 
4. State Layar

'CarState' adalah sealed class dengan tiga kondisi: 'CarLoading', 'CarLoaded', dan 'CarFailure'.

5. Dependency Injection

Repository dibuat dan dimasukkan lewat constructor di 'main.dart'

ViewModel hanya mengenal kontrak 'CarRepository'. Dengan begitu, tes memakai 'FakeCarRepository' tanpa menyentuh penyimpanan asli, dan penyimpanan bisa diganti tanpa mengubah ViewModel maupun View.


6. Alasan Pemilihan Pola

- MVVM dipilih karena logika terpusat di ViewModel, sehingga aturan usaha mudah dicari dan diuji.
- Repository + kontrak dipilih supaya penyimpanan bisa diganti dengan perubahan kecil.
- Sealed state dipilih supaya setiap kondisi layar tertangani.

7. Catatan Keterbatasan

- '_LateHoursDialog' memakai 'StatefulWidget' hanya untuk menyimpan teks input. Ia tidak menyimpan state bisnis.
- Angka rupiah belum diberi pemisah ribuan.
- Hanya ada satu fitur utama (daftar, sewa, kembali). Belum ada fitur lain yang memakai pola yang sama.
- Konvensi Modul 1 belum diterapkan karena belum ada catatannya di repositori ini.

8. Source-Swap Evidence

Sumber data berpindah dari daftar di memori ke 'shared_preferences'.

- Commit perpindahan: '5288fca' (pesan commit: "tambah unit test dan perbaiki widget test dengan mock shared_preferences")
- Versi awal (memori): '48dc335' (First Commit - AFL2)
- 'lib/data/repositories/car_repository_implementation.dart': 57 baris ditambah, 18 dihapus.
- 'lib/viewmodels/car_view_model.dart': ikut berubah, karena 'getAllCars()' dan 'updateCar()' menjadi 'Future'.
- 'lib/views/': tidak ada perubahan pada logika tampilan.

9. Keputusan dan Alternatif yang Ditolak

Data rusak (corrupt read)
- Dipilih: jika 'jsonDecode' gagal, daftar dikembalikan ke kondisi awal dan data rusak ditimpa.
- Ditolak: menampilkan 'CarFailure' dengan tombol "Coba lagi".
- Alasan: aplikasi tetap bisa dipakai, dan data rusak tidak terus-menerus menghalangi pembukaan aplikasi.
- Konsekuensi: status sewa yang rusak hilang tanpa pemberitahuan ke pengguna.

Penyimpanan: shared_preferences
- Dipilih: key-value dengan satu kunci 'cars' berisi JSON.
- Ditolak: database (misalnya Hive atau SQLite).
- Alasan: datanya kecil (10 mobil), cukup satu kunci, dan lebih sederhana untuk tahap belajar.

Tema
- Dipilih: 'ColorScheme.fromSeed' dengan satu warna dasar.
- Ditolak: menentukan setiap warna secara manual per widget.
- Alasan: warna konsisten dan mudah diganti dari satu tempat.

10. Uji Layout (Indikator 3.3)

- Diuji di emulator/perangkat standar (Pixel 8): daftar mobil tampil, tombol Sewa dan Kembali terlihat penuh.
- Belum diuji: ukuran layar kedua (layar kecil) dan rotasi layar.
- Risiko yang belum diverifikasi: baris tombol di 'Card' bisa overflow pada layar sempit.