# --------------------------------------------------------------------------------------------------------------------
# $FromPath = "バックアップ対象フォルダのパス名"  
# $DestPath = "バックアップ先フォルダのパス名\"  
# [例]
# $FromPath  = "C:\Folder1"              ※末尾には\を付けないでください。
# $DestPath  = "C:\Folder1_backup"  ※末尾に\を付けてください。
# 
# 実行時、[$DestPath+日付時刻文字列]でバックアップ先フォルダが作成されます。
# （例えば 2022年3月5日14時01分02秒に実行した場合）
#  $DestPath  ="C:\Folder1_backup\20220304_140102\" フォルダ内にバックアップが作成されます。
# --------------------------------------------------------------------------------------------------------------------
# ▼ 実行環境に合わせて書き換えてください。
$FromPath = "C:\Folder1"
$DestPath = "C:\Folder1_backup\" 
$BackupHistoryCount = 5



# --------------------------------------------------------------------------------------------------------------------
# $TranscriptPath       = "D:\バックアップXCOPY\backup_xcopy_datetime.log"
# ログファイルの出力先パス名を指定してください。
# --------------------------------------------------------------------------------------------------------------------
# ▼ 実行環境に合わせて書き換えてください。
$TranscriptPath       = "C:\Folder1\Xcopy_with_HistoryManagement.log"


# --------------------------------------------------------------------------------------------------------------------
# 以下は実行コードです。変更しないでください。  
# --------------------------------------------------------------------------------------------------------------------
# PowerShellログ出力の開始
Start-Transcript $TranscriptPath

# 日時分秒別のパスを作成
$ymdhms=Get-Date -Format "yyyyMMdd-HHmmss"
$DestPath2 = $DestPath + $ymdhms  + "\"

ECHO .
ECHO "FromPath  = $FromPath"
ECHO "DestPath2 = $DestPath2"
ECHO .

# バックアップ先フォルダを作成
New-Item ( $DestPath2 ) -ItemType Directory

ECHO .
ECHO "XCOPYコマンドを開始します"
ECHO .

XCOPY $FromPath $DestPath2 /S /Y /E /C /H 

# エラー検査
$XcopyExitCode=$LastExitCode

ECHO .
ECHO "XCOPYコマンドが終了しました"
ECHO .

if( ( $XcopyExitCode ) -eq 0 ) { ECHO xcopy終了コード=0:ファイルはエラーなしでコピーされました。               }
if( ( $XcopyExitCode ) -eq 1 ) { ECHO xcopy終了コード=1:コピーするファイルが見つかりませんでした。             }
if( ( $XcopyExitCode ) -eq 2 ) { ECHO xcopy終了コード=2:ユーザーが Ctrl + C キーを押して xcopy を終了しました。}
if( ( $XcopyExitCode ) -eq 4 ) { ECHO xcopy終了コード=4:初期化エラーが発生しました。 メモリまたはディスク領域が不足しているか、コマンド ラインに無効なドライブ名または無効な構文が入力されました。}
if( ( $XcopyExitCode ) -eq 5 ) { ECHO xcopy終了コード=5:ディスク書き込みエラーが発生しました。                 }


ECHO .
ECHO "バックアップ世代管理の処理を開始"
ECHO .

# バックアップ世代管理
[System.IO.DirectoryInfo[]] $DestPath_SubFolders = dir $DestPath  -Directory

$DestPath_SubFolders_Count         = $DestPath_SubFolders.Count
$DestPath_SubFolders_EraseCount = $DestPath_SubFolders.Count - $BackupHistoryCount

echo "バックアップ先ベースフォルダ名:$DestPath"
echo "　バックアップのサブフォルダの総数:$DestPath_SubFolders_Count"
echo "　保持する世代数:$BackupHistoryCount"
echo "　削除されるフォルダ数:$DestPath_SubFolders_EraseCount"

$cnt = 0
foreach ($item in $DestPath_SubFolders) {
    $cnt = $cnt + 1
    if( ( $cnt -le $DestPath_SubFolders_EraseCount ) -eq "true"  ){ 
        ECHO "$cnt : 古いバックアップ世代のため削除 : $item"

        $eraseFullPath = $DestPath + $item
        Remove-Item -Path $eraseFullPath -Recurse -Force
    } else { 
        ECHO "$cnt : 保持対象:$item" 
    }
}

ECHO .
ECHO "バックアップ世代管理の処理が終了しました"
ECHO .


# PowerShellログ出力の終了
Stop-Transcript
