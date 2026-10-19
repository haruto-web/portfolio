Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$assets = Join-Path $PSScriptRoot '..\public\assets'
$pdfPath = Join-Path $assets 'ven-andrew-mirasol-resume.pdf'
$docxPath = Join-Path $assets 'ven-andrew-mirasol-resume.docx'

$resume = @(
    @{ Type = 'name'; Text = 'VEN ANDREW B. MIRASOL' }
    @{ Type = 'role'; Text = 'MOBILE & WEB DEVELOPER' }
    @{ Type = 'contact'; Text = 'venandrewmirasol@gmail.com | +63 992 149 7659 | github.com/haruto-web' }
    @{ Type = 'section'; Text = 'PROFESSIONAL SUMMARY' }
    @{ Type = 'body'; Text = 'Fourth-year BSIT student at the Technological Institute of the Philippines with project experience building web applications, database-backed features, and AI-enabled applications. Contributed to a Django learning platform, a Laravel job platform, and an Android PPE detection app using on-device computer vision.' }
    @{ Type = 'section'; Text = 'TECHNICAL SKILLS' }
    @{ Type = 'body'; Text = 'Languages: Python, PHP, JavaScript, SQL' }
    @{ Type = 'body'; Text = 'Frameworks & build tools: Django, Laravel, React, FastAPI, Vite' }
    @{ Type = 'body'; Text = 'AI/ML: Computer vision; YOLOv8 and TensorFlow Lite PPE detection; SSD MobileNet person detection' }
    @{ Type = 'body'; Text = 'Databases: PostgreSQL, MySQL, Firebase / Firestore' }
    @{ Type = 'body'; Text = 'Developer tools: Git, GitHub, Visual Studio Code, Amazon Q, Kiro, Microsoft Agent, Codex' }
    @{ Type = 'section'; Text = 'SELECTED SOFTWARE DEVELOPMENT PROJECTS' }
    @{ Type = 'project'; Text = 'BrightTrack LMS | Python, Django, PostgreSQL, AI/ML' }
    @{ Type = 'body'; Text = 'Contributed to web development and database integration for a learning platform with learning analytics, academic performance tracking, and wellness monitoring.' }
    @{ Type = 'demo'; Text = 'Demo: https://brighttrack.onrender.com/ (static preview)' }
    @{ Type = 'project'; Text = 'JobAI | PHP, Laravel, JavaScript, MySQL, AI assistant' }
    @{ Type = 'body'; Text = 'Developed application features for a full-stack platform connecting employers and job seekers through separate portals, with an AI-powered administrative assistant, using Laravel, MySQL, and JavaScript.' }
    @{ Type = 'demo'; Text = 'Demo: https://jobai-1-7c66.onrender.com/ (static preview)' }
    @{ Type = 'project'; Text = 'HAZORA | Web dashboard: React, Vite, Firebase, Python, FastAPI, Computer Vision' }
    @{ Type = 'body'; Text = 'Construction-safety dashboard for authorized teams to monitor ESP32-CAM feeds, review AI-flagged PPE incidents, view safety analytics, and export reports. Role-based access supports site and head-office staff.' }
    @{ Type = 'project'; Text = 'HAZORA Mobile | Java, Android, CameraX, TensorFlow Lite, YOLOv8, SSD MobileNet' }
    @{ Type = 'body'; Text = 'Implemented a multi-frame scan flow that analyzes up to three camera frames and combines results. Runs on-device TensorFlow Lite inference with YOLOv8 PPE detection for helmets, vests, and shoes, alongside SSD MobileNet person detection.' }
    @{ Type = 'demo'; Text = 'Android app repository: https://github.com/lckdxx/HAZORA-Mobile/tree/UPDATED-AIUI' }
    @{ Type = 'section'; Text = 'EDUCATION' }
    @{ Type = 'project'; Text = 'Bachelor of Science in Information Technology | Technological Institute of the Philippines' }
    @{ Type = 'body'; Text = 'Fourth-year student' }
)

function Escape-PdfText([string]$text) {
    return $text.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
}

function Escape-XmlText([string]$text) {
    return [System.Security.SecurityElement]::Escape($text)
}

function Add-PdfText([string]$text, [int]$x, [int]$y, [int]$size, [bool]$bold, [string]$color) {
    $font = if ($bold) { '/F2' } else { '/F1' }
    $script:pdfContent += "$color rg BT $font $size Tf 1 0 0 1 $x $y Tm ($(Escape-PdfText $text)) Tj ET`n"
}

function Add-PdfRule([int]$y) {
    $script:pdfContent += "0.78 0.82 0.87 RG 0.7 w 54 $y m 558 $y l S`n"
}

