# Waitinator

Are we there yet?

Use case:

- You are standing in line
- It takes forever
- You add some observations in this app
- The app tells you when you're likely to be served

Ref: <https://docs.flutter.dev/>

# TODO

- Estimate time to arrival
- Publish to Github pages
- Set up CI that publishes to Github pages
- Don't crash when going to the second screen and then back to the first screen
  again. Right now we crash on the periodic 0.5s timer.
- Make the enter-new-observations setup nicer and more obvious
- Make an icon
- Enable removing / correcting observations
- Preserve state even on page reloads
- Make sure we can go back from the ETA screen
- Add a reset button somewhere?
- Adapt app theme to system theme setting: <https://thiagoevoa.medium.com/change-flutter-app-theme-according-to-the-system-theme-mode-c4a63d05128f>

## Done

- Finish initial screen
- Add a button for getting to the ETA screen once the initial screen has been
  properly filled in by the user
- Enable adding queue position observations on the ETA screen
- Run all tests in CI
