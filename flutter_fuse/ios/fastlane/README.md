fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios firebase
```
fastlane ios firebase
```
Push a new beta build to firebase
### ios upload_app
```
fastlane ios upload_app
```
Only do the deliver
### ios beta
```
fastlane ios beta
```
Push a new beta build to TestFlight
### ios beta_local
```
fastlane ios beta_local
```
Push a new beta build to TestFlight
### ios beta_deliver_local
```
fastlane ios beta_deliver_local
```
Only do the deliver
### ios screenshots
```
fastlane ios screenshots
```
Generate new localized screenshots

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
