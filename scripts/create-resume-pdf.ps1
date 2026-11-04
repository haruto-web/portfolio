Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing

$assets = Join-Path $PSScriptRoot '..\public\assets'
$pdfPath = Join-Path $assets 'ven-andrew-mirasol-resume.pdf'
$docxPath = Join-Path $assets 'ven-andrew-mirasol-resume.docx'
$photoPath = Join-Path $assets 'Updated_pic.png'

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
    $script:pdfContent += "0.55 0.58 0.61 RG 0.65 w 54 $y m 558 $y l S`n"
}

function Get-WrappedLines([string]$text, [int]$maxChars) {
    $lines = [System.Collections.Generic.List[string]]::new()
    $line = ''
    foreach ($word in ($text -split '\s+')) {
        $candidate = if ($line) { "$line $word" } else { $word }
        if ($candidate.Length -gt $maxChars -and $line) {
            $lines.Add($line)
            $line = $word
        }
        else {
            $line = $candidate
        }
    }
    if ($line) { $lines.Add($line) }
    return $lines.ToArray()
}

function Ensure-PdfSpace([int]$height) {
    if ($script:y - $height -lt 48) {
        $script:pdfPages.Add($script:pdfContent)
        $script:pdfContent = ''
        $script:y = 750
    }
}

function Add-PdfParagraph([string]$text, [int]$x, [int]$size, [bool]$bold, [string]$color, [int]$maxChars, [int]$lineHeight) {
    $lines = @(Get-WrappedLines $text $maxChars)
    Ensure-PdfSpace ($lines.Count * $lineHeight + 3)
    foreach ($line in $lines) {
        Add-PdfText $line $x $script:y $size $bold $color
        $script:y -= $lineHeight
    }
    $script:y -= 3
}

