

# Decoda

Decoda is a native macOS utility for decoding and inspecting configuration profiles (`.mobileconfig` files).

It provides administrators and engineers with a simple, local way to view the raw XML contents of a configuration profile without uploading files to third‑party services.

---

## 🔍 Overview

macOS configuration profiles are commonly distributed in encoded or signed formats that are not immediately human‑readable. Decoda converts these profiles into standard XML so their contents can be inspected, searched, and verified.

All processing is performed locally on the user’s machine.

---

## ✨ Features

- 🧾 Decode `.mobileconfig` files into readable XML
- 🔒 Local processing only — no network access or uploads
- 👀 Inline XML preview after decoding
- 🔎 Search within decoded XML
- 📋 Copy decoded XML to clipboard
- 📂 Optional automatic opening of the generated XML file
- 🌓 Native macOS interface with Light and Dark Mode support

---

## 🚀 Usage

1. Launch Decoda  
2. Drag a `.mobileconfig` file into the application (or click to browse)  
3. Click **Decode to XML**  
4. Inspect, search, or copy the decoded XML  

The decoded XML can optionally be saved and opened automatically in the default editor.

---

## ⚙️ Preview and Settings

Decoda includes a settings panel that allows control over:

- ✅ Whether a preview is shown after decoding
- 📤 Whether the decoded XML file is automatically opened
- 📑 Preview mode selection (summary, raw XML, or combined)
- 🎨 App appearance (System, Light, or Dark)

These settings are designed to support different workflows without modifying output.

---

## 🔐 Privacy and Security

Decoda processes files entirely on the local system.

- ❌ No files are uploaded
- ❌ No network connections are made
- ❌ No analytics or telemetry are collected

Configuration profiles may contain sensitive information; Decoda is designed with this in mind.

---

## 🧰 Requirements

- macOS 13 or later
- Xcode 15 or later (for building from source)

---

## 🛠️ Building from Source

1. Clone the repository  
2. Open `Decoda.xcodeproj` in Xcode  
3. Select the **Decoda** scheme  
4. Build and run  

No additional dependencies are required.

---

## 🎯 Intended Audience

Decoda is intended for:

- 🧑‍💻 macOS administrators
- 🗂️ MDM and device management engineers
- 🛡️ Security and compliance teams
- 👨‍🔧 Developers needing to inspect configuration profiles

---

© 2026 Luke Mutlow. All rights reserved.
