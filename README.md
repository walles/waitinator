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

## Development

Lint and test:

```
flutter analyze && flutter test
```

Easiest run is to do it from VSCode, just use the launch config.

Otherwise, from the command line:

```
flutter run
```

To exercise the Android build:

```
flutter build appbundle
```

### Color Theme

The color theme of the app has to be set in a number of different places:

- The [icon](icon/)
- In [`main.dart`](lib/main.dart), in `baseColor`
- The `theme_color` in [`web/manifest.json`](web/manifest.json)

## TODO

- Replace the ETA algorithm. We should use the least-squares method to get a
  line through all points, then pick the ETA span so that 90% or more of all
  observations end up between the lines. Each observation should count as two
  points, one at the actual number and one at the next number.
- Make a macOS app
- Reloading the app when it was on the Graph tab should keep it on the Graph tab
- Add a version / build number on the info screen, verify on both web and
  Android
- Hint user to provide more observations if the two ETAs are "too far" apart
- Bold the lower bound time left number
- Enable removing / correcting observations
- Use some kind of variable for the `flutter-version` in [our CI GitHub action](/.github/workflows/test-and-deploy.yaml)

### Done

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
- Make the icon's "i" match the theme blue color, and the various icon
  backgrounds on web and Android white
- Add dark mode support, tested on web and Android
- Make the ETA screen input box not look like crap in Firefox on Android. Can be
  reproduced using Chrome on a computer with mobile emulation mode and a narrow
  enough screen.
- Preserve state even on page reloads
- Test graph with both ETAs being close
- Test graph with start time and initial ETA being close
- Test graph both while counting up and counting down
- Test graph with both light and dark theme
- Don't crash when going to the second screen and then back to the first screen
  again. On web, we used to crash on the periodic 0.5s timer.
