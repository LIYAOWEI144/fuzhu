[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CommandFile,
    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,
    [string]$ReviewFileName = 'GROMACS_command_review.txt'
)

$ErrorActionPreference = 'Stop'
$commandPath = (Resolve-Path -LiteralPath $CommandFile).Path
if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

$reviewPath = Join-Path $OutputDirectory $ReviewFileName
$lines = Get-Content -LiteralPath $commandPath
$report = [System.Collections.Generic.List[string]]::new()
$report.Add('GROMACS 命令审计报告')
$report.Add("来源文件：$commandPath")
$report.Add('说明：本报告不执行模拟；请逐条核对建议命令及其所引用的 MDP/拓扑。')
$report.Add('')

foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if (-not $trimmed.StartsWith('gmx ')) { continue }

    $recommendation = $null
    $reason = $null
    if ($trimmed -match '\s-maxwarn\s+\d+') {
        $recommendation = ($trimmed -replace '\s-maxwarn\s+\d+', '')
        $reason = '首次预处理不应忽略 warning。请先运行此命令，逐条处理输出后才使用最小必要的 -maxwarn。'
    } elseif ($trimmed -match '^gmx\s+solvate\b') {
        $recommendation = $trimmed
        $reason = '执行前确认拓扑已定义与所选水模型兼容的 SOL；坐标文件不会自动添加水分子拓扑。'
    } elseif ($trimmed -match '^gmx\s+genion\b') {
        $recommendation = $trimmed
        $reason = '在交互选择时仅选择 SOL 组；执行后核对离子 residue 名称、[ molecules ] 和离子 .itp 定义一致。'
    } elseif ($trimmed -match '^gmx\s+genrestr\b') {
        $recommendation = $trimmed
        $reason = '仅在计划约束配体时使用。生成的 posre 文件必须被 LIG.itp 条件包含，并使用独立的配体约束宏。'
    } elseif ($trimmed -match '^gmx\s+mdrun\b') {
        $recommendation = $trimmed
        $reason = '运行前保留 .tpr、.mdp、.top/.itp 和 checkpoint；长生产模拟应先确认轨迹输出频率与可用磁盘空间。'
    } else {
        $recommendation = $trimmed
        $reason = '命令语法未见通用替换项；仍须结合对应 MDP、拓扑和 grompp 输出进行预检。'
    }

    $report.Add("原命令：$trimmed")
    $report.Add("建议命令：$recommendation")
    $report.Add("原因：$reason")
    $report.Add('')
}

if ($report.Count -le 4) {
    $report.Add('未识别到以 gmx 开头的命令；请检查输入文本的命令格式。')
}

[System.IO.File]::WriteAllLines($reviewPath, $report, [System.Text.UTF8Encoding]::new($false))
Write-Output $reviewPath
