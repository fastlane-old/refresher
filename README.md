<h3 align="center">
  <a href="https://github.com/fastlane/fastlane">
    <img src="app/assets/images/fastlane.png" width="150" />
    <br />
    fastlane
  </a>
</h3>
<p align="center">
  <a href="https://github.com/fastlane/deliver">deliver</a> &bull; 
  <a href="https://github.com/fastlane/snapshot">snapshot</a> &bull; 
  <a href="https://github.com/fastlane/frameit">frameit</a> &bull; 
  <a href="https://github.com/fastlane/PEM">PEM</a> &bull; 
  <a href="https://github.com/fastlane/sigh">sigh</a> &bull; 
  <a href="https://github.com/fastlane/produce">produce</a> &bull;
  <a href="https://github.com/fastlane/cert">cert</a> &bull;
  <a href="https://github.com/fastlane/codes">codes</a> &bull;
  <a href="https://github.com/fastlane/spaceship">spaceship</a> &bull;
  <a href="https://github.com/fastlane/pilot">pilot</a> &bull;
  <a href="https://github.com/fastlane/boarding">boarding</a>

</p>
-------

refresher
============

[![Twitter: @KauseFx](https://img.shields.io/badge/contact-@KrauseFx-blue.svg?style=flat)](https://twitter.com/KrauseFx)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/fastlane/refresher/blob/master/LICENSE)

`refresher` is being run on [Heroku](https://www.heroku.com/). All [fastlane](https://fastlane.tools) tools check for available updates on each app start.

`refresher` also caches the latest version number for ~5 minutes. The only thing that is stored is a log of the current time. No user specific information is being stored.

You can see the generated stats on [https://refresher.fastlane.tools/](https://refresher.fastlane.tools/) and the graphs on [https://refresher.fastlane.tools/graphs](https://refresher.fastlane.tools/graphs).

Also, the number of active projects using `fastlane` are available [here](https://refresher.fastlane.tools/unique). The App Identifier will be hashed, so that no sensitive data is transfered. 

If you want to opt out, just use the `FASTLANE_SKIP_UPDATE_CHECK` and/or `FASTLANE_OPT_OUT_USAGE` environment variables.

There is also a Raspberry Pi client, that shows the launches in real time on a LED board on [GitHub](https://github.com/KrauseFx/fastrockets).

# License
This project is licensed under the terms of the MIT license. See the LICENSE file.

> This project and all fastlane tools are in no way affiliated with Apple Inc. This project is open source under the MIT license, which means you have full access to the source code and can modify it to fit your own needs. All fastlane tools run on your own computer or server, so your credentials or other sensitive information will never leave your own computer. You are responsible for how you use fastlane tools.
