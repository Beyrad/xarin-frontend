# 🎵 Xarin Music Player

A modern **Flutter music player app**.
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
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/cd05a346-b4bd-4e69-ab89-4ede00888f9a" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/100e2a09-f24a-4619-bd41-60e414e383c8" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/706d3daf-9de6-4d74-8197-90361e37a6a5" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/99f79d3b-f17b-4557-81a9-2e4dcfc967cd" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/bf010c15-71f0-4f34-ad3e-68cf3f8bd37e" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/e029aaf0-017e-4a08-91f2-d9db8a7846a4" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/47da5efd-fb3a-4823-994d-a21d3d61e043" />
<img width="591" height="1280" alt="image" src="https://github.com/user-attachments/assets/422de100-cb10-4121-bd92-d048f7078df6" />


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
```
  cupertino_icons: ^1.0.8
  web_socket_channel: ^3.0.1
  just_audio: ^0.9.42
  audio_session: ^0.1.13
  permission_handler: ^12.0.1
  audio_metadata_reader: ^1.4.2
  carousel_slider: ^5.1.1
  file_selector: ^1.0.3
```
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
 ├── register.dart          # Registeration page
 ├── profile.dart           # Credentials handling
 ├── constants.dart         # Global constants
 ├── music_player.dart      # Music player UI
 ├── HomePage.dart          # Homepage with playlists
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