$sourceImage = [System.Drawing.Image]::FromFile($photoPath)
$bitmap = [System.Drawing.Bitmap]::new($sourceImage.Width, $sourceImage.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.Clear([System.Drawing.Color]::White)
$graphics.DrawImage($sourceImage, 0, 0, $sourceImage.Width, $sourceImage.Height)
$jpegStream = [System.IO.MemoryStream]::new()
$bitmap.Save($jpegStream, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$photoBytes = $jpegStream.ToArray()
$photoWidth = $bitmap.Width
$photoHeight = $bitmap.Height
$graphics.Dispose()
$bitmap.Dispose()
$sourceImage.Dispose()
$jpegStream.Dispose()

$script:pdfPages = [System.Collections.Generic.List[string]]::new()
$script:pdfContent = ''
$script:y = 750

$script:pdfContent += "q 90 0 0 120 54 660 cm /Im1 Do Q`n"
$script:pdfContent += "0.55 0.58 0.61 RG 0.65 w 54 660 90 120 re S`n"
Add-PdfText $resume[0].Text 164 746 15 $true '0.12 0.16 0.22'
Add-PdfText $resume[1].Text 164 723 9 $true '0.12 0.16 0.22'
$contactParts = $resume[2].Text -split '\s*\|\s*'
$contactY = 699
foreach ($contactPart in $contactParts) {
    Add-PdfText $contactPart 164 $contactY 9 $false '0.12 0.16 0.22'
    $contactY -= 15
}
Add-PdfRule 642
$script:y = 627

for ($index = 3; $index -lt $resume.Count; $index++) {
    $item = $resume[$index]
    switch ($item.Type) {
        'section' {
            Ensure-PdfSpace 30
            Add-PdfText $item.Text 54 $script:y 10 $true '0.12 0.16 0.22'
            Add-PdfRule ($script:y - 5)
            $script:y -= 20
        }
        'project' {
            Add-PdfParagraph $item.Text 54 9 $true '0.12 0.16 0.22' 105 12
        }
        'demo' {
            Add-PdfParagraph $item.Text 66 8 $false '0.28 0.30 0.33' 105 11
        }
        'body' {
            Add-PdfParagraph $item.Text 54 9 $false '0.12 0.16 0.22' 105 12
        }
    }
}
$script:pdfPages.Add($script:pdfContent)

$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$photoString = $latin1.GetString($photoBytes)
$pdfObjects = [System.Collections.Generic.List[string]]::new()
$pdfObjects.Add('<< /Type /Catalog /Pages 2 0 R >>')
$pageReferences = for ($index = 0; $index -lt $script:pdfPages.Count; $index++) {
    "$((6 + ($index * 2))) 0 R"
}
$pdfObjects.Add("<< /Type /Pages /Kids [$($pageReferences -join ' ')] /Count $($script:pdfPages.Count) >>")
$pdfObjects.Add('<< /Type /Font /Subtype /Type1 /BaseFont /Times-Roman >>')
$pdfObjects.Add('<< /Type /Font /Subtype /Type1 /BaseFont /Times-Bold >>')
$pdfObjects.Add("<< /Type /XObject /Subtype /Image /Width $photoWidth /Height $photoHeight /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length $($photoBytes.Length) >>`nstream`n$photoString`nendstream")
for ($index = 0; $index -lt $script:pdfPages.Count; $index++) {
    $pageObject = 6 + ($index * 2)
    $contentObject = $pageObject + 1
    $pageContent = $script:pdfPages[$index]
    $pdfObjects.Add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> /XObject << /Im1 5 0 R >> >> /Contents $contentObject 0 R >>")
    $pdfObjects.Add("<< /Length $($latin1.GetByteCount($pageContent)) >>`nstream`n$pageContent`nendstream")
}

$pdf = "%PDF-1.4`n"
$offsets = [System.Collections.Generic.List[int]]::new()
for ($index = 0; $index -lt $pdfObjects.Count; $index++) {
    $offsets.Add($latin1.GetByteCount($pdf))
    $pdf += "$($index + 1) 0 obj`n$($pdfObjects[$index])`nendobj`n"
}
$xrefOffset = $latin1.GetByteCount($pdf)
$pdf += "xref`n0 $($pdfObjects.Count + 1)`n0000000000 65535 f `n"
foreach ($offset in $offsets) { $pdf += ('{0:D10} 00000 n ' -f $offset) + "`n" }
$pdf += "trailer`n<< /Size $($pdfObjects.Count + 1) /Root 1 0 R >>`nstartxref`n$xrefOffset`n%%EOF`n"
[IO.File]::WriteAllBytes($pdfPath, $latin1.GetBytes($pdf))

function New-WordParagraph([string]$text, [string]$style) {
    $escapedText = Escape-XmlText $text
    return "<w:p><w:pPr><w:pStyle w:val=`"$style`"/></w:pPr><w:r><w:t xml:space=`"preserve`">$escapedText</w:t></w:r></w:p>"
}

$nameParagraph = New-WordParagraph $resume[0].Text 'Title'
$roleParagraph = New-WordParagraph $resume[1].Text 'Subtitle'
$contactParagraphs = foreach ($contactPart in ($resume[2].Text -split '\s*\|\s*')) {
    New-WordParagraph $contactPart 'Contact'
}
$photoDrawing = @'
<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="1000000" cy="1333333"/><wp:docPr id="1" name="Profile photo"/><wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:nvPicPr><pic:cNvPr id="0" name="Profile photo"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="rId2"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="1000000" cy="1333333"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>
'@
$headerTable = @"
<w:tbl><w:tblPr><w:tblW w:w="10000" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="100" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblGrid><w:gridCol w:w="2200"/><w:gridCol w:w="7800"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr><w:tc><w:tcPr><w:tcW w:w="2200" w:type="dxa"/></w:tcPr>$photoDrawing</w:tc><w:tc><w:tcPr><w:tcW w:w="7800" w:type="dxa"/></w:tcPr>$nameParagraph$roleParagraph$($contactParagraphs -join '')</w:tc></w:tr></w:tbl>
"@

$paragraphs = [System.Collections.Generic.List[string]]::new()
$paragraphs.Add($headerTable)
$paragraphs.Add('<w:p><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="2" w:color="8C949B"/></w:pBdr><w:spacing w:after="120"/></w:pPr></w:p>')
for ($index = 3; $index -lt $resume.Count; $index++) {
    $item = $resume[$index]
    $style = switch ($item.Type) {
        'section' { 'Section' }
        'project' { 'Project' }
        'demo' { 'Demo' }
        default { 'Normal' }
    }
    $paragraphs.Add((New-WordParagraph $item.Text $style))
}

$documentXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:body>$($paragraphs -join '')<w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="720" w:right="900" w:bottom="720" w:left="900" w:header="360" w:footer="360" w:gutter="0"/></w:sectPr></w:body></w:document>
"@

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/><w:sz w:val="18"/><w:color w:val="1F2937"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="50" w:line="220" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
  <w:style w:type="paragraph" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/></w:style>
  <w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="30"/><w:color w:val="1F2937"/></w:rPr><w:pPr><w:spacing w:after="40"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Subtitle"><w:name w:val="Subtitle"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="19"/></w:rPr><w:pPr><w:spacing w:after="80"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Contact"><w:name w:val="Contact"/><w:basedOn w:val="Normal"/><w:rPr><w:sz w:val="18"/></w:rPr><w:pPr><w:spacing w:after="35"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Section"><w:name w:val="Section"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:pPr><w:jc w:val="center"/><w:keepNext/><w:spacing w:before="110" w:after="60"/><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="2" w:color="8C949B"/></w:pBdr></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Project"><w:name w:val="Project"/><w:basedOn w:val="Normal"/><w:rPr><w:b/><w:sz w:val="18"/></w:rPr><w:pPr><w:keepNext/><w:spacing w:before="45" w:after="15"/></w:pPr></w:style>
  <w:style w:type="paragraph" w:styleId="Demo"><w:name w:val="Demo"/><w:basedOn w:val="Normal"/><w:rPr><w:sz w:val="16"/><w:color w:val="4B5563"/></w:rPr><w:pPr><w:spacing w:after="35"/></w:pPr></w:style>
</w:styles>
'@

$contentTypesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
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
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/profile.png"/>
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
    $photoEntry = $archive.CreateEntry('word/media/profile.png')
    $photoFileStream = [IO.File]::OpenRead($photoPath)
    $photoEntryStream = $photoEntry.Open()
    try { $photoFileStream.CopyTo($photoEntryStream) }
    finally {
        $photoEntryStream.Dispose()
        $photoFileStream.Dispose()
    }
}
finally {
    $archive.Dispose()
    $docxStream.Dispose()
}

Write-Output "Created $pdfPath"
Write-Output "Created $docxPath"
