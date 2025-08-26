# 🎵 Xarin Music Player

A modern **Flutter music player app** with login, playlists, and offline support.  
Built with **Flutter**, designed for simplicity, and packed with features like metadata reading, album art display, and playlist management.  

---

## ✨ Features

- 🔐 **User Authentication** – Secure login with credentials saved locally.  
- 📥 **Automatic Downloads** – Missing songs are auto-downloaded and synced with `xarin_data.json`.  
- 🗂 **Playlist Management** – Create, edit, and play from custom playlists.  
- 🎶 **Music Player** – Play, pause, and navigate between tracks.  
- 🖼 **Album Art & Metadata** – Extracts title, artist, duration, and cover image.  
- 🔄 **Sync with Server** – Keeps local library up to date with server data.  
- 📱 **Beautiful UI** – Carousel slider for albums, smooth navigation, and clean design.  

---

## 📸 Screenshots

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+ recommended)  
- Android Studio / VS Code with Flutter plugin  
- Device/emulator with Android 7.0+  

### 2. Clone the Project
```bash
git clone https://github.com/your-username/xarin-music-player.git
cd xarin-music-player
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

---

## 📂 Project Structure
```
lib/
 ├── main.dart              # Entry point
 ├── login.dart             # Login screen
 ├── profile.dart           # Credentials handling
 ├── constants.dart         # Global constants
 ├── music_player.dart      # Music player UI
 ├── home.dart              # Homepage with playlists
 └── widgets/               # Reusable widgets
```

---

## 🛠 Tech Stack
- **Flutter** – Cross-platform UI  
- **Dart** – Core language  
- **just_audio** – Music playback  
- **audio_metadata_reader** – Metadata & album art  
- **carousel_slider** – Album carousel UI  
- **permission_handler** – Storage access  
- **file_selector** – File picking  

---

## 🤝 Contributing
Contributions are welcome!  
Feel free to fork the repo and submit a PR with improvements.

---

## 📜 License
This project is licensed under no license! enjoy and share it.

---

## 👨‍💻 Author
Developed with ❤️ by **[Amin & Behrad]**
