# Ding Talk

[![CI Check](https://github.com/zhengmz/actions/actions/workflows/dingtalk.yml/badge.svg)](https://github.com/zhengmz/actions/actions/workflows/dingtalk.yml)

Using this GitHub Action Notify message to DingTalk.

see: 

- <https://github.com/marketplace?type=actions&query=Dingtalk>
- [js variant 1](https://github.com/ghostoy/dingtalk-action)
- [js variant 2](https://github.com/wow-actions/dingtalk-notify)

## Features

- Support Ubuntu
- Support tow url method: token or webhook
- Support secret method: secret or keyword or both

## Usage

```yaml
- name: DingTalk Notify
  uses: zhengmz/actions@dingtalk
  with:
    token: ${{ secret.DINGTALK_TOKEN }}
    webhook: ${{ secret.DINGTALK_WEBHOOK }}
    secret: ${{ secret.DINGTALK_SECRET }}
    keyword: ${{ secret.DINGTALK_KEYWORD }}
    ignore_error: true
    # JSON format
    body: |
      {
        "msgtype": "markdown",
        "markdown": {
           "title": "GitHub Actions Notify",
           "text": "我就是我, 是不一样的烟火"
        },
        "at": {
          "atMobiles":[
            "180xxxxxx"
          ],
          "atUserIds":[
            "user123"
          ],
          "isAtAll": false
        },
      }
```

## Inputs

Various inputs are defined to let you configure the action:

| Name | Required | Description | Default |
| --- | :-: | --- | --- |
| `token` | ✔️ | Dingtalk bot token |  |
| `webhook` | ✔️ | Dingtalk bot webhook |  |
| `secret` |  | Dingtalk bot secret to [sign the request](https://developers.dingtalk.com/document/robots/customize-robot-security-settings) |  |
| `keyword` |  | Dingtalk bot keyword |  |
| `msgtype` |  | Dingtalk message type. Valid types are: `'text'`, `'markdown'`, `'link'`, `'actionCard'`, `'feedCard'`. | `'markdown'` |
| `content` |  | Dingtalk message content in [JSON type](https://developers.dingtalk.com/document/robots/custom-robot-access) |  |
| `at` |  | Users to at in JSON type, or set to `'all'` to at all users |  |
| `ignore_error` |  | If set true, will not fail action when sending message failed | `true` |
| `body` |  | Whole data for api |  |

## FAQ

```json
// 消息内容中不包含任何关键词
{
  "errcode":310000,
  "errmsg":"keywords not in content"
}

// timestamp 无效
{
  "errcode":310000,
  "errmsg":"invalid timestamp"
}

// 签名不匹配
{
  "errcode":310000,
  "errmsg":"sign not match"
}

// IP地址不在白名单
{
  "errcode":310000,
  "errmsg":"ip X.X.X.X not in whitelist"
}
```