$script:pdfContent = ''
$y = 750
foreach ($item in $resume) {
    switch ($item.Type) {
        'name' {
            Add-PdfText $item.Text 54 $y 20 $true '0.08 0.13 0.22'
            $y -= 25
        }
        'role' {
            Add-PdfText $item.Text 54 $y 10 $true '0.08 0.37 0.65'
            $y -= 16
        }
        'contact' {
            Add-PdfText $item.Text 54 $y 9 $false '0.25 0.29 0.34'
            $y -= 20
        }
        'section' {
            Add-PdfText $item.Text 54 $y 11 $true '0.08 0.37 0.65'
            $y -= 5
            Add-PdfRule $y
            $y -= 14
        }
        'project' {
            Add-PdfText $item.Text 54 $y 9 $true '0.12 0.16 0.22'
            $y -= 13
        }
        'demo' {
            Add-PdfText $item.Text 66 $y 8 $false '0.25 0.29 0.34'
            $y -= 12
        }
        'body' {
            $words = $item.Text -split '\s+'
            $line = ''
            foreach ($word in $words) {
                $candidate = if ($line) { "$line $word" } else { $word }
                if ($candidate.Length -gt 98 -and $line) {
                    Add-PdfText $line 54 $y 10 $false '0.12 0.16 0.22'
                    $y -= 13
                    $line = $word
                }
                else {
                    $line = $candidate
                }
            }
            if ($line) {
                Add-PdfText $line 54 $y 10 $false '0.12 0.16 0.22'
                $y -= 16
            }
        }
    }
}

$pdfObjects = @(
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>',
    "<< /Length $([Text.Encoding]::ASCII.GetByteCount($pdfContent)) >>`nstream`n$pdfContent`nendstream"
)

$pdf = "%PDF-1.4`n"
$offsets = @()
for ($index = 0; $index -lt $pdfObjects.Count; $index++) {
    $offsets += [Text.Encoding]::ASCII.GetByteCount($pdf)
    $pdf += "$($index + 1) 0 obj`n$($pdfObjects[$index])`nendobj`n"
}
$xrefOffset = [Text.Encoding]::ASCII.GetByteCount($pdf)
$pdf += "xref`n0 $($pdfObjects.Count + 1)`n0000000000 65535 f `n"
foreach ($offset in $offsets) { $pdf += ('{0:D10} 00000 n ' -f $offset) + "`n" }
$pdf += "trailer`n<< /Size $($pdfObjects.Count + 1) /Root 1 0 R >>`nstartxref`n$xrefOffset`n%%EOF`n"
[IO.File]::WriteAllBytes($pdfPath, [Text.Encoding]::ASCII.GetBytes($pdf))

$paragraphs = foreach ($item in $resume) {
    $style = switch ($item.Type) {
        'name' { 'Title' }
        'role' { 'Subtitle' }
        'contact' { 'Contact' }
        'section' { 'Heading1' }
        'project' { 'Heading2' }
        'demo' { 'Demo' }
        default { 'Normal' }
    }
    $text = Escape-XmlText $item.Text
    "<w:p><w:pPr><w:pStyle w:val=`"$style`"/></w:pPr><w:r><w:t xml:space=`"preserve`">$text</w:t></w:r></w:p>"
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>$($paragraphs -join '')<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="720" w:right="900" w:bottom="720" w:left="900" w:header="360" w:footer="360" w:gutter="0"/></w:sectPr></w:body></w:document>
"@

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="20"/><w:color w:val="1F2937"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="80" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
  <w:style w:type="paragraph" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="40"/><w:color w:val="14213D"/></w:rPr><w:pPr><w:spacing w:after="40"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="21"/><w:color w:val="145E9A"/></w:rPr><w:pPr><w:spacing w:after="60"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Contact"><w:name w:val="Contact"/><w:basedOn w:val="Normal"/><w:rPr><w:sz w:val="18"/></w:rPr><w:pPr><w:spacing w:after="140"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="22"/><w:color w:val="145E9A"/></w:rPr><w:pPr><w:keepNext/><w:spacing w:before="100" w:after="70"/><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="2" w:color="C7D0D9"/></w:pBdr></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="19"/></w:rPr><w:pPr><w:keepNext/><w:spacing w:before="40" w:after="20"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Demo"><w:name w:val="Demo"/><w:basedOn w:val="Normal"/><w:rPr><w:sz w:val="16"/><w:color w:val="4B5563"/></w:rPr><w:pPr><w:spacing w:after="60"/></w:pPr></w:style>
</w:styles>
'@

$contentTypesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
'@

$relsXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@

$documentRelsXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>
'@

$docxStream = [IO.File]::Open($docxPath, [IO.FileMode]::Create)
$archive = [IO.Compression.ZipArchive]::new($docxStream, [IO.Compression.ZipArchiveMode]::Create)
try {
    $entries = @{
        '[Content_Types].xml' = $contentTypesXml
        '_rels/.rels' = $relsXml
        'word/document.xml' = $documentXml
        'word/styles.xml' = $stylesXml
        'word/_rels/document.xml.rels' = $documentRelsXml
    }
    foreach ($entryName in $entries.Keys) {
        $entry = $archive.CreateEntry($entryName)
        $writer = [IO.StreamWriter]::new($entry.Open(), [Text.Encoding]::UTF8)
        try { $writer.Write($entries[$entryName]) } finally { $writer.Dispose() }
    }
}
finally {
    $archive.Dispose()
    $docxStream.Dispose()
}

Write-Output "Created $pdfPath"
Write-Output "Created $docxPath"
