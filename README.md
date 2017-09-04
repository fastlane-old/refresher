### This repository is deprecated

Please check out the [main readme](https://github.com/fastlane/fastlane#metrics) for most up to date information about what kind of data fastlane stores.

----


<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="app/assets/images/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>

-------

refresher
============

[![Twitter: @FastlaneTools](https://img.shields.io/badge/contact-@FastlaneTools-blue.svg?style=flat)](https://twitter.com/FastlaneTools)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/refresher/blob/master/LICENSE)

`refresher` is being run on [Heroku](https://www.heroku.com/). All [fastlane](https://fastlane.tools) tools check for available updates on each app start.

`refresher` also caches the latest version number for ~5 minutes. The App Identifier will be hashed, so that no sensitive data is transfered. 

If you want to opt out, just use the `FASTLANE_SKIP_UPDATE_CHECK` and/or `FASTLANE_OPT_OUT_USAGE` environment variables.

# Code of Conduct
Help us keep `refresher` open and inclusive. Please read and follow our [Code of Conduct](https://github.com/fastlane/code-of-conduct).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
