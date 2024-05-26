# Anti-Theft Device Using Flutter, Vonage, TypeScript, and MongoDB

## Overview

This project demonstrates how to build a cutting-edge anti-theft device using Flutter, Vonage, TypeScript, and MongoDB. The app leverages the accelerometer of a mobile device to detect movement and sends real-time alerts to the user via calls and SMS.

## Features

- **Movement Detection:** Uses the device's accelerometer to detect any movement.
- **Real-Time Alerts:** Sends notifications via Vonage (calls and SMS) when movement is detected.
- **Anti-Tampering System:** Ensures the device remains secure even if someone tries to turn it off or break it.
- **Backend:** Developed with TypeScript and MongoDB for efficient data management.

## Technologies Used

- **Flutter:** For accessing the accelerometer and building the mobile application.
- **Vonage:** For sending real-time alerts.
- **TypeScript:** For developing the backend.
- **MongoDB:** For data storage and management.

## Demonstration

[YouTube](https://youtu.be/rq6h271bE2Q)

## Use Cases

- **Home Security:** Ensure no one accesses your personal areas when you are away. Simply place the phone into a cupboard, drawer, or any area that shouldn't be accessed. If there is any attempt made to access your belongings, the detected movement will trigger an alert notifying you immediately!

- **Office Security:** Protect your workstation and personal items in the office. Place the device on your desk or in a drawer. Any unauthorized movement of your items will send you an instant alert, ensuring your work materials are safe.

- **Travel Security:** Safeguard your luggage and travel essentials while on the go. Place the device inside your suitcase or travel bag. If someone tries to move or tamper with your luggage, you'll receive an immediate notification, helping you keep your belongings secure.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/get-npm)
- [MongoDB](https://www.mongodb.com/try/download/community)

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/iamuv2000/anti-theft-app
   cd anti-theft-app
   ```
2. ** Start the backend server **
   Add .env file and then

```
cd server
npm install
npm run dev
```

3. **Mobile app**

```
cd movement_app
flutter pub get
flutter run
```
