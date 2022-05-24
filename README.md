# My GitHub Actions

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat&logo=github&label=LICENSE)](https://github.com/zhengmz/actions/blob/master/LICENSE)
![GitHub Stars](https://img.shields.io/github/stars/zhengmz/actions.svg?style=flat&logo=appveyor&label=Stars&logo=github)
![GitHub Forks](https://img.shields.io/github/forks/zhengmz/actions.svg?style=flat&logo=appveyor&label=Forks&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/zhengmz/actions?label=Latest%20Commit&logo=github)

## 1. Actions

### 1.1 outputs

必须在一行上，如果涉及多行，需要处理，如

```shell
o="$(cat ./functions | sed ':a;N;s/\n/\\n/g;ta')"
echo "::set-output name=functions::$o"
```

## 2. workflow

### 2.1 使用 `${{ <key> }}` 来引用

原理上，似乎只是替换，可以先使用 env 来获取，再引用

如果其值含有引号等符号，也会直接替换，如

```yaml
- id: lib
  run: |
    o="$(cat $GITHUB_ACTION_PATH/functions | sed ':a;N;s/\n/\\n/g;ta')"
    echo "::set-output name=functions::$o"

  # 如果 functions 文件中有引号，则会出错
- name: error usage
  run: |
    echo "${{ steps.lib.outputs.functions }}" > /tmp/functions

  # 正确使用：用一个环境变量先获取其值
- name: correct usage
  env:
    f: ${{ steps.lib.outputs.functions }}
  run: |
    echo "$f" > /tmp/functions
```

### 2.2 权限

```conf
permissions:
  actions: write  # for delete workflow run
  contents: write # for create or delete release
```

### 2.3 触发

- `workflow_dispatch` 事件只在默认分支有效
  - see: <https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow>
- `on: push` 指定分支时，需要此 yml 也在此分支下的 `.github/workflow` 目录下 

  ```yaml
  # 此 yml 必须在 lib 分支下，才能被触发
  on:
    push:
      branches:
        - 'lib'
  ```

所以，如果既需要 push 分支触发，又需要手工运行，则 yml 文件必须在默认分支和 lib 分支都存在

### 2.4 运行环境

每个步骤的运行环境似乎是独立，如

```yml
- name: Source functions by curl
  if: env.IMPORT_ACTION != 'true'
  run: |
    #set +e
    ls -alh
    [ -f /tmp/functions ] && cat /tmp/functions && rm -f /tmp/functions
    curl -fsSL https://github.com/zhengmz/actions/raw/lib/functions > /tmp/functions
    source /tmp/functions

  # 上步 functions 中的四个函数无法在这里使用
- name: Check functions
  run: |
    info "information"
    warn "warning message"
    error "error log"
    log "notice"
```

### 2.5 重用 workflow

see: <https://docs.github.com/en/actions/using-workflows/reusing-workflows>

在子流程中，需要定义 `workflow_call` 事件，如：

```yaml
# At .github/workflow/lib.yml @ lib
on:
  # Be a reusable workflow
  workflow_call:
    inputs:
      delete_run:
        description: 'Delete older workflow run'
        type: string
        required: true
        default: 'true'
      import_action:
        description: 'Import lib by action'
        type: string
        required: false
        default: 'true'
    outputs:
      status:
        description: "The status of workflow"
        value: ${{ jobs.build.outputs.status }}

env:
  DELETE_OLD_RUN: ${{ github.event.inputs.delete_run || 'true' }}
  IMPORT_ACTION: ${{ github.event.inputs.import_action || 'true' }}
```

在主流程中，使用如下：

```yaml
# At .github/workflow/manual.yml @ master 
jobs:
  call-lib-yml:
    uses: zhengmz/actions/.github/workflows/lib.yml@lib
    if: github.event.inputs.workflow == 'lib'
    with:
      delete_run: ${{ github.event.inputs.delete_run }}

  build:
    runs-on: ubuntu-latest
```

已知情况：

- 传递给被重用的子流程的 github 仍然是主流程的参数，并没有 `workflow_call` 的事件名
- 传递 boolean 变量时，主流程会使用 'true' 字符串，而子流程则严格校验 boolean，所以在子流程中改为 string 类型
- 在主流程中使用 needs 时，如果子流程被 skipped，则主流程也 skipped
- 主流程中不使用 needs 时，其执行顺序无序，此时，无法获取子流程的 outputs

