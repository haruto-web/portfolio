function Escape-PdfText([string]$text) {
    return $text.Replace('\', '\\').Replace('(', '\(').Replace(')', '\)')
}

function Add-Text([string]$text, [int]$x, [int]$y, [int]$size, [bool]$bold = $false, [string]$color = '0.12 0.16 0.22') {
    $font = if ($bold) { '/F2' } else { '/F1' }
    $script:content += "$color rg BT $font $size Tf 1 0 0 1 $x $y Tm ($(Escape-PdfText $text)) Tj ET`n"
}

function Add-Rule([int]$x1, [int]$y1, [int]$x2, [int]$y2) {
    $script:content += "0.78 0.82 0.87 RG 0.7 w $x1 $y1 m $x2 $y2 l S`n"
}

$content = ''
$content += "0.08 0.13 0.22 rg 0 700 595 142 re f`n"
Add-Text 'VEN ANDREW B. MIRASOL' 50 790 22 $true '1 1 1'
Add-Text 'MOBILE & WEB DEVELOPER  |  BSIT STUDENT' 52 766 10 $false '0.72 0.84 0.96'
Add-Text 'venandrewmirasol@gmail.com  |  +63 992 149 7659  |  github.com/haruto-web' 52 733 9 $false '1 1 1'

Add-Text 'ABOUT ME' 50 668 11 $true '0.08 0.37 0.65'
Add-Rule 50 659 545 659
Add-Text 'BSIT student and aspiring developer focused on software development,' 50 641 10
Add-Text 'mobile and web application design, and database management.' 50 627 10
Add-Text 'Built projects using Firebase, Laravel, Django, React, and Java.' 50 613 10
Add-Text 'Eager to learn, adapt, and contribute to real-world tech solutions.' 50 599 10

Add-Text 'SKILLS' 50 574 11 $true '0.08 0.37 0.65'
Add-Rule 50 565 190 565
Add-Text 'PROGRAMMING' 50 547 9 $true
Add-Text 'Java, Python, PHP,' 50 533 9
Add-Text 'JavaScript, SQL' 50 521 9
Add-Text 'FRAMEWORKS' 50 495 9 $true
Add-Text 'Firebase, Laravel,' 50 481 9
Add-Text 'Django, React, AI/ML' 50 469 9
Add-Text 'TOOLS & DATABASES' 50 443 9 $true
Add-Text 'Android Studio, VS Code,' 50 429 9
Add-Text 'Git, GitHub, MySQL,' 50 417 9
Add-Text 'PostgreSQL, Firestore' 50 405 9
Add-Text 'EDUCATION' 50 291 11 $true '0.08 0.37 0.65'
Add-Rule 50 282 190 282
Add-Text 'BACHELOR OF SCIENCE' 50 264 9 $true
Add-Text 'IN INFORMATION TECHNOLOGY' 50 252 9 $true
Add-Text 'Currently Enrolled' 50 236 9 $false '0.38 0.43 0.50'
Add-Text 'Mobile development, web' 50 218 9
Add-Text 'technologies, databases' 50 206 9

Add-Text 'EDUCATION & PROJECT EXPERIENCE' 225 574 11 $true '0.08 0.37 0.65'
Add-Rule 225 565 545 565
Add-Text 'BSIT STUDENT' 225 547 10 $true
Add-Text 'Currently Enrolled' 225 533 9 $false '0.38 0.43 0.50'
Add-Text '- Focused on mobile app development, web' 225 517 9
Add-Text '  technologies, databases, and project-based learning.' 225 505 9
Add-Text '- Built systems such as BrightTrack LMS,' 225 489 9
Add-Text '  JobAI, AI hazard detection, and mobile apps.' 225 477 9

Add-Text 'PROJECTS BUILT' 225 451 10 $true
Add-Text 'Django  |  PostgreSQL  |  AI/ML' 225 437 9 $false '0.38 0.43 0.50'
Add-Text '- Learning management system with AI support,' 225 421 9
Add-Text '  analytics, performance, and wellness tracking.' 225 409 9

Add-Text 'Laravel  |  MySQL  |  JavaScript  |  AI' 225 393 9 $false '0.38 0.43 0.50'
Add-Text '- Full-stack job platform for employers and job seekers' 225 377 9
Add-Text '  with an AI admin assistant.' 225 365 9

Add-Text 'CONTACT' 225 194 11 $true '0.08 0.37 0.65'
Add-Rule 225 185 545 185
Add-Text 'Email' 225 167 9 $true
Add-Text 'venandrewmirasol@gmail.com' 275 167 9
Add-Text 'GitHub' 225 151 9 $true
Add-Text 'github.com/haruto-web' 275 151 9
Add-Text 'Proficient with VS Code and modern development tools' 225 116 8 $false '0.38 0.43 0.50'

$content += "0.08 0.37 0.65 rg 50 83 495 2 re f`n"
$content += "BT 0.38 0.43 0.50 rg /F1 8 Tf 1 0 0 1 50 64 Tm (Ven Andrew B. Mirasol  |  Mobile & Web Developer) Tj ET`n"

$objects = @(
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R /F2 5 0 R >> >> /Contents 6 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>',
    "<< /Length $([Text.Encoding]::ASCII.GetByteCount($content)) >>`nstream`n$content`nendstream"
)

$pdf = "%PDF-1.4`n"
$offsets = @()
for ($index = 0; $index -lt $objects.Count; $index++) {
    $offsets += [Text.Encoding]::ASCII.GetByteCount($pdf)
    $pdf += "$($index + 1) 0 obj`n$($objects[$index])`nendobj`n"
}
$xrefOffset = [Text.Encoding]::ASCII.GetByteCount($pdf)
$pdf += "xref`n0 $($objects.Count + 1)`n0000000000 65535 f `n"
foreach ($offset in $offsets) { $pdf += ('{0:D10} 00000 n ' -f $offset) + "`n" }
$pdf += "trailer`n<< /Size $($objects.Count + 1) /Root 1 0 R >>`nstartxref`n$xrefOffset`n%%EOF`n"
[IO.File]::WriteAllBytes((Resolve-Path (Join-Path $PSScriptRoot '..\public\assets')).Path + '\ven-andrew-mirasol-resume.pdf', [Text.Encoding]::ASCII.GetBytes($pdf))