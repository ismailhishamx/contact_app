# Development Log: Contacts App

This document summarizes the steps taken to build and refactor the Contacts App, including the implementation of data persistence.

---

## 1. Project Refactoring (Cleanup)
**Goal:** Make the code organized, readable, and professional.

*   **Created `Contact` Model (`lib/contact_model.dart`)**: Instead of using loose variables, we created a blueprint for contact data.
*   **Extracted `ContactCard` Widget (`lib/widgets/contact_card.dart`)**: Moved the visual design of the contact card into its own file.
*   **Refactored `HomeScreen`**: Simplified the main screen by using the new model and widget.

---

## 2. Data Persistence (Saving Data)
**Goal:** Ensure contacts remain saved even after a Hot Restart or App Close.

### The "How to Think About It" Logic:
The app uses two types of memory:
1.  **RAM (The Desk):** Where the app works while open. It is wiped on restart.
2.  **Shared Preferences (The Safe):** A small file on the phone's hard drive where we lock our data for long-term storage.

### The Storage Process:
1.  **Translation (JSON):** Since the "Safe" only understands text, we use `jsonEncode` to turn our `Contact` objects into a long String.
2.  **Saving (`_saveToDisk`):** Every time the list changes (Add/Edit/Delete), we update the "Safe" with the new String.
3.  **Loading (`_loadFromDisk`):** When the app wakes up (`initState`), it checks the "Safe," grabs the String, and turns it back into `Contact` objects.

---

## 3. Key Functions & Concepts
*   **`setState()`**: Tells Flutter to redraw the screen because something changed.
*   **`initState()`**: The "Morning Routine" of the app. It runs once when the screen is created.
*   **`async / await`**: Used when talking to the phone's storage because it takes a split second for the "Safe" to open.
*   **`?? 'Unknown'`**: A safety check (Null Operator) that prevents the app from crashing if data is missing.

---

## 4. Troubleshooting History
*   **Native Plugins:** Learned that adding a library like `shared_preferences` requires a **Full Stop and Start**, not just a Hot Restart.
*   **Console Logging:** Added `print()` statements to track when the app successfully Saves or Loads data.

---

**Summary:** The app is now a functional, persistent system following modern Flutter development patterns.
