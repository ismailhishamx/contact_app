# Project Overview: Contacts App

A comprehensive guide to the features, structure, and technical logic of the Contacts App.

---

## 1. App Features
*   **Splash Screen:** A professional entry point with a custom shimmer animation.
*   **Empty State:** Uses Lottie animations to show a "No Contacts" message when the list is empty.
*   **Contact Management:**
    *   **Add:** A bottom sheet to input Name, Email, Phone, and a Profile Image.
    *   **Edit:** Reuses the same form to update existing contact details.
    *   **Delete:** A quick-action button to remove a contact from the list.
*   **Data Persistence:** Uses `shared_preferences` so your data stays saved even if you close the app or restart your phone.

---

## 2. Project Architecture (File Structure)

### `lib/main.dart`
*   **Purpose:** The entry point of the app.
*   **Logic:** Defines the app's theme (colors/fonts) and sets up the Navigation Routes (how the app moves between the Splash and Home screens).

### `lib/contact_model.dart`
*   **Purpose:** The "Blueprint" for data.
*   **Logic:** Defines the `Contact` class. It includes a "Translator" (`toJson` and `fromJson`) to convert complex objects into simple text for storage.

### `lib/home_screen.dart`
*   **Purpose:** The "Brain" of the app.
*   **Logic:** 
    *   Manages the `List<Contact>`.
    *   Handles the "Safe" (Storage) operations: `_saveToDisk` and `_loadFromDisk`.
    *   Controls the Bottom Sheet form for adding/editing.

### `lib/widgets/contact_card.dart`
*   **Purpose:** The "Face" of a contact.
*   **Logic:** A reusable UI component that displays the contact's photo, name, email, and phone number.

### `lib/splash_screen.dart`
*   **Purpose:** The "Introduction."
*   **Logic:** Shows the app logo for 3 seconds before moving to the Home Screen.

---

## 3. Technical Stack (Libraries)
| Library | Purpose |
| :--- | :--- |
| **`shared_preferences`** | The "Safe" used to store contacts on the phone's hard drive. |
| **`image_picker`** | Allows the user to select photos from their gallery. |
| **`lottie`** | Handles the high-quality animations for the empty state. |
| **`google_fonts`** | Provides professional typography (Inter). |

---

## 4. How the "Save" System Works
1.  **Trigger:** Whenever the user clicks "Add" or "Delete," the `_saveToDisk()` function runs.
2.  **Conversion:** The `Contact` objects are converted into **JSON strings**.
3.  **Storage:** These strings are locked into the phone's private storage using a unique key.
4.  **Retrieval:** When the app starts (`initState`), it checks the storage, converts the strings back into objects, and uses `setState()` to show them on the screen.

---

## 5. Important Setup Notes
*   **Native Code:** Because this app uses phone hardware (Storage and Gallery), you must perform a **Cold Boot** (Stop and Start) whenever a new library is added to ensure the Android/iOS engine is fully built.
*   **Permissions:** The app automatically requests access to the phone's gallery when you try to pick a photo.
