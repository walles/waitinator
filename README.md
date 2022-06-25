<a href="https://github.com/walles/waitinator/actions"><img src="https://github.com/walles/waitinator/workflows/test-and-deploy/badge.svg" alt="Build Status"></a>

# [Waitinator](https://walles.github.io/waitinator/)

Try it here: <https://walles.github.io/waitinator/>

Icon source in the [icon](icon) directory. If you want to change the icon then
first edit the source there, then render it and update all the icon files.

---

Are we there yet?

Use case:

- You are standing in line
- It takes forever
- You add some observations in this app
- The app tells you when you're likely to be served

Ref: <https://docs.flutter.dev/>

# Color Theme

The color theme of the app has to be set in a number of different places:

- The [icon](icon/)
- In [`main.dart`](lib/main.dart), as `primary: Color(...)`
- The `theme_color` in [`web/manifest.json`](web/manifest.json)

# TODO

- Don't crash when going to the second screen and then back to the first screen
  again. Right now (on web) we crash on the periodic 0.5s timer.
- Add a reset button somewhere?
- Make the icon's "i" match the theme blue color, and the various icon
  backgrounds on web and Android white
- Add a version / build number on the info screen, verify on both web and
  Android
- Hint user to provide more observations if the two ETAs are "too far" apart
- Make the ETA screen input box not look like crap in Firefox on Android. Can be
  reproduced using Chrome on a computer with mobile emulation mode and a narrow
  enough screen.
- Bold the lower bound time left number
- Enable removing / correcting observations
- Preserve state even on page reloads
- Use some kind of variable for the `flutter-version` in [our CI GitHub action](/.github/workflows/test-and-deploy.yaml)
- Test on Android Dark Mode, then possibly adapt app theme to system theme setting:
  <https://thiagoevoa.medium.com/change-flutter-app-theme-according-to-the-system-theme-mode-c4a63d05128f>

## Done

- Finish initial screen
- Add a button for getting to the ETA screen once the initial screen has been
  properly filled in by the user
- Enable adding queue position observations on the ETA screen
- Run all tests in CI
- Estimate time to arrival
- Publish to Github pages
- Set up CI that publishes to Github pages
- Add source code link somewhere in the UI
- Test on a very low display (think phone web browser in landscape mode)
- Make an icon
- Enable entering multiple identical observations. I wanted to do that when I
  was on the phone and got to hear "your place is number 19" over and over.
- Render to an Android app
- Make a compliant Android icon
