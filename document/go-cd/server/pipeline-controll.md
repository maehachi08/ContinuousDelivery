# GoCDにおけるスケジュール制御

## Stage Type
  - [Choose when a stage runs](https://docs.go.cd/15.2.0/configuration/dev_choose_when_stage_runs.html)

GoCDではStageの動作を制御するための **Stage Type** という設定が存在します。

Stage Typeは以下の2つから選択します。
 1. On Success
 1. Manual

### On Success

 Stage Typeで **On Success** を設定している場合、前段のStageが正常に完了した場合に自動的に当該Stageをスケジュールします。

### Manual

 Stage Typeで **Manual** を設定している場合、ユーザが手動でStageのスケジュールを実行する必要があります。

### 注意点

 パイプラインの最初のStageに関しては、On Success に設定することで Materials に登録したGitレポジトリなどの更新を検知し自動的なパイプラインスケジューリングを行ってくれます。逆に言えば、パイプラインの最初のStageを Manual 設定にしていると自動的なパイプラインスケジューリングがされないので注意が必要です。

## Job

Jobの設定項目としてJobのスケジューリング制御を行う設定はなさそうです。


## Task
  - [Conditional task execution](https://docs.go.cd/16.5.0/advanced_usage/dev_conditional_task_execution.html)


GoCDではTaskの動作を制御するための **Run If Conditions** とい設定が存在します。

Run If Conditions は以下の3つから選択します。
 1. Passed
 1. Failed
 1. Any

### Passed

 Run If Conditionsで **Passed** を設定している場合、前タスクが成功している場合に実行します。

### Failed

 Run If Conditionsで **Failed** を設定している場合、前タスクが失敗している場合に実行します。

### Any

 Run If Conditionsで **Any** を設定している場合、前タスクの成否に関わらず実行します。



