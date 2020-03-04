# OpenFaaS Github action

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![CI](https://github.com/mrsimpson/action-openfaas-build/workflows/CI/badge.svg)

 A no-frills [Github action](https://help.github.com/en/actions/getting-started-with-github-actions) for building OpenFaaS functions.

The function gets the image information from the function file.

## Limitations

No sophisticated optional parameters! The main pupose of this action is simplicity.
Therefore, no other optional, non-functional parameters influencing the behaviour of `faas-cli` are going to be supported.
If you really feel that you desperately need sommething, feel free to open an issue!

## Inputs

| Parameter | effect   | default | required |
| ----      |   ----   | ----    | -----    |    
| `stack-file` | The OpenFaaS function definition file | `stack.yml` | yes |
| `docker-username` | Your docker username with push authorization | ❌ | yes |
| `docker-password` | Your docker password | ❌ | yes |
| `platforms` | The platform abbreviations to build for, potentially comma-separated. e. g. `linux/amd64,linux/arm/v7` | `linux/amd64` | yes |
| `deploy` | Whether the built image shall be deployed | `0`=no, `1`=yes | no |
| `gateway` | The gateway url override. Only has an effect, if `deploy=1` |  | no |
| `openfaas-username` | User for authenticating at OpenFaaS gateway |  | no |
| `openfaas-password`| Password for authenticating at OpenFaaS gateway |  | no |

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