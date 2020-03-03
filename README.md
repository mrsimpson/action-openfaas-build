# OpenFaaS Github action

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

 A [Github action](https://help.github.com/en/actions/getting-started-with-github-actions) for building OpenFaaS functions.

The function gets the image information from the function file.

## 🌨⚡️ Limitations

The app is currently not capable of building multi-images-functions, see [corresponding issue](https://github.com/mrsimpson/action-openfaas-build/issues/4)

## Inputs

| Parameter | effect   | default |
| ----      |   ----   | ----    |
| `stack-file` | The OpenFaaS function definition file | `stack.yml` |
| `docker-username` | Your docker username with push authorization | |
| `docker-password` | Your docker password | |
| `platforms` | The platform abbreviations to build for, potentially comma-separated. e. g. `linux/amd64,linux/arm/v7` | `linux/amd64` |

## Further links

🏠 [**Homepage**](https://github.com/mrsimpson/action-openfaas-build)

✨ [**Demo**](https://github.com/open-abap/openfaas-fn-fibonacci/actions)

## Author

👤 **Oliver Jägle**

* Twitter: [@OJaegle](https://twitter.com/OJaegle)
* Github: [@mrsimpson](https://github.com/mrsimpson)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!

Feel free to check [issues page](https://github.com/mrsimpson/action-openfaas-build/issues). 

## Show your support

Give a ⭐️ if this project helped you!


***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_