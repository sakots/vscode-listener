# vscode-listener

リモートのUbuntuマシンから`vscode .`でwindowsがわのvscodeを開けるようにするやつ

## 使い方

### 下準備

#### WindowsのSSH設定にRemoteForwardを追加する

Windowsの`~/.ssh/config`を開き、対象ホストの設定へRemoteForwardを追加する。

```text
Host SASAME SASAME-shell
  HostName 192.168.10.105
  User sakots
  IdentityFile ~/.ssh/id_ed25519

Host SASAME-shell
  RemoteForward 54321 localhost:54321
  ExitOnForwardFailure yes
```

#### Ubuntuに vscode 関数を追加する

Ubuntuの`~/.bashrc`または`~/.bash_aliases`に次の関数を追加する。

```bash
vscode() {
  local path
  path="$(realpath "${1:-.}")"

  echo "Opening: $path"

  curl -v -G \
    --data-urlencode "host=SASAME" \
    --data-urlencode "path=$path" \
    http://localhost:54321/
}
```

### windows側

pathの通っているディレクトリに、`vscode-listener.ps1`、`vsl.ps1`、`vsl.bat`のシンボリックリンクを作ってください。

コマンドラインから`vsl`で起動できるようになります。

## 更新履歴

### [2026/09/28] v0.1.0

- リポジトリ生やした
