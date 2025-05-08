# 🗂️ Munim Todo - A Flutter Kanban Board

A Kanban-style task manager built in Flutter, featuring role-based authentication, offline storage, and a drag-and-drop Kanban UI. This project demonstrates core app architecture practices using GetX and clean code principles.


## Recording 🎬

https://github.com/user-attachments/assets/49eb7385-13da-4f18-987f-7e8bdd236c79

## Screenshots 📸

| ![Splash](https://github.com/user-attachments/assets/cb4cdb86-ed03-4798-b6f9-c1c6a95762a9) | ![Login](https://github.com/user-attachments/assets/660c97ec-1ef6-4790-bbf3-26024a0456d9) | ![Register](https://github.com/user-attachments/assets/600a6a72-8019-4aa2-99f5-bd36626acb62) | ![AI Alerts](https://github.com/user-attachments/assets/3b8d9924-9ba3-472d-96d9-0320980d4aae) |
|:------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------:|:---------------------------------------------------------------------------------------------:|
| Create User                                                                             | TODO Screen                                                                               | Create Task                                                                          | Update task                                                                                     |

---



## 🔑 Demo Accounts

The app comes with pre-configured demo accounts:

| Username | Password | Role |
| --- | --- | --- |
| admin | admin123 | Admin |
| editor | editor123 | Editor |
| viewer | viewer123 | Viewer |



## 📌 Key Features

### 🔐 Authentication & Role Management
- Login/Register functionality with 3 roles:
  - **Admin**: Full control (create/edit/delete)
  - **Editor**: Can edit tasks only
  - **Viewer**: Read-only access
- Role-based access control in both UI and logic

### 📦 Offline Storage
- Local persistence using Hive
- Tasks saved offline; data is retained without internet
- Manual "Sync" simulation (no real server communication)
- Task sync status: Synced / Pending

### 🧩 Kanban Board UI
- Three draggable columns: To Do, In Progress, Done
- Tasks can be dragged & dropped across columns
- Responsive layout optimized for mobile screens
- Swipe gestures to move tasks between statuses
- Quick action buttons for status transitions

### 📝 Task Details
Each task includes:
- Title (string)
- Description (text)
- Priority: Low / Medium / High
- Status: To Do / In Progress / Done
- Creation information and sync status

## ⚙️ Architecture & Tech Stack

| Layer | Tech |
| --- | --- |
| State Management | GetX |
| Local DB | Hive |
| Architecture | Clean architecture (MVC separation via GetX controllers, views, models) |

## 🚀 Getting Started

1. Clone the repo
```bash
git clone https://github.com/your-username/munim_todo.git
cd munim_todo
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```



## 📱 User Experience Features
- Responsive design for both portrait and landscape orientations
- Intuitive swipe gestures to change task status
- Visual cues for task priority and status
- Smooth animations for better user interaction
- Status change notifications via snackbars 
