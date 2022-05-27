# Debug action via tmate

[![CI Check](https://github.com/zhengmz/actions/actions/workflows/tmate.yml/badge.svg)](https://github.com/zhengmz/actions/actions/workflows/tmate.yml)

see:

- <https://github.com/P3TERX/ssh2actions>
- <https://github.com/csexton/debugger-action>
- <https://github.com/mxschmitt/action-tmate>

This GitHub Action offers you connect to GitHub Actions VM via SSH for interactive debugging

## Features

- Support Ubuntu and macOS
- Support SSH connection methods: tmate
- Proceed to the next step or stay connected
- Send SSH connection info to DingTalk

## Usage

### Connect to Github Actions VM via SSH by using [tmate](https://tmate.io)

```yaml
- name: Start SSH via tmate
  uses: zhengmz/actions@tmate
  with:
    timeout: 30
  env:
    # Send connection info to DingTalk (optional)
    # see: https://open.dingtalk.com/document/group/custom-robot-access
    # For url: choose DINGTALK_TOKEN or DINGTALK_WEBHOOK
    DINGTALK_TOKEN: ${{ secrets.DINGTALK_TOKEN }} # Just access_token, not whole webhook url
    DINGTALK_WEBHOOK: ${{ secrets.DINGTALK_WEBHOOK }} # whole webhook url
    # For secret: choose DINGTALK_SECRET or DINGTALK_KEYWORD or both
    DINGTALK_SECRET: ${{ secrets.DINGTALK_SECRET }}
    DINGTALK_KEYWORD: ${{ secrets.DINGTALK_KEYWORD }}
```

