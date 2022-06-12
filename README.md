<a href="https://github.com/walles/waitinator/actions"><img src="https://github.com/walles/waitinator/workflows/test-and-deploy/badge.svg" alt="Build Status"></a>

# [Waitinator](https://walles.github.io/waitinator/)

Try it here: <https://walles.github.io/waitinator/>

---

Are we there yet?

Use case:

- You are standing in line
- It takes forever
- You add some observations in this app
- The app tells you when you're likely to be served

Ref: <https://docs.flutter.dev/>

# TODO

- Add a version / build number somewhere in the UI
- Add source code link somewhere in the UI
- Bold the lower bound time left number
- Don't crash when going to the second screen and then back to the first screen
  again. Right now we crash on the periodic 0.5s timer.
- Make an icon
- Render to an Android app and install on my phone
- Enable removing / correcting observations
- Preserve state even on page reloads
- Add a reset button somewhere?
- Adapt app theme to system theme setting: <https://thiagoevoa.medium.com/change-flutter-app-theme-according-to-the-system-theme-mode-c4a63d05128f>

## Done

- Finish initial screen
- Add a button for getting to the ETA screen once the initial screen has been
  properly filled in by the user
- Enable adding queue position observations on the ETA screen
- Run all tests in CI
- Estimate time to arrival
- Publish to Github pages
- Set up CI that publishes to Github pages
