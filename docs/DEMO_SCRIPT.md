# Lead Tracker - Demo Script (2-3 minutes)

## Setup
- Use an Android emulator/device. Have internet on initially; be ready to toggle it off for the error-state demo.
- If needed, start fresh by logging out and using a new account, or use "Clear all my leads and reload sample data" from Profile.

## Flow

1. **Splash (0:00–0:10)**
   - Launch the app. Show splash: logo in gradient container, "Lead Tracker", tagline "Manage leads. Close deals.", fade/scale animation.
   - Auto-navigates to Login (no session) or Dashboard (remembered session).

2. **Signup (0:10–0:30)**
   - Tap "Sign up". Enter name, email, password (e.g. `Test1234`) and confirm.
   - Show a validation error briefly (e.g. mismatched confirm or weak password), fix it, then submit.
   - On success, app logs in and lands on Dashboard/Main shell.

3. **Dashboard (0:30–0:50)**
   - Point out greeting with first name and today's date.
   - Show stat cards (Total/New/Contacted/Converted) and conversion rate with progress/segmented bar.
   - Scroll to "Recent leads" and tap "View all" to switch to Leads tab.

4. **Leads - search & filter (0:50–1:10)**
   - Show leads list with count in app bar.
   - Type in search bar (debounced) to filter by name/phone/email/company; clear with X.
   - Tap filter chips (All/New/Contacted/Converted) with counts; show search+filter combine.
   - Open sort menu and change order (Newest/Oldest/Name A-Z).

5. **Add lead with validation then success (1:10–1:35)**
   - Tap FAB "+". Try to save with invalid input (e.g. 9-digit phone or phone starting with 5) to show validation errors.
   - Correct fields (10-digit phone starting 6-9, valid optional email, pick source/status) and save.
   - Show success snackbar and new lead in list; dashboard counts update.

6. **Lead details - call & note, status change (1:35–2:00)**
   - Open a lead (Hero avatar transition). Show info, status, notes section.
   - Tap **Call**: dialer opens (or snackbar if unavailable). Return to app to show auto-added "Called on ..." note and status promoted New → Contacted if applicable.
   - Change status via dropdown; add a manual note and delete a note.

7. **Delete with undo (2:00–2:10)**
   - From Leads list, swipe a lead to delete. Show snackbar with **Undo** and tap Undo to restore (or demonstrate undo behavior).

8. **Persistence (2:10–2:25)**
   - Close the app completely and reopen it. Show user still logged in (Remember me) and leads/edits/statuses/notes still present.

9. **Offline/error state (2:25–2:40)**
   - Turn off internet/Wi-Fi. Pull to refresh on Leads.
   - If local leads exist: show "Could not refresh" snackbar while keeping list. If testing empty state, show ErrorView with Retry and friendly message.
   - Turn internet back on and retry successfully.

10. **Logout (2:40–2:50)**
    - Go to Profile tab, show user info, total leads, app version.
    - Tap Logout, confirm, and return to Login screen.

## Notes for recording
- Keep narration concise and highlight: local hashed auth, Provider + layered architecture, Hive/SharedPreferences persistence, randomuser.me API mapping/merge, and validation/UX states.
- Ensure no overflow on the demo device; rotate once briefly if showing landscape resilience (optional).